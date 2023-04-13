//
//  Peer.Selector.swift
//  Camera
//
//  Created by Ivan Kh on 22.04.2022.
//  Copyright © 2022 Ivan Kh. All rights reserved.
//

import Foundation
import Combine
import BlackUtils
import BlackMedia


final class Peer {}

extension Peer {
    final class Selector {}
}

protocol PeerSelectorProtocol : ObservableObject {
    var peer: Network.Peer.Proto? { get }
    var peerPublisher: Published<Network.Peer.Proto?>.Publisher { get }
}

extension Peer.Selector {
    typealias Proto = PeerSelectorProtocol
    typealias AnyProto = any PeerSelectorProtocol
}

extension Peer.Selector {
    class General : PeerSelectorProtocol {
        private var peers: [Network.Peer.Proto] = []
        private var peerSubscription: AnyCancellable?
        private var peersSubscription: AnyCancellable?
        private let peersPublisher: AnyPublisher<[Network.Peer.Proto], Never>
        private let queue = TaskQueue()

        @Published private(set) var peer: Network.Peer.Proto?
        @Published private(set) var connectedPeer: Network.Peer.Proto?
        var peerPublisher: Published<Network.Peer.Proto?>.Publisher { $peer }

        init() {
            peersPublisher = Empty(completeImmediately: false).eraseToAnyPublisher()
            setup(peers: peersPublisher)
        }
        
        init(peers: AnyPublisher<[Network.Peer.Proto], Never>) {
            peersPublisher = peers
            setup(peers: peers)
        }

        private func setup(peers: AnyPublisher<[Network.Peer.Proto], Never>) {
            peersSubscription = peers.sink(receiveValue: peers(value:))
        }
        
        private func peers(value: [Network.Peer.Proto]) {
            self.peers = value
            select()
        }

        @MainActor private func set(peer: Network.Peer.Proto) {
            guard self.peer !== peer else { return }

            self.peerSubscription?.cancel()
            self.peer = peer

            if peer.state.value == .connected {
                self.connectedPeer = peer
            }

            peerSubscription = peer.state.sink { state in
                if state == .connected {
                    self.connectedPeer = peer
                }
                else {
                    self.connectedPeer = nil
                }
            }
        }

        private func select() {
            queue.task {
                guard self.peer?.state.value != .connected else { return }
                guard let newPeer = self.peers.sortedByState().first else { return }
                let oldPeer = self.peer

                do {
                    debugPrint("Selector: selecting peer \(newPeer.debugIdentifier)")

                    if newPeer.state.value != .connected {
                        _ = try await newPeer.connect()
                    }

                    debugPrint("STATE in SELECTOR \(newPeer.state.value)")

                    if newPeer.state.value == .connected && newPeer !== oldPeer {
                        await self.set(peer: newPeer)

                        Task {
                            await oldPeer?.disconnect()
                        }

                        debugPrint("Selector: set peer \(newPeer.debugIdentifier)")
                    }
                }
                catch {
                    debugPrint("Selector: connection error \(error)")
                }
            }
        }
    }
}

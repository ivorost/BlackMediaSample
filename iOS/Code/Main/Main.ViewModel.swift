//
//  Main.ViewModel.swift
//  Camera
//
//  Created by Ivan Kh on 11.08.2022.
//  Copyright © 2022 Ivan Kh. All rights reserved.
//

import Foundation
import UIKit
import Combine
import BlackMedia

extension Main {
    class ViewModel : ObservableObject {
        let peerSelector: Peer.Selector.AnyProto
        private let nwSession = Network.NW.Session()
        private let peersLog = Network.Peer.Log.Publisher()
        private let put: Peer.Put

        init() {
            peerSelector
            = Peer.Selector.General(peers: nwSession.peers.peers.receive(on: RunLoop.main).eraseToAnyPublisher())

            put
            = Peer.Put(peerSelector)
        }
        
        func start() async throws {
            try await nwSession.start()
        }
    }
}

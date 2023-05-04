//
//  Media.ViewModel.swift
//  Camera
//
//  Created by Ivan Kh on 04.11.2022.
//  Copyright © 2022 Ivan Kh. All rights reserved.
//

import AVFoundation
import Combine
import BlackUtils
import BlackMedia

struct Media {}
extension Media { struct Put {} }
extension Media { struct Get {} }

extension Media {
    class ViewModel : ObservableObject {
        @Published var peer: Network.Peer.Proto?
        fileprivate let peerPublisher: Network.Peer.OptionalValuePublisher
        private var session: Session.Proto?

        init(_ peer: Network.Peer.OptionalValuePublisher = Just<Network.Peer.Proto?>(nil).eraseToAnyValuePublisher()) {
            self.peerPublisher = peer
            peer.assign(to: &self.$peer)
        }

        func start(layer: SampleBufferDisplayLayer) {
            BlackMedia.Capture.queue.async {
                let session = self.setup(layer: layer)

                do {
                    try session.start()
                    self.session = session
                }
                catch {
                    logAVError(error)
                }
            }
        }
        
        func stop() {
            BlackMedia.Capture.queue.async {
                self.session?.stop()
            }
        }
        
        func setup(layer: SampleBufferDisplayLayer) -> Session.Proto {
            return Session.shared
        }
    }
}

extension Media.Put {
    class ViewModel : Media.ViewModel {
        override func setup(layer: SampleBufferDisplayLayer) -> Session.Proto {
            let peer = Capture.Peer(peerPublisher)
            let media = Video.streamCamera(to: peer, preview: layer)
            return broadcast([ peer, media ])
        }
    }
}

extension Media.Get {
    class ViewModel : Media.ViewModel {
        override func setup(layer: SampleBufferDisplayLayer) -> Session.Proto {
            let peer = Capture.Peer(peerPublisher)
            let media = Video.display(from: peer, to: layer)
            return broadcast([ peer, media ])
        }
    }
}

//  Created by Ivan Kh on 11.08.2022.

import Foundation
import UIKit
import Combine
import BlackMedia
import BlackUtils

extension Main {
    class ViewModel : ObservableObject {
        @Published private(set) var peer: Network.Peer.Proto?
        private let nwSession = Network.NW.Session()

        init() {
            nwSession.store.peers
                .receive(on: RunLoop.main)
                .firstConnected()
                .connectWhenAvailable()
                .connectWhenEnterForeground()
                .receive(on: DispatchQueue.main)
                .assign(to: &$peer)
        }
        
        func start() async throws {
            try await nwSession.start()
        }
    }
}

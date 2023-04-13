//
//  App.SwiftUI.swift
//  Camera
//
//  Created by Ivan Kh on 05.08.2022.
//  Copyright © 2022 Ivan Kh. All rights reserved.
//

import SwiftUI
import Combine
import BlackMedia

struct Main {}

extension Main {
    @main
    struct Scene: App {
        @ObservedObject private var vm: ViewModel
        @ObservedObject private var router: Router.General
        let peerCancellable: AnyCancellable

        init() {
            let vm = ViewModel()
            self.vm = vm

            let router = Router.General(selector: vm.peerSelector)
            self.router = router

            peerCancellable = vm.peerSelector.peerPublisher.sink { peer in
                if let peer, peer.id != "" {
                    router.navigate(to: .capture)
                }
                else {
                    router.navigate(to: .pair)
                }
            }

            Task {
                try! await vm.start()
            }
        }

        var body: some SwiftUI.Scene {
            WindowGroup {
                ZStack {
                    Color.applicationBackground

                    router
                        .view
                        .zIndex(1)
                }
                .ignoresSafeArea()
                .environmentObject(router)
            }
        }
    }
}

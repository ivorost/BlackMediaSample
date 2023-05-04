//
//  App.SwiftUI.swift
//  Camera
//
//  Created by Ivan Kh on 05.08.2022.
//  Copyright © 2022 Ivan Kh. All rights reserved.
//

import SwiftUI
import AVFoundation
import Combine
import BlackMedia
import BlackUtils

struct Main {}

extension Main {
    @main
    struct Scene: App {
        @ObservedObject private var vm: ViewModel
        @ObservedObject private var router: Router.General

        init() {
            let vm = ViewModel()

            self.vm = vm
            self.router = Router.General(vm.$peer.eraseToAnyValuePublisher())

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
                .onReceive(vm.$peer) { peer in
                    navigate(with: peer)
                }
            }
        }

        private func navigate(with peer: (any Network.Peer.Proto)?) {
            guard let peer else {
                router.navigate(to: .pair)
                return
            }

            if peer.id.name > Network.Peer.Identity.local.name {
                router.navigate(to: .capture)
            }
            else {
                router.navigate(to: .display)
            }
        }
    }
}

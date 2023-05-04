//
//  Main.Router.swift
//  Camera
//
//  Created by Ivan Kh on 07.04.2023.
//  Copyright © 2023 Ivan Kh. All rights reserved.
//

import SwiftUI
import BlackUtils
import BlackMedia

extension Main {
    final class Router {}
}

extension Main.Router {
    enum Route {
        case pair
        case capture
        case display
    }
}

extension Main.Router {
    typealias Proto = RouterProtocol
    typealias AnyProto = any RouterProtocol<Route>
    typealias Empty = EmptyRouter<Route>
}

extension Main.Router {
    class General: Proto {
        @Published var route: Route = .pair
        var routePublisher: Published<Route>.Publisher { $route }
        var peer: Network.Peer.OptionalValuePublisher

        init(_ peer: Network.Peer.OptionalValuePublisher) {
            self.peer = peer
        }

        var view: some View {
            switch route {
            case .pair:
                Peer.View()
            case .capture:
                Media.View(vm: Media.Put.ViewModel(peer), title: "Streaming to")
            case .display:
                Media.View(vm: Media.Get.ViewModel(peer), title: "Receiving from")
            }
        }

        func navigate(to route: Route) {
            self.route = route
        }
    }
}

private extension View {
    func animationModifier() -> some View {
        let duration: CFTimeInterval = 0.5

        return self
            .transition(.asymmetric(insertion: .dummy, removal: .dummy).animation(.linear(duration: duration)))
            .environment(\.animationDuration, duration)
    }
}

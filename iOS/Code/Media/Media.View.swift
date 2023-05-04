//
//  Media.Get.View.swift
//  Camera
//
//  Created by Ivan Kh on 04.11.2022.
//  Copyright © 2022 Ivan Kh. All rights reserved.
//

import SwiftUI
import BlackUtils
import BlackMedia

extension Media {
    struct View: SwiftUI.View {
        @ObservedObject var vm: ViewModel
        let title: String

        var body: some SwiftUI.View {
            let sampleBufferView = SampleBufferDisplaySwiftUI()

            ZStack(alignment: .bottomLeading) {
                sampleBufferView
                    .videoGravity(.resizeAspectFill)
                    .onAppear {
                        vm.start(layer: sampleBufferView.layer)
                    }
                    .onDisappear {
                        vm.stop()
                    }

                ZStack(alignment: .bottomTrailing) {
                    if let peer = vm.peer {
                        Media.View.Peer(peer: peer, title: title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 30)
                            .padding(.bottom, 30)
                            .padding(.top, 10)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.peerBackground)
            }
        }
    }
}

extension Media.View {
    struct Peer: SwiftUI.View {
        let peer: Network.Peer.AnyProto
        let title: String
        @State var state: Network.Peer.State = .disconnected
        #if DEBUG
        @State var description: String = ""
        #endif

        var body: some SwiftUI.View {
            VStack {
                HStack {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(Color(state.color))
                        .onReceive(peer.state.receive(on: RunLoop.main)) { value in
                            withAnimation {
                                self.state = value
                            }
                        }

                    Text("\(title) \(peer.id.name)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                #if DEBUG
                Divider()

                HStack {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.clear)

                    Text(description)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .onReceive(peer.debugDescription.receive(on: RunLoop.main)) { description in
                    self.description = description
                }
                #endif
            }
        }
    }
}

struct MediaViewPreview: PreviewProvider {
    static var previews: some View {
        Media.View(vm: Media.ViewModel(), title: "Preview")
    }
}

extension Color {
    static let peerBackground = Color("peer_background")
}

extension Network.Peer.State {
    var color: UIColor {
        switch self {
        case .connected: return .green
        case .connecting: return .yellow
        case .disconnected, .disconnecting: return .red
        }
    }
}

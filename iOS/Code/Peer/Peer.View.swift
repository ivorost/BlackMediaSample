//
//  Peer.View.swift
//  Camera
//
//  Created by Ivan Kh on 13.04.2023.
//  Copyright © 2023 Ivan Kh. All rights reserved.
//

import SwiftUI

final class Peer {}

extension Peer {
    struct View: SwiftUI.View {
        var body: some SwiftUI.View {
            VStack {
                GrowingCircleIndicatorView()
                    .foregroundColor(.green)
                    .frame(width: 100, height: 100)
                
                Text("Please open application on another device")
                    .multilineTextAlignment(.center)
                    .padding(50)
            }
        }
    }
}

struct PeerViewPreview: PreviewProvider {
    static var previews: some View {
        Peer.View()
    }
}

struct GrowingCircleIndicatorView: View {

    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        let animation = Animation
            .easeIn(duration: 1.1)
            .repeatForever(autoreverses: false)

        return Circle()
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                scale = 0
                opacity = 1
                DispatchQueue.main.async {
                    withAnimation(animation) {
                        scale = 1
                        opacity = 0
                    }
                }
            }
    }
}

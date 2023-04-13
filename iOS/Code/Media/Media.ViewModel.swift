//
//  Media.ViewModel.swift
//  Camera
//
//  Created by Ivan Kh on 04.11.2022.
//  Copyright © 2022 Ivan Kh. All rights reserved.
//

import AVFoundation
import BlackUtils
import BlackMedia

struct Media {}

extension Media {
    class ViewModel : ObservableObject {
        private var session: Session.Proto?
        
        func start(layer: SampleBufferDisplayLayer) {
            BlackMedia.Capture.queue.async {
                let setup = self.setup(layer: layer)
                let session = setup.setup()

                do {
                    try session?.start()
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
        
        func setup(layer: SampleBufferDisplayLayer) -> Video.Setup.Proto {
            return Video.Setup.shared
        }
    }
}

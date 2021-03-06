// Copyright since 2015 Showmax s.r.o.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


import Foundation
import UIKit

import SHMAVPlayerInterface

extension ExamplePlayerController
{
    /// Create and show custom UI over player.
    ///
    /// - Parameter playerInterface: Current player interface to use.
    func setupOverlayView(with playerInterface: SHMAVPlayerInterface)
    {
        playerController.showsPlaybackControls = false
        
        let possibleOverlay = Bundle.main.loadNibNamed(
            "ExamplePlayerControllerOverlayView",
            owner: nil,
            options: nil
        )?.first as? ExamplePlayerControllerOverlayView
        
        guard let overlay = possibleOverlay else
        {
            print("Can't load overlay view.")
            return
        }
        
        add(view: overlay, to: view)
        
        overlay.closeClosure = {[weak self] in
            
            self?.dismiss(animated: true, completion: nil)
        }
        
        overlay.useNew(playerInterface: playerInterface)
    }
}

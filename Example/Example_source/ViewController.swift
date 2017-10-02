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

import UIKit

import AVFoundation
import AVKit

import RxSwift

class ViewController: UIViewController {
    var     bag = DisposeBag()

    /// Initialize and present player controller.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let assetURL = URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8") else {
            fatalError("Can't create URL for asset.")
        }

        let asset = AVAsset(url: assetURL)

        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)

        let playerController = ExamplePlayerController(nibName: "ExamplePlayerController", bundle: nil, player: player)

        present(playerController, animated: true, completion: {[weak playerController] in

            playerController?.playerInterface.play()
        })
    }
}

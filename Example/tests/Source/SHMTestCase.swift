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
import AVFoundation

import XCTest
import Nimble
import RxSwift
import RxBlocking
import SHMAVPlayerInterface

let kBipBopDuration: TimeInterval = 1800.045

class SHMTestCase: XCTestCase
{
    var bag = DisposeBag()
    var lastPlayer: AVPlayer? = nil
    
    override func setUp()
    {
        super.setUp()
    }
    
    override func tearDown()
    {
        super.tearDown()
        
        bag = DisposeBag()
        lastPlayer = nil
    }
    
    func createPlayer() -> AVPlayer
    {
        let asset = AVAsset(url: URL(string: "https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)

        lastPlayer = player
        
        return player
    }
    
    func createPlayerAndInterface() -> (player: AVPlayer, interface: SHMAVPlayerInterface)
    {
        let player = createPlayer()
        let interface = SHMAVPlayerInterface(player: player)
        
        return (player: player, interface: interface)
    }
}

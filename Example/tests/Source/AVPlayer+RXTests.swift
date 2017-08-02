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

class AVPlayerRXTests: SHMTestCase
{
    func test__status__changeToReadyToPlayWhenPlaybackStarts()
    {
        let player = createPlayer()
        
        shmwait(timeout: 3.0, action: { done in
            
            player.rx.status(options: .new)
                .subscribe(
                    onNext: { status in
                        
                        guard status == .readyToPlay else { return }
                        
                        done()
                    }
                )
                .disposed(by: self.bag)
            
            player.play()
        })
    }
    
    func test__rate__changeTo1WhenPlaybackStarts()
    {
        let player = createPlayer()
        
        shmwait(timeout: 3.0, action: { done in
            
            player.rx.rate(options: .new)
                .subscribe(
                    onNext: { rate in
                        
                        guard rate == 1.0 else { return }
                        
                        done()
                    }
                )
                .disposed(by: self.bag)
            
            player.play()
        })
    }
    
    func test__paused__reportFalseWhenPlaybackStarts()
    {
        let player = createPlayer()
        
        shmwait(timeout: 3.0, action: { done in
            
            player.rx.paused(options: .new)
                .subscribe(
                    onNext: { paused in
                        
                        guard !paused else { return }
                        
                        done()
                    }
                )
                .disposed(by: self.bag)
            
            player.play()
        })
    }
    
    func test__pausedIsTrue__whenPlaybackPause()
    {
        let player = createPlayer()
        
        shmwait(timeout: 3.0, action: { done in
            
            var shouldBePaused = false
            
            player.rx.playbackPosition(updateInterval: 0.1, updateQueue: nil)
                .subscribe(
                    onNext: { position in
                    
                        guard position > 0.0 && !shouldBePaused else { return }
                        
                        shouldBePaused = true
                        player.pause()
                    }
                )
                .disposed(by: self.bag)
            
            
            player.rx.paused(options: .new)
                .subscribe(
                    onNext: { paused in
                        
                        guard shouldBePaused else { return }
                        
                        expect(paused) == true
                        done()
                    }
                )
                .disposed(by: self.bag)
            
            player.play()
        })
    }
    
    func test__playbackPosition__changeWhenPlaybackStarts()
    {
        let player = createPlayer()
        
        shmwait(timeout: 3.0, action: { done in
            
            player.rx.playbackPosition(updateInterval: 0.1, updateQueue: nil)
                .subscribe(
                    onNext: { position in
                        
                        guard position > 0.0 else { return }
                        
                        done()
                    }
                )
                .disposed(by: self.bag)
            
            player.play()
        })
    }
    
    func test__externalPlaybackActive__shouldChangeWhenPlayerConnectToAirPlay()
    {
        //dont know how to do this yet
    }
}

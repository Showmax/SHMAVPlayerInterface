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

import Foundation
import AVFoundation

import XCTest
import Nimble
import RxSwift
import RxBlocking
import SHMAVPlayerInterface

class AVPlayerItemRXTests: SHMTestCase
{
    func test__twoSameSHMPlayerItemBufferStatuses__areEqual()
    {
        let status1 = AVPlayerItem.SHMPlayerItemBufferStatus(bufferEmpty: true, bufferFull: false)
        let status2 = AVPlayerItem.SHMPlayerItemBufferStatus(bufferEmpty: true, bufferFull: false)
        
        expect(status1) == status2
    }
    
    func test__twoDifferentSHMPlayerItemBufferStatuses__areNotEqual()
    {
        let status1 = AVPlayerItem.SHMPlayerItemBufferStatus(bufferEmpty: true, bufferFull: false)
        let status2 = AVPlayerItem.SHMPlayerItemBufferStatus(bufferEmpty: true, bufferFull: true)
        
        expect(status1) != status2
    }
    
    
    func test__playbackFinished__isSignaledWhenPlaybackFinish()
    {
        let (player, playerInterface) = createPlayerAndInterface()
        
        shmwait(timeout: 5.0, action: { done in
            
            var seeked = false
            player.currentItem?.rx.status(options: .new)
                .subscribe(
                    onNext: { status in
                        
                        guard status == .readyToPlay && !seeked else { return }
                        
                        guard let duration = playerInterface.duration else
                        {
                            XCTFail("Can't read duration of testing asset.")
                            done()
                            return
                        }
                        
                        seeked = true
                        
                        // when player is ready then we seek to almost and and wait for end notification
                        playerInterface.seek(to: duration - 1.0, toleranceBefore: 0.0, toleranceAfter: 0.0, cancelPendingSeeks: true)
                    }
                )
                .disposed(by: self.bag)
            
            player.currentItem?.rx.playbackFinished
                .subscribe(
                    onNext: { _ in
                        
                        done()
                    }
                )
                .disposed(by: self.bag)
            
            player.play()
        })
    }
    
    func test__accessLogEvent__arrivesWhenPlayerLoadChunks()
    {
        let player = createPlayer()
        
        shmwait(timeout: 3.0, action: { done in
            
            var eventArrived = false
            player.currentItem?.rx.accessLogEvent
                .subscribe(
                    onNext: { _ in
                        
                        guard !eventArrived else { return }
                        
                        eventArrived = true
                        done()
                    }
                )
                .disposed(by: self.bag)
            
            player.play()
        })
    }
    
    func test__errorLogEvent__arrivesWhenThereIsSomeErrorDuringPlayback()
    {
        //how to cause error
    }
    
    func test__status__changeToReadyToPlayWhenPlaybackStarts()
    {
        let player = createPlayer()
        
        shmwait(timeout: 3.0, action: { done in
            
            player.currentItem?.rx.status(options: .new)
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
    
    func test__playbackBufferEmpty__changeToFalseWhenPlaybackStarts()
    {
        let player = createPlayer()
        
        shmwait(timeout: 3.0, action: { done in
            
            player.currentItem?.rx.playbackBufferEmpty(options: .new)
                .subscribe(
                    onNext: { bufferEmpty in
                        
                        guard player.status == .readyToPlay else { return }
                        
                        expect(bufferEmpty) == false
                        done()
                    }
                )
                .disposed(by: self.bag)
            
            player.play()
        })
    }
    
    func test__playbackBufferFull__changeToTrueWhenBufferIsFull()
    {
        //how to cause full buffer?
    }
    
    func test__bufferStatus__changeWhenEmptyBufferChangeOrFullBufferChange()
    {
        let player = createPlayer()
        
        shmwait(timeout: 3.0, action: { done in
            
            player.currentItem?.rx.bufferStatus(options: .new)
                .subscribe(
                    onNext: { bufferStatus in
                        
                        guard player.status == .readyToPlay else { return }
                        
                        //we can be sure that buffer is not empty when item is ready to play
                        expect(bufferStatus.bufferEmpty) == false
                        
                        done()
                    }
                )
                .disposed(by: self.bag)
            
            player.play()
        })
    }
}

//
//  AVPlayerItem+RXTests.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 23/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation

import Foundation
import AVFoundation

import XCTest
import Nimble
import RxSwift
import RxBlocking

class AVPlayerItemRXTests: SHMTestCase
{
    func test__playbackFinished__isSignaledWhenPlaybackFinish()
    {
        let player = createPlayer()
        let playerInterface = SHMAVPlayerInterface(player: player)
        
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
                        
                        print("Duration \(duration)")
                        
                        print("Seek to duration \(duration - 1.0)")
                        
                        seeked = true
                        playerInterface.seek(to: duration - 1.0, toleranceBefore: 0.0, toleranceAfter: 0.0, cancelPendingSeeks: true, completionHandler: { finished in
                            
                            print("Seek finished \(finished)")
                            print("Location \(playerInterface.playbackPosition)")
                        })
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
}

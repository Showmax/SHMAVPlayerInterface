//
//  SHMAVPlayerInterfaceTests.swift
//  SHMAVPlayerInterface
//
//  Created by Michal Fousek on 11/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import AVFoundation

import XCTest
import Nimble
import RxSwift
import RxBlocking

class SHMAVPlayerInterfaceTests: SHMTestCase
{
    func test__duration__isNilBeforePlayerIsReadyToPlay()
    {
        let (_, playerInterface) = createPlayerAndInterface()
        
        expect(playerInterface.duration).to(beNil())
    }
    
    func test__duration__isSameAsAssetDurationAfterPlayerIsReady()
    {
        let (player, playerInterface) = createPlayerAndInterface()
        
        shmwait(timeout: 3.0, action: { done in
            
            player.currentItem?.rx.status(options: .new)
                .subscribe(
                    onNext: { status in
                        
                        guard status == .readyToPlay else { return }
                        
                        expect(playerInterface.duration) == kBipBopDuration
                        done()
                    }
                )
                .disposed(by: self.bag)
            
            player.play()
        })
    }
    
    func test__playbackIsProbablyStalled__playbackIsStalledBeforeItStarts()
    {
        let (_, playerInterface) = createPlayerAndInterface()
        
        expect(playerInterface.playbackProbablyStalled) == true
    }
    
    func test__play__playbackShoudlStart()
    {
        let (player, playerInterface) = createPlayerAndInterface()
        
        shmwait(timeout: 3.0, action: { done in
            
            var playbackStarted = false
            player.rx.rate(options: .new)
                .subscribe(
                    onNext: { rate in
                        
                        guard rate >= 1.0 && !playbackStarted else { return }
                        
                        playbackStarted = true
                        done()
                    }
                )
                .disposed(by: self.bag)
            
            playerInterface.play()
        })
    }
    
    
    func test__pause__pausePlayback()
    {
        let (player, playerInterface) = createPlayerAndInterface()
        
        shmwait(timeout: 3.0, action: { done in
            
            var shouldBePaused = false
            player.rx.playbackPosition(updateInterval: 0.1, updateQueue: nil)
                .subscribe(
                    onNext: { position in
                        
                        guard position > 0.0 && !shouldBePaused else { return }
                        
                        shouldBePaused = true
                        playerInterface.pause()
                        
                        expect(player.rate) == 0.0
                        done()
                    }
                )
                .disposed(by: self.bag)
            
            player.play()
        })
    }
    
    func test__seek__shouldSeekToSpecificPosition()
    {
        let (player, playerInterface) = createPlayerAndInterface()
        
        shmwait(timeout: 3.0, action: { done in
            
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
                        
                        player.pause()
                        seeked = true
                        
                        playerInterface.seek(
                            to: duration - 1.0,
                            toleranceBefore: 0.0,
                            toleranceAfter: 0.0,
                            cancelPendingSeeks: true,
                            completionHandler: { _ in
                                
                                expect(playerInterface.playbackPosition) == kBipBopDuration - 1.0
                                done()
                        })
                    }
                )
                .disposed(by: self.bag)
            
            player.play()
        })
    }
    
//    func test__availableSubtitles__shouldBeAsInAsset()
//    {
//        let (player, playerInterface) = createPlayerAndInterface()
//        
//        let languages = playerInterface.availableSubtitles.map({ ($0.languageCode, $0.forced) }).sor
//        
//        print(languages)
//    }
}

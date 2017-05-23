//
//  AVPlayer+RXTests.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 23/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import AVFoundation

import XCTest
import Nimble
import RxSwift
import RxBlocking

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

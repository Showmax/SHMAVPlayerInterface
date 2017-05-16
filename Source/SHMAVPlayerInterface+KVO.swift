//
//  SHMAVPlayerInterface+KVO.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 16/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import AVFoundation

import RxSwift
import RxCocoa

extension SHMAVPlayerInterface
{
    func setupAllKVOObservers()
    {
        observePlayersRate()
        observePlayersExternalPlaybackActive()
        observePlayersStatus()
        observePlayerItemsBufferStatus()
        observePlayersStatus()
    }
    
    func observePlayersRate()
    {
        guard configuration.observeProperties.contains(.playbackPaused) else { return }
        
        player.rx.observe(Float.self, "rate", options: .new, retainSelf: false)
            .ignoreNil()
            .map({ rate in
                
                let paused = rate > 0.0 ? false : true
                return (paused: paused, rate: rate)
            })
            .bind(to: playbackPausedSubject)
            .disposed(by: observingContext.observersBag)
    }
    
    func observePlayersExternalPlaybackActive()
    {
        guard configuration.observeProperties.contains(.externalPlayback) else { return }
        
        player.rx.observe(Bool.self, "externalPlaybackActive", options: .new, retainSelf: false)
            .ignoreNil()
            .bind(to: externalPlaybackSubject)
            .disposed(by: observingContext.observersBag)
    }
    
    func observePlayersStatus()
    {
        guard configuration.observeProperties.contains(.playerStatus) else { return }
        
        player.rx.observe(AVPlayerStatus.self, "status", options: .new, retainSelf: false)
            .ignoreNil()
            .bind(to: playerStatusSubject)
            .disposed(by: observingContext.observersBag)
    }
    
    func observePlayerItemsBufferStatus()
    {
        guard configuration.observeProperties.contains(.playerBufferStatus), let item = player.currentItem else { return }
        
        let bufferEmptyObservable = item.rx.observe(Bool.self, "playbackBufferEmpty", options: .new, retainSelf: false)
            .ignoreNil()
            
        let bufferFullObservable = item.rx.observe(Bool.self, "playbackBufferFull", options: .new, retainSelf: false)
            .ignoreNil()
        
        Observable.merge(bufferEmptyObservable, bufferFullObservable)
            .map({[weak self] _ -> PlayerItemBufferStatus? in
                
                guard let item = self?.player.currentItem else { return nil }
                
                return PlayerItemBufferStatus(bufferEmpty: item.isPlaybackBufferEmpty, bufferFull: item.isPlaybackBufferFull)
            })
            .ignoreNil()
            .bind(to: playerBufferStatusSubject)
            .disposed(by: observingContext.observersBag)
    }
    
    func observePlayerItemsStatus()
    {
        guard configuration.observeProperties.contains(.playerItemStatus), let item = player.currentItem else { return }
        
        item.rx.observe(AVPlayerItemStatus.self, "status", options: .new, retainSelf: false)
            .ignoreNil()
            .bind(to: playerItemStatusSubject)
            .disposed(by: observingContext.observersBag)
    }
}

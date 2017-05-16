//
//  SHMAVPlayerInterface+Observables.swift
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
    func observePlayerStatus(options: ObservingOptions) -> Observable<AVPlayerStatus>
    {
        return player.rx.observe(AVPlayerStatus.self, "status", options: options.keyValuesObservingOptions, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    func observePlayerItemStatus(options: ObservingOptions) -> Observable<AVPlayerItemStatus>
    {
        assert(player.currentItem != nil, "You have to set player's item first!")
        guard let item = player.currentItem else { return Observable<AVPlayerItemStatus>.empty() }
        
        return item.rx.observe(AVPlayerItemStatus.self, "status", options: options.keyValuesObservingOptions, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    func observePlayerItemBufferStatus(options: ObservingOptions) -> Observable<PlayerItemBufferStatus>
    {
        assert(player.currentItem != nil, "You have to set player's item first!")
        guard let item = player.currentItem else { return Observable<PlayerItemBufferStatus>.empty() }
        
        let bufferEmptyObservable = item.rx.observe(
            Bool.self,
            "playbackBufferEmpty",
            options: options.keyValuesObservingOptions,
            retainSelf: false
        )
        
        let bufferFullObservable = item.rx.observe(
            Bool.self,
            "playbackBufferFull",
            options: options.keyValuesObservingOptions,
            retainSelf: false
        )
        
        return Observable.merge(bufferEmptyObservable.ignoreNil(), bufferFullObservable.ignoreNil())
            .map({[weak item] _ -> PlayerItemBufferStatus?  in
                
                guard let item = item else { return nil }
                
                return PlayerItemBufferStatus(bufferEmpty: item.isPlaybackBufferEmpty, bufferFull: item.isPlaybackBufferFull)
            })
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    func observePlaybackFinished() -> Observable<Void>
    {
        return NotificationCenter.default.rx.notification(.AVPlayerItemDidPlayToEndTime)
            .map({ _ in Void() })
    }
    
    func observePlaybackPaused(options: ObservingOptions) -> Observable<(paused: Bool, rate: Float)>
    {
        return player.rx.observe(Float.self, "rate", options: options.keyValuesObservingOptions, retainSelf: false)
            .ignoreNil()
            .map({ rate in
                
                let paused = rate > 0.0 ? false : true
                return (paused: paused, rate: rate)
            })
            .distinctUntilChanged({ (v1: (paused: Bool, rate: Float), v2: (paused: Bool, rate: Float)) in
                
                return v1.paused == v2.paused && v1.rate == v2.rate
            })
    }
    
    func observePlaybackPosition(updateInterval: TimeInterval, updateQueue: DispatchQueue?) -> Observable<TimeInterval>
    {
        return Observable.create({[weak player] observer in
            
            guard let player = player else
            {
                observer.onCompleted()
                return Disposables.create()
            }
            
            let intervalTime = CMTime(seconds: updateInterval, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            let obj = player.addPeriodicTimeObserver(
                forInterval: intervalTime,
                queue: updateQueue,
                using: { positionTime in
                    
                    let position = CMTimeGetSeconds(positionTime)
                    
                    observer.onNext(position)
            })
            
            return Disposables.create
            {
                player.removeTimeObserver(obj)
            }
        })
    }
    
    func observeExternalPlaybackActive(options: ObservingOptions) -> Observable<Bool>
    {
        return player.rx.observe(Bool.self, "externalPlaybackActive", options: options.keyValuesObservingOptions, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    func observeAccessLog() -> Observable<AVPlayerItemAccessLogEvent>
    {
        return NotificationCenter.default.rx.notification(.AVPlayerItemNewAccessLogEntry)
            .map({[weak self] _ -> AVPlayerItemAccessLogEvent? in
                
                return self?.player.currentItem?.accessLog()?.events.last
            })
            .ignoreNil()
    }
    
    
    func observeErrorLog() -> Observable<AVPlayerItemErrorLogEvent>
    {
        return NotificationCenter.default.rx.notification(.AVPlayerItemNewErrorLogEntry)
            .map({[weak self] _ -> AVPlayerItemErrorLogEvent? in
                
                return self?.player.currentItem?.errorLog()?.events.last
            })
            .ignoreNil()
    }
}

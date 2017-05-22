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

extension Reactive where Base: AVPlayer
{
    public var playbackFinished: Observable<Void>
    {
        return NotificationCenter.default.rx.notification(.AVPlayerItemDidPlayToEndTime)
            .map({ _ in Void() })
    }
    
    public func status(options: NSKeyValueObservingOptions) -> Observable<AVPlayerStatus>
    {
        return base.rx.observe(AVPlayerStatus.self, "status", options: options, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    public func rate(options: NSKeyValueObservingOptions) -> Observable<Float>
    {
        return base.rx.observe(Float.self, "rate", options: options, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    public func paused(options: NSKeyValueObservingOptions) -> Observable<Bool>
    {
        return base.rx.rate(options: options)
            .map({ $0 > 0.0 })
    }
    
    public func playbackPosition(updateInterval: TimeInterval, updateQueue: DispatchQueue?) -> Observable<TimeInterval>
    {
        return Observable.create({[weak base] observer in
            
            guard let player = base else
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
    
    public func externalPlaybackActive(options: NSKeyValueObservingOptions) -> Observable<Bool>
    {
        return base.rx.observe(Bool.self, "externalPlaybackActive", options: options, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    
}

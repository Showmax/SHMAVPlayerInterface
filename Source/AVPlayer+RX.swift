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
    /// Create observable which will emitt `AVPlayerStatus` every time player's status change. Only distinct values will be emitted.
    ///
    /// - Parameter options: Observing options which determine the values that are returned. These options are passed to KVO method.
    /// - Returns: Observable which emitt player's status every time it change.
    public func status(options: NSKeyValueObservingOptions) -> Observable<AVPlayerStatus>
    {
        return base.rx.observe(AVPlayerStatus.self, "status", options: options, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    /// Create observable which will emitt `Float` every time player's rate change. Only distinct values will be emitted.
    ///
    /// - Parameter options: Observing options which determine the values that are returned. These options are passed to KVO method.
    /// - Returns: Observable which emitt player's rate every time it change.
    public func rate(options: NSKeyValueObservingOptions) -> Observable<Float>
    {
        return base.rx.observe(Float.self, "rate", options: options, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    
    /// Create observable which will emitt `Bool` every time player's rate change. Only distinct values will be emitted.
    /// If rate is <= 0.0 then this will emitt `true`.
    ///
    /// - Parameter options: Observing options which determine the values that are returned. These options are passed to KVO method.
    /// - Returns: Observable which emitt paused state every time player's rate change.
    public func paused(options: NSKeyValueObservingOptions) -> Observable<Bool>
    {
        return base.rx.rate(options: options)
            .map({ $0 <= 0.0 })
            .distinctUntilChanged()
    }
    
    /// Create observable which will emitt playback position.
    ///
    /// - Parameters:
    ///   - updateInterval: Interval in which is position updated.
    ///   - updateQueue: Queue which is used to update position. If this is set to `nil` then updates are done on main queue.
    /// - Returns: Observable which will emitt playback position.
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
                    
                    observer.onNext(positionTime.seconds)
            })
            
            return Disposables.create
            {
                player.removeTimeObserver(obj)
            }
        })
    }
    
    /// Create observable which will emitt `Bool` every time player's externalPlaybackActive change. Only distinct values will be emitted.
    ///
    /// - Parameter options: Observing options which determine the values that are returned. These options are passed to KVO method.
    /// - Returns: Observable which emitt player's externalPlaybackActive every time it change.
    public func externalPlaybackActive(options: NSKeyValueObservingOptions) -> Observable<Bool>
    {
        return base.rx.observe(Bool.self, "externalPlaybackActive", options: options, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    
}

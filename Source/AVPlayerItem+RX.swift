//
//  AVPlayerItem+RX.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 22/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import AVFoundation

import RxSwift
import RxCocoa

extension AVPlayerItem
{
    public struct SHMPlayerItemBufferStatus
    {
        let bufferEmpty: Bool
        let bufferFull: Bool
    }
}

extension AVPlayerItem.SHMPlayerItemBufferStatus: Equatable {}
public func == (lhs: AVPlayerItem.SHMPlayerItemBufferStatus, rhs: AVPlayerItem.SHMPlayerItemBufferStatus) -> Bool
{
    return lhs.bufferEmpty == rhs.bufferEmpty && lhs.bufferFull == rhs.bufferFull
}

extension Reactive where Base: AVPlayerItem
{
    public var accessLogEvent: Observable<AVPlayerItemAccessLogEvent>
    {
        return NotificationCenter.default.rx.notification(.AVPlayerItemNewAccessLogEntry)
            .map({[weak base] _ -> AVPlayerItemAccessLogEvent? in
                
                return base?.accessLog()?.events.last
            })
            .ignoreNil()
    }
    
    public var errorLogEvent: Observable<AVPlayerItemErrorLogEvent>
    {
        return NotificationCenter.default.rx.notification(.AVPlayerItemNewErrorLogEntry)
            .map({[weak base] _ -> AVPlayerItemErrorLogEvent? in
                
                return base?.errorLog()?.events.last
            })
            .ignoreNil()

    }
    
    public func status(options: NSKeyValueObservingOptions) -> Observable<AVPlayerItemStatus>
    {
        return base.rx.observe(AVPlayerItemStatus.self, "status", options: options, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    public func playbackBufferEmpty(options: NSKeyValueObservingOptions) -> Observable<Bool>
    {
        return base.rx.observe(Bool.self, "playbackBufferEmpty", options: options, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    public func playbackBufferFull(options: NSKeyValueObservingOptions) -> Observable<Bool>
    {
        return base.rx.observe(Bool.self, "playbackBufferFull", options: options, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    public func bufferStatus(options: NSKeyValueObservingOptions) -> Observable<AVPlayerItem.SHMPlayerItemBufferStatus>
    {
        let bufferEmptyObservable = base.rx.playbackBufferEmpty(options: options)
        let bufferFullObservable = base.rx.playbackBufferFull(options: options)
        
        return Observable.merge(bufferEmptyObservable, bufferFullObservable)
            .map({[weak base] _ -> AVPlayerItem.SHMPlayerItemBufferStatus? in
                
                guard let base = base else { return nil }
                
                return AVPlayerItem.SHMPlayerItemBufferStatus(bufferEmpty: base.isPlaybackBufferEmpty, bufferFull: base.isPlaybackBufferFull)
            })
            .ignoreNil()
            .distinctUntilChanged()
    }
}

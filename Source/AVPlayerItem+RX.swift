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

import RxSwift
import RxCocoa

extension AVPlayerItem {
    /// Structure used to provide informations about player item's current status.
    public struct SHMPlayerItemBufferStatus: Equatable {
        public let bufferEmpty: Bool
        public let bufferFull: Bool
        
        public init(bufferEmpty: Bool, bufferFull: Bool) {
            self.bufferEmpty = bufferEmpty
            self.bufferFull = bufferFull
        }
        
        public static func == (lhs: AVPlayerItem.SHMPlayerItemBufferStatus, rhs: AVPlayerItem.SHMPlayerItemBufferStatus) -> Bool {
            return lhs.bufferEmpty == rhs.bufferEmpty && lhs.bufferFull == rhs.bufferFull
        }
    }
}

extension Reactive where Base: AVPlayerItem {
    /// Create observable which emitt `completed` signal when this item has played to its end time.
    public var playbackFinished: Observable<Void> {
        return NotificationCenter.default.rx.notification(.AVPlayerItemDidPlayToEndTime, object: base)
            .map({ _ in Void() })
    }
    
    /// Create observable which will emitt `AVPlayerItemAccessLogEvent` every time new event will be added to `AVPlayerItem`'s access log.
    public var accessLogEvent: Observable<AVPlayerItemAccessLogEvent> {
        return NotificationCenter.default.rx.notification(.AVPlayerItemNewAccessLogEntry)
            .map({[weak base] _ -> AVPlayerItemAccessLogEvent? in
                
                return base?.accessLog()?.events.last
            })
            .ignoreNil()
    }
    
    /// Create observable which will emitt `AVPlayerItemErrorLogEvent` every time new event will be added to `AVPlayerItem`'s error log.
    public var errorLogEvent: Observable<AVPlayerItemErrorLogEvent> {
        return NotificationCenter.default.rx.notification(.AVPlayerItemNewErrorLogEntry)
            .map({[weak base] _ -> AVPlayerItemErrorLogEvent? in
                
                return base?.errorLog()?.events.last
            })
            .ignoreNil()

    }
    
    /// Create observable which will emitt `AVPlayerItemStatus` every time player item's status change. Only distinct values will be emitted.
    ///
    /// - Parameter options: Observing options which determine the values that are returned. These options are passed to KVO method.
    /// - Returns: Observable which emitt player item's status every time it change.
    public func status(options: NSKeyValueObservingOptions) -> Observable<AVPlayerItemStatus> {
        return base.rx.observe(AVPlayerItemStatus.self, "status", options: options, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    /// Create observable which will emitt `Bool` every time player item's `playbackBufferEmpty` change. Only distinct values will be emitted.
    ///
    /// - Parameter options: Observing options which determine the values that are returned. These options are passed to KVO method.
    /// - Returns: Observable which emitt player item's `playbackBufferEmpty` every time it change.
    public func playbackBufferEmpty(options: NSKeyValueObservingOptions) -> Observable<Bool> {
        return base.rx.observe(Bool.self, "playbackBufferEmpty", options: options, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    /// Create observable which will emitt `Bool` every time player item's `playbackBufferFull` change. Only distinct values will be emitted.
    ///
    /// - Parameter options: Observing options which determine the values that are returned. These options are passed to KVO method.
    /// - Returns: Observable which emitt player item's `playbackBufferFull` every time it change.
    public func playbackBufferFull(options: NSKeyValueObservingOptions) -> Observable<Bool> {
        return base.rx.observe(Bool.self, "playbackBufferFull", options: options, retainSelf: false)
            .ignoreNil()
            .distinctUntilChanged()
    }
    
    /// Create observable which will emitt `AVPlayerItem.SHMPlayerItemBufferStatus` every time player item's `playbackBufferEmpty` or
    /// `playbackBufferFull` change.
    ///
    /// - Parameter options: Observing options which determine the values that are returned. These options are passed to KVO method.
    /// - Returns: Observable which emitt `AVPlayerItem.SHMPlayerItemBufferStatus` every time player item's `playbackBufferEmpty` or
    ///            `playbackBufferFull` change.
    public func bufferStatus(options: NSKeyValueObservingOptions) -> Observable<AVPlayerItem.SHMPlayerItemBufferStatus> {
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

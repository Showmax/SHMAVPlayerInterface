//
//  SHMAVPlayerInterface+Types.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 16/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import AVFoundation

extension SHMAVPlayerInterface
{
    public typealias PlayerItemBufferStatus = (bufferEmpty: Bool, bufferFull: Bool)
    
    public struct ObserveProperties: OptionSet
    {
        public let rawValue: Int
        
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        public static let playerStatus = ObserveProperties(rawValue: 1 << 0)
        public static let playerItemStatus = ObserveProperties(rawValue: 1 << 1)
        public static let playerBufferStatus = ObserveProperties(rawValue: 1 << 2)
        public static let playbackFinished = ObserveProperties(rawValue: 1 << 3)
        public static let playbackPaused = ObserveProperties(rawValue: 1 << 4)
        public static let playbackPosition = ObserveProperties(rawValue: 1 << 5)
        public static let playbackStall = ObserveProperties(rawValue: 1 << 6)
        public static let externalPlayback = ObserveProperties(rawValue: 1 << 7)
        public static let accessLogEvent = ObserveProperties(rawValue: 1 << 8)
        public static let errorLogEvent = ObserveProperties(rawValue: 1 << 9)
    }
    
    public struct Configuration
    {
        let observeProperties: ObserveProperties
        
        let positionUpdateInterval: TimeInterval
        let positionUpdateQueue: DispatchQueue?
        
        static var `default`: Configuration
        {
            return Configuration(
                observeProperties: ObserveProperties(rawValue: 0),
                positionUpdateInterval: 0.2,
                positionUpdateQueue: nil
            )
        }
    }
    
    public struct Subtitle
    {
        let languageCode: String
        let forced: Bool
        let option: AVMediaSelectionOption
    }
    
    public struct AudioTrack
    {
        let languageCode: String
        let option: AVMediaSelectionOption
    }

}

extension SHMAVPlayerInterface
{
    struct ObservingContext
    {
        var pathsObservedForPlayer: [String]
        var pathsObservedForItem: [String]
        var periodicTimeObserver: Any?
        var playbackReachedEndNotificationObserver: NSObjectProtocol?
        var newAccessLogEventNotificationObserver: NSObjectProtocol?
        var newErrorLogEventNotificationObserver: NSObjectProtocol?
        
        static var empty: ObservingContext
        {
            return ObservingContext(
                pathsObservedForPlayer: [],
                pathsObservedForItem: [],
                periodicTimeObserver: nil,
                playbackReachedEndNotificationObserver: nil,
                newAccessLogEventNotificationObserver: nil,
                newErrorLogEventNotificationObserver: nil
            )
        }
    }

}

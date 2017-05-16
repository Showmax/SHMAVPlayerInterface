//
//  SHMAVPlayerInterface.swift
//  SHMAVPlayerInterface
//
//  Created by Michal Fousek on 11/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import AVFoundation

import RxSwift

extension SHMAVPlayerInterface
{
    struct ObserveProperties: OptionSet
    {
        let rawValue: Int
        
        static let playerStatus = ObserveProperties(rawValue: 1 << 0)
        static let playerItemStatus = ObserveProperties(rawValue: 1 << 1)
        static let playerBufferStatus = ObserveProperties(rawValue: 1 << 2)
        static let playbackFinished = ObserveProperties(rawValue: 1 << 3)
        static let playbackPaused = ObserveProperties(rawValue: 1 << 4)
        static let playbackPosition = ObserveProperties(rawValue: 1 << 5)
        static let playbackStall = ObserveProperties(rawValue: 1 << 6)
        static let externalPlayback = ObserveProperties(rawValue: 1 << 7)
        static let accessLogEvent = ObserveProperties(rawValue: 1 << 8)
        static let errorLogEvent = ObserveProperties(rawValue: 1 << 9)
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
}

extension SHMAVPlayerInterface
{
    public struct Subtitle
    {
        let languageCode: String
        let forced: Bool
        let option: AVMediaSelectionOption
    }
}

extension SHMAVPlayerInterface
{
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

extension SHMAVPlayerInterface
{
    public typealias PlayerItemBufferStatus = (bufferEmpty: Bool, bufferFull: Bool)
}

extension SHMAVPlayerInterface
{
    public var playerStatusObservable: Observable<AVPlayerStatus> { return playerStatusSubject.asObservable() }
    public var playerItemStatusObservable: Observable<AVPlayerStatus> { return playerItemStatusSubject.asObservable() }
    public var playerBufferStatusObservable: Observable<PlayerItemBufferStatus> { return playerBufferStatusSubject.asObservable() }
    public var playbackFinishedObservable: Observable<Void> { return playbackFinishedSubject.asObservable() }
    public var playbackPausedObservable: Observable<Bool> { return playbackPausedSubject.asObservable() }
    public var playbackPositionObservable: Observable<TimeInterval> { return playbackPositionSubject.asObservable() }
    public var externalPlaybackObservable: Observable<Bool> { return externalPlaybackSubject.asObservable() }
    public var newAccessLogEventObservable: Observable<AVPlayerItemAccessLogEvent> { return newAccessLogEventSubject.asObservable() }
    public var newErrorLogEventObservable: Observable<AVPlayerItemErrorLogEvent> { return newErrorLogEventSubject.asObservable() }
}

public class SHMAVPlayerInterface: NSObject
{
    public let              player: AVPlayer
    var                     configuration: Configuration
    
    public private(set) var seeking: Bool
    
    var                     observingContext: ObservingContext
    
    lazy var                playerStatusSubject: PublishSubject<AVPlayerStatus> =
    {
        return PublishSubject<AVPlayerStatus>()
    }()
    
    lazy var                playerItemStatusSubject: PublishSubject<AVPlayerStatus> =
    {
        return PublishSubject<AVPlayerStatus>()
    }()

    lazy var                playerBufferStatusSubject: PublishSubject<PlayerItemBufferStatus> =
    {
        return PublishSubject<PlayerItemBufferStatus>()
    }()

    lazy var                playbackFinishedSubject: PublishSubject<Void> =
    {
        return PublishSubject<Void>()
    }()

    lazy var                playbackPausedSubject: PublishSubject<Bool> =
    {
        return PublishSubject<Bool>()
    }()

    lazy var                playbackPositionSubject: PublishSubject<TimeInterval> =
    {
        return PublishSubject<TimeInterval>()
    }()

    lazy var                externalPlaybackSubject: PublishSubject<Bool> =
    {
        return PublishSubject<Bool>()
    }()

    lazy var                newAccessLogEventSubject: PublishSubject<AVPlayerItemAccessLogEvent> =
    {
        return PublishSubject<AVPlayerItemAccessLogEvent>()
    }()

    lazy var                newErrorLogEventSubject: PublishSubject<AVPlayerItemErrorLogEvent> =
    {
        return PublishSubject<AVPlayerItemErrorLogEvent>()
    }()

    
    public init(player: AVPlayer)
    {
        self.player = player
        
        seeking = false
        configuration = Configuration.default
        observingContext = ObservingContext.empty
    }
    
    deinit
    {
        cancelAllObservers()
    }
    
    // MARK: - Public API
    
    public var duration: TimeInterval?
    {
        guard let item = player.currentItem else { return nil }
        
        return CMTimeGetSeconds(item.duration)
    }
    
    public var playbackPosition: TimeInterval
    {
        return CMTimeGetSeconds(player.currentTime())
    }
    
    public var availableSubtitles: [Subtitle]
    {
        guard let subtitlesGroup = player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicLegible) else
        {
            return []
        }
        
        let subtitles = subtitlesGroup.options.flatMap({ option -> Subtitle? in
            
            guard let languageCode = option.extendedLanguageTag else { return nil }
            let forced = option.hasMediaCharacteristic(AVMediaCharacteristicContainsOnlyForcedSubtitles)
            
            return Subtitle(languageCode: languageCode, forced: forced, option: option)
        })
        
        return subtitles
    }
    
    public var selectedSubtitle: Subtitle?
    {
        guard let item = player.currentItem else { return nil }
        guard let subtitlesGroup = item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicLegible) else { return nil }
        
        guard   let selectedOption = item.selectedMediaOption(in: subtitlesGroup),
                let languageCode = selectedOption.extendedLanguageTag
                else
        {
            return nil
        }
        
        return Subtitle(
            languageCode: languageCode,
            forced: selectedOption.hasMediaCharacteristic(AVMediaCharacteristicContainsOnlyForcedSubtitles),
            option: selectedOption
        )
    }
    
    public var availableAudioTracks: [AudioTrack]
    {
        guard let audioGroup = player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicAudible) else
        {
            return []
        }
        
        let audioTracks = audioGroup.options.flatMap({ option -> AudioTrack? in
            
            guard let languageCode = option.extendedLanguageTag else { return nil }
            
            return AudioTrack(languageCode: languageCode, option: option)
        })
        
        return audioTracks
    }
    
    public var selectedAudioTrack: AudioTrack?
    {
        guard let item = player.currentItem else { return nil }
        guard let audioGroup = item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicAudible) else { return nil }
        
        guard   let selectedOption = item.selectedMediaOption(in: audioGroup),
                let languageCode = selectedOption.extendedLanguageTag
                else
        {
            return nil
        }
        
        return AudioTrack(
            languageCode: languageCode,
            option: selectedOption
        )
    }
    
    public var pausedByUser: Bool
    {
        return paused && !probablyStalled
    }
    
    public var paused: Bool
    {
        return player.rate == 0.0
    }
    
    public var probablyStalled: Bool
    {
        return paused && !seeking && (player.currentItem?.isPlaybackBufferEmpty ?? false)
    }
    
    public var error: Error?
    {
        return player.error ?? player.currentItem?.error
    }
    
    public func set(playerItem: AVPlayerItem?, configuration: Configuration)
    {
        cancelAllObservers()
        
        self.configuration = configuration
        
        player.replaceCurrentItem(with: playerItem)
        
        prepareAllObservers()
    }
    
    public func play()
    {
        player.play()
    }
    
    public func pause()
    {
        player.pause()
    }
    
    public func seek(
        to position: TimeInterval,
        toleranceBefore: TimeInterval = 0.0,
        toleranceAfter: TimeInterval = 0.0,
        completionHandler: ((Bool) -> Void)? = nil
    )
    {
        player.currentItem?.cancelPendingSeeks()
        
        seeking = true
        
        let seekTime = CMTime(seconds: position, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let toleranceBeforeTime = CMTime(seconds: toleranceBefore, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let toleranceAfterTime = CMTime(seconds: toleranceAfter, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        seeking = true
        player.seek(
            to: seekTime,
            toleranceBefore: toleranceBeforeTime,
            toleranceAfter: toleranceAfterTime,
            completionHandler: {[weak self] finished in
            
                completionHandler?(finished)
            
                self?.seeking = false
        })
    }
    
    public func select(subtitle: Subtitle?)
    {
        guard let item = player.currentItem else { return }
        guard let subtitlesGroup = item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicLegible) else { return }
        
        item.select(subtitle?.option, in: subtitlesGroup)
    }
    
    public func select(audioTrack: AudioTrack)
    {
        guard let item = player.currentItem else { return }
        guard let audioGroup = item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicAudible) else { return }
        
        item.select(audioTrack.option, in: audioGroup)
    }
    
    // MARK: - Internal API
    
    func cancelAllObservers()
    {
        removeAllPlayerTimeObservers()
        removeAllKVOObservers()
        
        observingContext = ObservingContext.empty
    }
    
    func prepareAllObservers()
    {
        setupPlayerTimeObservers()
        
        setupListeningForNotifications()
        
        setupPlayerKVOObservers()
        setupPlayerItemKVOObservers()
    }
    
    // MARK: - Internal API - Position observing
    
    func removeAllPlayerTimeObservers()
    {
        guard let periodicTimeObserver = observingContext.periodicTimeObserver else { return }
        
        player.removeTimeObserver(periodicTimeObserver)
    }
    
    func setupPlayerTimeObservers()
    {
        guard configuration.observeProperties.contains(.playbackPosition) else { return }
        
        let intervalTime = CMTime(seconds: configuration.positionUpdateInterval, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        observingContext.periodicTimeObserver = player.addPeriodicTimeObserver(
            forInterval: intervalTime,
            queue: configuration.positionUpdateQueue,
            using: {[weak self] positionTime in

                //call some method which should do some with new position
                
                let position = CMTimeGetSeconds(positionTime)
                
                self?.playbackPositionSubject.onNext(position)
                
        })
    }
    
    // MARK: - Internal API - Notifications
    
    func stopListeningForNotifications()
    {
        removeNotification(observer: observingContext.playbackReachedEndNotificationObserver)
        removeNotification(observer: observingContext.newAccessLogEventNotificationObserver)
        removeNotification(observer: observingContext.newErrorLogEventNotificationObserver)
    }
    
    func removeNotification(observer: NSObjectProtocol?)
    {
        if let observer = observer
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func setupListeningForNotifications()
    {
        setupListeningForPlaybackReachedToEndNotification()
        setupListeningForNewAccessLogEventNotification()
        setupListeningForNewAccessLogEventNotification()
    }
    
    func setupListeningForPlaybackReachedToEndNotification()
    {
        guard configuration.observeProperties.contains(.playbackFinished) else { return }
        
        observingContext.playbackReachedEndNotificationObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: nil,
            using: {[weak self] _ in
                
                //call some method which can handle state when playback reached end
                
                self?.playbackFinishedSubject.onNext(Void())
        })
    }
    
    func setupListeningForNewAccessLogEventNotification()
    {
        guard configuration.observeProperties.contains(.accessLogEvent) else { return }
        
        observingContext.newErrorLogEventNotificationObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemNewAccessLogEntry,
            object: nil,
            queue: nil,
            using: { _ in
            
                //call some method which can handle state when there is new acces log entry
        })
    }
    
    func setupListeningForNewErrorLogEventNotification()
    {
        guard configuration.observeProperties.contains(.errorLogEvent) else { return }
        
        observingContext.newErrorLogEventNotificationObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemNewErrorLogEntry,
            object: nil,
            queue: nil,
            using: { _ in
                
                //call some method which can handle state when there is new acces log entry
        })
    }
    

    // MARK: - Internal API - Observers
    
    func removeAllKVOObservers()
    {
        let player = self.player
        let item = player.currentItem
        
        print("PAths to remove item \(observingContext.pathsObservedForItem)")
        
        observingContext.pathsObservedForItem.forEach({ item?.removeObserver(self, forKeyPath: $0) })
        observingContext.pathsObservedForItem = []
        
        observingContext.pathsObservedForPlayer.forEach({ player.removeObserver(self, forKeyPath: $0) })
        observingContext.pathsObservedForPlayer = []
    }
    
    func createPathsToObserveForPlayer() -> [String]
    {
        var paths = ["rate"]
        
        if configuration.observeProperties.contains(.externalPlayback)
        {
            paths.append("externalPlaybackActive")
        }
        
        if configuration.observeProperties.contains(.playerStatus)
        {
            paths.append("status")
        }
        
        return paths
    }
    
    func setupPlayerKVOObservers()
    {
        observingContext.pathsObservedForPlayer = createPathsToObserveForPlayer()
        observingContext.pathsObservedForPlayer.forEach({ self.player.addObserver(self, forKeyPath: $0, options: .new, context: nil) })
    }
    
    func createPathsToObserveForItem() -> [String]
    {
        var paths: [String] = []
        
        if configuration.observeProperties.contains(.playerBufferStatus)
        {
            paths.append("playbackBufferEmpty")
            paths.append("playbackBufferFull")
        }
        
        if configuration.observeProperties.contains(.playerItemStatus)
        {
            paths.append("status")
        }
        
        return paths
    }
    
    func setupPlayerItemKVOObservers()
    {
        guard let item = player.currentItem else { return }
        
        observingContext.pathsObservedForItem = createPathsToObserveForItem()
        observingContext.pathsObservedForItem.forEach({ item.addObserver(self, forKeyPath: $0, options: .new, context: nil) })
        
        print("Paths for item \(observingContext.pathsObservedForItem)")
    }
    
    
    // MARK: - KVO
    
    // =====================================================
    override public func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?)
    {
        guard let path = keyPath else { return }
        
        switch path
        {
        case "playbackBufferEmpty":
            let info: PlayerItemBufferStatus = (
                bufferEmpty: player.currentItem?.isPlaybackBufferEmpty ?? true,
                bufferFull: player.currentItem?.isPlaybackBufferFull ?? false
            )
            
            playerBufferStatusSubject.onNext(info)
            
        case "status":
            guard   let observedObject = object as? AnyClass,
                    let changed = change,
                    let changedStatus = changed[NSKeyValueChangeKey.newKey] as? NSNumber,
                    let status = AVPlayerStatus(rawValue: changedStatus.intValue) else
            {
                print("No status")
                
                return
            }
            
            if observedObject === player
            {
                playerStatusSubject.onNext(status)
                
            } else if let item = player.currentItem, observedObject === item
            {
                playerItemStatusSubject.onNext(status)
            }
            
        default:
            break
        }
        
//        guard let path = keyPath else { return }
        
//        switch path
//        {
//        case "rate":
//            handle(players: player, rateChange: change)
//            
//        case "status":
//            handle(players: player, statusChange: change, withSource: source)
//            
//        case "playbackBufferEmpty":
//            handle(players: player, bufferEmptyChange: change)
//            
//        case "externalPlaybackActive":
//            handle(players: player, externalPlaybackChange: change)
//            
//        default:
//            break
//        }
    }
    
}

/*
 - callbacking - delegate? closure with events? combination?
 - what should user configure on player itself and what should be configured through API of this library?
 
 AVPlayer:
 
 MVP:
 
 X play
 X pause
 X replace current item (destroy observing on current and set new)
 X seek to position in seconds (user cancelPendingSeeks())
 X report playback progress (interval should be configurable, automatically remove observer)
 X report stall and resume playback (rate, isPlaybackLikelyToKeepUp, buffer status, AVPlayerItemPlaybackStalled notif?)
 X report buffer status (underflow, has data)
 X report player status
 X get error
 
 - observing rate
 X observing externalPlaybackActive (report change on external playback)
 X observing status (report state changes, report failed - AVPlayerItemFailedToPlayToEndTime notif?)
 
 FULL:
 - reasonForWaitingToPlay observing
 - report boundary times (set time and report them through callbacks)
 - observing volume
 
 AVPlayerItem:
 
 MVP:
 X duration in seconds
 X current playback position in seconds
 X access_log (report changes in profile, AVPlayerItemNewAccessLogEntry notif)
 X error_log (probably only for debugging, report errors, AVPlayerItemNewErrorLogEntry notif)
 
 X api to list subtitles
 X api to swtich subtitles
 X api to list audio languages
 X api to switch audio languages
 
 X playback finished (AVPlayerItemDidPlayToEndTime notif)
 
 
 
 Full:
 - observing tracks
 - loaded time ranges (report array of ranges in seconds or compute everything togegher?)
 - observing presentationSize
 - observing timedMetadata
 
 */

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

public class SHMAVPlayerInterface
{
    public let              player: AVPlayer
    
    public private(set) var seeking: Bool
    
    public init(player: AVPlayer)
    {
        self.player = player
        
        seeking = false
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
}

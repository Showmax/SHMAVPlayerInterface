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

/// This class can make your live easier when you are working with `AVPlayer` and `AVPlayerItem`. It provides API which is easy to use and you can
/// use it to interact with `AVPlayer` and it's item. 
///
/// You can also use RX extensions for `AVPlayer and `AVPlayerItem` provided by this library .
/// These extensions will provide additional ways how to easily interact with `AVPlayer` and `AVPlayerItem`.
///
/// This class is only wrapper around `AVPlayer`. This class doesn't inherit from `AVPlayer` class or it doesn't extend that. To use this class
/// just create instance and pass your player to constructor and that's it.
///
public class SHMAVPlayerInterface
{
    /// Instace of `AVPlayer` wrapped by this instance.
    public let              player: AVPlayer
    
    /// Indicates if seek operation is currently in progress.
    public private(set) var seeking: Bool
    
    /// Create and configure `SHMAVPlayerInterface` instance with existing `AVPlayer` instance.
    ///
    /// - Parameter player: Existing player.
    public init(player: AVPlayer)
    {
        self.player = player
        
        seeking = false
    }
    
    // MARK: - Playback state and control
    
    /// Return current asset duration if it's available. If `player` doesn't have `currentItem` or current item didn't load duration information yet
    /// then this method return `nil`.
    public var duration: TimeInterval?
    {
        let seconds = player.currentItem?.duration.seconds ?? TimeInterval.nan

        return seconds.isNaN ? nil : seconds
    }
    
    /// Return current playback position in seconds.
    public var playbackPosition: TimeInterval
    {
        return player.currentTime().seconds
    }

    /// Indicates if playback is paused. `player`'s `rate` property is used to determine this.
    public var paused: Bool
    {
        return player.rate == 0.0
    }
    
    /// Indicates if playback is probably stalled.
    ///
    /// We assume that playback is stalled when:
    /// - playback is paused (rate is <= 0.0)
    /// - seeking operation is NOT in progress
    /// - `currentItem`'s playback buffer is empty
    public var playbackProbablyStalled: Bool
    {
        return paused && !seeking && (player.currentItem?.isPlaybackBufferEmpty ?? false)
    }
    
    /// Get current error. First try to return error from player and if it's `nil` then return error from `player`'s item.
    public var error: Error?
    {
        return player.error ?? player.currentItem?.error
    }
    
    /// Resume playback by calling `play()` on `player`.
    public func play()
    {
        player.play()
    }
    
    /// Pause playback by calling `pause()` on `player`.
    public func pause()
    {
        player.pause()
    }
    
    /// Sets the current playback time within a specified time bound and invokes the specified block when the seek operation has either been 
    /// completed or been interrupted.
    ///
    /// Use this method to seek to a specified time for the current player item and to be notified when the seek operation is complete.
    ///
    /// The time seeked to will be within the range [time-beforeTolerance, time+afterTolerance], and may differ from the specified time for
    /// efficiency. You can request sample accurate seeking by passing a time value of `0.0` for both toleranceBefore and toleranceAfter.
    /// Sample accurate seeking may incur additional decoding delay which can impact seeking performance.
    ///
    /// The completion handler for any prior seek request that is still in process will be invoked immediately with the finished parameter set 
    /// to false. If the new request completes without being interrupted by another seek request or by any other operation the specified completion 
    /// handler will be invoked with the finished parameter set to true.
    ///
    /// - Parameters:
    ///   - position: Position in seconds to which to seek.
    ///   - toleranceBefore: The tolerance in seconds allowed before `position`. Default value is 0.0.
    ///   - toleranceAfter: The tolerance allowed after `position`. Default value is 0.0.
    ///   - cancelPendingSeeks: Indicates if any pending seeks should be canceled. Default value is `true`.
    ///   - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted.
    ///
    ///                        The block takes one argument:
    ///
    ///                        finished
    ///                            Indicated whether the seek operation completed.
    public func seek(
        to position: TimeInterval,
        toleranceBefore: TimeInterval = 0.0,
        toleranceAfter: TimeInterval = 0.0,
        cancelPendingSeeks: Bool = true,
        completionHandler: ((Bool) -> Void)? = nil
    )
    {
        if cancelPendingSeeks
        {
            player.currentItem?.cancelPendingSeeks()
        }
        
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
    
    // MARK: - Subtitles and audio tracks
    
    /// Return array of available subtitles tracks.
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
    
    /// Return selected subtitle track. If none is selected this property returns `nil`.
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
    
    /// Return array of available audio tracks.
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
    
    /// Return selected audio track. If none is selected this property returns `nil`.
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
    
    /// This method selects subtitle track. If `nil` is passed then no track is selected and current one is deselected.
    ///
    /// You should pass here only `Subtitle` instance previously returned by `SHMAVPlayerInterface`.
    ///
    /// - Parameter subtitle: Subtitle track to select. If this is `nil` then no track is selected and current one is deselected.
    public func select(subtitle: Subtitle?)
    {
        guard let item = player.currentItem else { return }
        guard let subtitlesGroup = item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicLegible) else { return }
        
        item.select(subtitle?.option, in: subtitlesGroup)
    }
    
    /// This method selects audio track. If `nil` is passed then no track is selected and current one is deselected.
    ///
    /// You should pass here only `AudioTrack` instance previously returned by `SHMAVPlayerInterface`.
    ///
    /// - Parameter subtitle: Audio track to select. If this is `nil` then no track is selected and current one is deselected.
    public func select(audioTrack: AudioTrack)
    {
        guard let item = player.currentItem else { return }
        guard let audioGroup = item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicAudible) else { return }
        
        item.select(audioTrack.option, in: audioGroup)
    }
}

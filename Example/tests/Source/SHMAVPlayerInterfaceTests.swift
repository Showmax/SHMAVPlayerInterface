//
//  SHMAVPlayerInterfaceTests.swift
//  SHMAVPlayerInterface
//
//  Created by Michal Fousek on 11/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import AVFoundation

import XCTest

import RxSwift

class SHMAVPlayerInterfaceTests: XCTestCase
{
    func test__playerStatusChange__playerStatusChangedCallbackIsCalled()
    {
    }
    
    func test__playbackFinish__playbackFinishedCallbackIsCalled()
    {
        
    }
    
    func test__playbackPause__playbackPausedCallbackIsCalled()
    {
        
    }
    
    func test__playbackResume__playbackPausedCallbackIsCalled()
    {
        
    }
    
    func test__playbackPositionIsUpdated__playbackPositionUpdatedCallbackIsCalled()
    {
        
    }
    
    func test__playbackSwitchToExtenralPlayback__externalPlaybackActiveChangedIsCalled()
    {
        
    }
    
    func test__playbackSwitchFromExternalPlayback__externalPlaybackActiveChangedIsCalled()
    {
        
    }
    
    func test__newAccessLogEvent__newAccessLogEventCallbackIsCalled()
    {
    }
    
    func test__newErrorLogEvent__newErrorLogEventIsCalled()
    {
        
    }
    
    func test__duration__isSameAsAssetDuration()
    {
        
    }
    
    func test__playbackPosition__isSameAsCurrentPlaybackPosition()
    {
        
    }
    
    func test__availableSubtitles__areSameAsSubtitlesProvidedByAsset()
    {
        
    }
    
    func test__selectedSubtitlesWhenSomeSubtitlesAreSelected__returnSubtitles()
    {
        
    }
    
    func test__selectedSubtitlesWhenNoSubtitlesSelected__returnNil()
    {
        
    }
    
    func test__availableAudioTracks__areSameAsAudioTracksProvidedByAsset()
    {
        
    }
    
    func test__selectedAudioTrack__returnCurrentlySelectedAudioTrack()
    {
        
    }
    
    func test__pausedByUser__returnTrueWhenPlaybackIsProbablyPausedByUser()
    {
        
    }
    
    func test__probablyStalled__returnTrueWhenPlaybackIsProbablyStalled()
    {
        
    }
    
    func test__error__returnErrorObject()
    {
        
    }
    
    func test__setPlayerItem__probablyIntegrationTestWhichTestsIfEverythingSetup()
    {
        
    }
    
    func test__play__playbackStarts()
    {
        
    }
    
    func test__pause__playbackPause()
    {
        
    }
    
    func test__seek__currentPlaybackPositionChangeWhenSeekFinish()
    {
        
    }
    
    func test__selectSomeSubtitle__subtitleIsSelected()
    {
        
    }
    
    func test__deselectSubtitle__subtitlesAreTurnedOff()
    {
        
    }
    
    func test__selectAudioTrack__audioTrackIsSelected()
    {
        
    }
    
    
    
    func test1()
    {
        var bag = DisposeBag()
        
        let asset = AVAsset(url: URL(string: "https://tungsten.aaplimg.com/VOD/bipbop_adv_example_v2/master.m3u8")!)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        
        let playerInterface = SHMAVPlayerInterface(player: player)
        
        shmwait(timeout: 5.0, action: { done in
            
            playerInterface.observePlaybackPosition(updateInterval: 0.1, updateQueue: nil)
                .subscribe(
                    onNext: { position in
                        
                        ldebug("Testing position \(position)")
                        guard position > 0.0 else { return }
                        
                        done()
                    }
                )
                .disposed(by: bag)
            
            playerInterface.play()
        })
        
        bag = DisposeBag()
    }
}

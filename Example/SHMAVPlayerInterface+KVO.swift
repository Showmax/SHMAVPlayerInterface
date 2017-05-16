//
//  SHMAVPlayerInterface+KVO.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 16/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import AVFoundation

extension SHMAVPlayerInterface
{
    func removeAllKVOObservers()
    {
        let player = self.player
        let item = player.currentItem
        
        ldebug("PAths to remove item \(observingContext.pathsObservedForItem)")
        
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
        
        ldebug("Paths for item \(observingContext.pathsObservedForItem)")
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
                ldebug("No status")
                
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

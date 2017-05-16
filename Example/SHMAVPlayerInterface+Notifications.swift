//
//  SHMAVPlayerInterface+Notifications.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 16/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation

extension SHMAVPlayerInterface
{
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
}

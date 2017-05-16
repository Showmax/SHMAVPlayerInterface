//
//  SHMAVPlayerInterface+PlayerObservers.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 16/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import CoreMedia

extension SHMAVPlayerInterface
{
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

}

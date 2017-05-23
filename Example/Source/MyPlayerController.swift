//
//  MyPlayerController.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 16/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import RxSwift

class MyPlayerController: AVPlayerViewController
{
    var     bag = DisposeBag()
    var     playerInterface: SHMAVPlayerInterface?
    
    override var player: AVPlayer?
    {
        get { return super.player }
        set
        {
            defer
            {
                super.player = newValue
            }
            
            guard let newPlayer = newValue else
            {
                playerInterface = nil
                return
            }
            
            playerInterface = SHMAVPlayerInterface(player: newPlayer)
            
            subscribeToPlayerInterface()
            
            let asset = AVAsset(url: URL(string: "https://tungsten.aaplimg.com/VOD/bipbop_adv_example_v2/master.m3u8")!)
            let item = AVPlayerItem(asset: asset)
            
            let config = SHMAVPlayerInterface.Configuration(
                observeProperties: [.playerItemStatus, .playbackPosition],
                positionUpdateInterval: 0.1,
                positionUpdateQueue: nil
            )
            
            playerInterface?.set(playerItem: item, configuration: config)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        bag = DisposeBag()
        playerInterface = nil
    }
    
    func subscribeToPlayerInterface()
    {
        guard let playerInterface = self.playerInterface else { return }
        
        playerInterface.playerItemStatusObservable
            .subscribe(
                onNext: { status in
                    
                    print("Item status \(status.rawValue)")
                }
            )
            .disposed(by: bag)
        
        playerInterface.playbackPositionObservable
            .subscribe(
                onNext: { position in
                    
                    print("Playback position \(position).")
                }
            )
            .disposed(by: bag)
    }
    
}

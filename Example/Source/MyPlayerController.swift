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
import RxCocoa

class MyPlayerController: AVPlayerViewController
{
    var     bag = DisposeBag()
    var     playerInterface: SHMAVPlayerInterface?
    
    deinit
    {
        ldebug("Destroying player controller")
    }
    
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
        //playerInterface?.observePlaybackPosition(updateInterval: 0.1, updateQueue: nil)
         //   .subscribe(
           //     onNext: { position in
                    
             //       ldebug("Playback position \(position).")
               // }
            //)
            //.disposed(by: bag)
        
        playerInterface?.observePlayerItemStatus(options: .new)
            .subscribe(
                onNext: { itemStatus in
                    
                    ldebug("Item status \(itemStatus.rawValue)")
                }
            )
            .disposed(by: bag)
    }
    
}

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
        
//        playerInterface?.player.rx.status(options: [.initial, .new])
//            .subscribe(
//                onNext: { itemStatus in
//                    
//                    ldebug("player status \(itemStatus.rawValue)")
//                }
//            )
//            .disposed(by: bag)
//        
//        playerInterface?.player.currentItem?.rx.status(options: [.initial, .new])
//            .subscribe(
//                onNext: { itemStatus in
//                    
//                    ldebug("player item status \(itemStatus.rawValue)")
//                }
//            )
//            .disposed(by: bag)
//        
//        playerInterface?.player.rx.playbackPosition(updateInterval: 0.1, updateQueue: nil)
//            .subscribe(
//                onNext: { position in
//                    
//                    ldebug("position \(position)")
//                }
//            )
//            .disposed(by: bag)
//        
//        playerInterface?.player.currentItem?.rx.bufferStatus(options: [.new])
//            .subscribe(
//                onNext: { bufferStatus in
//                    
//                    ldebug("bufferStatus \(bufferStatus)")
//                }
//            )
//            .disposed(by: bag)
//        
//        playerInterface?.player.currentItem?.rx.errorLogEvent
//            .subscribe(
//                onNext: { event in
//                    
//                    let str = "\(event.uri) \(event.errorStatusCode) \(event.errorDomain) \(event.errorComment)"
//                    ldebug(str)
//                }
//            )
//            .disposed(by: bag)
        
//        playerInterface?.player.currentTime?.rx.acc
        
//        playerInterface?.observePlayerItemStatus(options: .new)
//            .subscribe(
//                onNext: { itemStatus in
//                    
//                    ldebug("Item status \(itemStatus.rawValue)")
//                }
//            )
//            .disposed(by: bag)
    }
    
}

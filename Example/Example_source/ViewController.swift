//
//  ViewController.swift
//  SHMAVPlayerInterfaceExampleTVOS
//
//  Created by Michal Fousek on 16/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import UIKit

import AVFoundation
import AVKit

import RxSwift

class ViewController: UIViewController
{
    var     bag = DisposeBag()
    
    /// Initialize and present player controller.
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        guard let assetURL = URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8") else
        {
            fatalError("Can't create URL for asset.")
        }
        
        let asset = AVAsset(url: assetURL)
        
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        
        let playerController = ExamplePlayerController(nibName: "ExamplePlayerController", bundle: nil, player: player)
        
        present(playerController, animated: true, completion: {[weak playerController] in
            
            playerController?.playerInterface.play()
        })
    }    
}

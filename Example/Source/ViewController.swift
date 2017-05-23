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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //        "https://tungsten.aaplimg.com/VOD/bipbop_adv_example_v2/master.m3u8"
    }
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        let player = AVPlayer(playerItem: nil)
        
        let playerController = MyPlayerController()
        playerController.player = player
        
        present(playerController, animated: true, completion: {[weak playerController] in
            
            playerController?.playerInterface?.play()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

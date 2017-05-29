//
//  SHMTextCase.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 23/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import AVFoundation

import XCTest
import Nimble
import RxSwift
import RxBlocking

let kBipBopDuration: TimeInterval = 1800.045

class SHMTestCase: XCTestCase
{
    var bag = DisposeBag()
    var lastPlayer: AVPlayer? = nil
    
    override func setUp()
    {
        super.setUp()
    }
    
    override func tearDown()
    {
        super.tearDown()
        
        bag = DisposeBag()
        lastPlayer = nil
    }
    
    func createPlayer() -> AVPlayer
    {
        let asset = AVAsset(url: URL(string: "https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)

        lastPlayer = player
        
        return player
    }
    
    func createPlayerAndInterface() -> (player: AVPlayer, interface: SHMAVPlayerInterface)
    {
        let player = createPlayer()
        let interface = SHMAVPlayerInterface(player: player)
        
        return (player: player, interface: interface)
    }
}

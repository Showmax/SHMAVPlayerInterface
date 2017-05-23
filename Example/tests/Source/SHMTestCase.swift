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
        let asset = AVAsset(url: URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")!)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)

        lastPlayer = player
        
        return player
    }
}

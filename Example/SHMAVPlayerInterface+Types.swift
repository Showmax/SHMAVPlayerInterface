//
//  SHMAVPlayerInterface+Types.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 16/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import AVFoundation

import RxSwift

extension SHMAVPlayerInterface
{
    public struct Subtitle
    {
        let languageCode: String
        let forced: Bool
        let option: AVMediaSelectionOption
    }
    
    public struct AudioTrack
    {
        let languageCode: String
        let option: AVMediaSelectionOption
    }
}


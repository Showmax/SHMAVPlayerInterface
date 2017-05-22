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
    /// This structure represent one subtitle track.
    public struct Subtitle
    {
        /// ISO language code of this subtitle track.
        let languageCode: String
        /// Indicates if subtitles are forced.
        let forced: Bool
        /// Option which represents this subtitle track in player.
        let option: AVMediaSelectionOption
    }
    
    /// This structure represent one audio track.
    public struct AudioTrack
    {
        /// ISO language code of this audio track.
        let languageCode: String
        /// Option which represents this audio track in player.
        let option: AVMediaSelectionOption
    }
}


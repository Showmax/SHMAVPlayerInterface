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
    public struct ObservingOptions: OptionSet
    {
        public let rawValue: UInt
        
        public init(rawValue: UInt) { self.rawValue = rawValue }
        
        public static let initial = ObservingOptions(rawValue: 1 << 0)
        public static let new = ObservingOptions(rawValue: 1 << 1)
        
        var keyValuesObservingOptions: NSKeyValueObservingOptions
        {
            var options = NSKeyValueObservingOptions(rawValue: 0)
            
            if self.contains(.initial)
            {
                options.insert(.initial)
            }
            
            if self.contains(.new)
            {
                options.insert(.new)
            }
            
            return options
        }
    }
    
    public struct PlayerItemBufferStatus
    {
        let bufferEmpty: Bool
        let bufferFull: Bool
    }
    
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

extension SHMAVPlayerInterface.PlayerItemBufferStatus: Equatable {}
public func == (lhs: SHMAVPlayerInterface.PlayerItemBufferStatus, rhs: SHMAVPlayerInterface.PlayerItemBufferStatus) -> Bool
{
    return lhs.bufferEmpty == rhs.bufferEmpty && lhs.bufferFull == rhs.bufferFull
}

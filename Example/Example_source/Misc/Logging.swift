//
//  Logging.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 16/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation

var dateFormatter: DateFormatter? = nil

func ldebug(_ message: Any, function: String = #function, line: Int = #line, file: String = #file)
{
#if DEBUG
    if dateFormatter == nil
    {
        dateFormatter = DateFormatter()
        dateFormatter?.dateFormat = "HH:mm:ss.SSS"
    }
    
    let filename = ((file as NSString).lastPathComponent as NSString).deletingPathExtension
    
    print("\(dateFormatter?.string(from: Date()) ?? "") \(Int(Thread.isMainThread ? 1 : 0)) [\(filename):\(line)] \(function): \(message)")
#endif
    
}

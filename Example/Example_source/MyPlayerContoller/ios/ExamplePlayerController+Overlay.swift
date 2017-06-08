//
//  ExamplePlayerController+Overlay.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 23/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import UIKit

import SHMAVPlayerInterface

extension ExamplePlayerController
{
    /// Create and show custom UI over player.
    ///
    /// - Parameter playerInterface: Current player interface to use.
    func setupOverlayView(with playerInterface: SHMAVPlayerInterface)
    {
        playerController.showsPlaybackControls = false
        
        let possibleOverlay = Bundle.main.loadNibNamed(
            "ExamplePlayerControllerOverlayView",
            owner: nil,
            options: nil
        )?.first as? ExamplePlayerControllerOverlayView
        
        guard let overlay = possibleOverlay else
        {
            print("Can't load overlay view.")
            return
        }
        
        add(view: overlay, to: view)
        
        overlay.closeClosure = {[weak self] in
            
            self?.dismiss(animated: true, completion: nil)
        }
        
        overlay.useNew(playerInterface: playerInterface)
    }
}

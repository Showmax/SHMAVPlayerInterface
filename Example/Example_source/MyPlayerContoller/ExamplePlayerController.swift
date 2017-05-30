//
//  ExamplePlayerController.swift
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

/// This controller wrap `AVPlayerViewController`. Thanks to this we can present custom UI over player.
class ExamplePlayerController: UIViewController
{
    var     bag: DisposeBag
    var     playerInterface: SHMAVPlayerInterface
    
    let     playerController: AVPlayerViewController
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, player: AVPlayer)
    {
        playerInterface = SHMAVPlayerInterface(player: player)
        playerController = AVPlayerViewController()
        bag = DisposeBag()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        addChildViewController(playerController)
        add(view: playerController.view, to: view)
        playerController.didMove(toParentViewController: self)
        
        playerController.player = player
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setupOverlayView(with: playerInterface)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        bag = DisposeBag()
    }
    
    func add(view: UIView, to overlayView: UIView)
    {
        overlayView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        overlayView.addConstraint(fullscreenConstraintForAttribute(.left, superview: overlayView, view: view))
        overlayView.addConstraint(fullscreenConstraintForAttribute(.right, superview: overlayView, view: view))
        overlayView.addConstraint(fullscreenConstraintForAttribute(.top, superview: overlayView, view: view))
        overlayView.addConstraint(fullscreenConstraintForAttribute(.bottom, superview: overlayView, view: view))
    }
    
    func fullscreenConstraintForAttribute(_ attribute: NSLayoutAttribute, superview: UIView, view: UIView) -> NSLayoutConstraint
    {
        return NSLayoutConstraint(
            item: view,
            attribute: attribute,
            relatedBy: .equal,
            toItem: superview,
            attribute: attribute,
            multiplier: 1.0,
            constant: 0.0
        )
    }
    
}

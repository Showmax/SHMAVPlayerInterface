// Copyright since 2015 Showmax s.r.o.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


import Foundation
import AVKit
import AVFoundation

import RxSwift
import RxCocoa

import SHMAVPlayerInterface

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
        
        observePlaybackPositionOnAllPlatforms()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        bag = DisposeBag()
    }
    
    func observePlaybackPositionOnAllPlatforms()
    {
        // Receive update on playback position every two seconds on main thread.
        playerInterface.player.rx.playbackPosition(updateInterval: 2.0, updateQueue: nil)
            .subscribe(
                onNext: { position in
                    
                    ldebug("Playback position: \(position)")
                    
                }
            )
            .disposed(by: bag)
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

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
import UIKit

import RxSwift
import RxCocoa

import SHMAVPlayerInterface

/// This class represent custom UI over player.
class ExamplePlayerControllerOverlayView: UIView
{
    var                 bag = DisposeBag()
    
    @IBOutlet var       indicator: UIActivityIndicatorView!
    @IBOutlet var       slider: CustomSlider!
    @IBOutlet var       playButton: UIButton!
    @IBOutlet var       playbackPositionLabel: UILabel!
    @IBOutlet var       playbackRemainingLabel: UILabel!
    
    var                 updateSliderUsingPlaybackPosition = true
    
    var                 playerInterface: SHMAVPlayerInterface? = nil
    var                 closeClosure: (() -> Void)? = nil
    
    // MARK: - Actions
    
    /// This method is called when user hit play/pause button. It just call play or pause on `playerInterface`.
    @IBAction func playPause()
    {
        guard let playerInterface = self.playerInterface else { return }
        
        playerInterface.paused ? playerInterface.play() : playerInterface.pause()
    }
    
    /// Skip playback position about 10 seconds back. If current playback position is `< 10.0` then skip to`0.0`.
    @IBAction func rewind()
    {
        guard let playerInterface = self.playerInterface else { return }
        
        var seekTime: TimeInterval
        if playerInterface.playbackPosition < 10.0
        {
            seekTime = 0.0
            
        } else
        {
            seekTime = playerInterface.playbackPosition - 10.0
        }
        
        playerInterface.seek(to: seekTime, completionHandler: {[weak self] _ in
            
            self?.playerInterface?.play()
        })
    }
    
    /// Skip playback position about 10 seconds forward. If current playback position is `> duration - 10.0` then skip to `duration - 1.0`.
    @IBAction func forward()
    {
        guard let playerInterface = self.playerInterface, let duration = playerInterface.duration else { return }
        
        var seekTime: TimeInterval
        if playerInterface.playbackPosition + 10.0 >= duration
        {
            seekTime = duration - 1.0
            
        } else
        {
            seekTime = playerInterface.playbackPosition + 10.0
        }
        
        playerInterface.seek(to: seekTime, completionHandler: {[weak self] _ in
            
            self?.playerInterface?.play()
        })
    }
    
    /// This method is called when user hit close button. It calls `closeClosure`.
    @IBAction func close()
    {
        closeClosure?()
    }
    
    // MARK: - API

    /// Use new player interface. Drop current dispose bag and bind observables to UI.
    ///
    /// - Parameter playerInterface: Player interface to use.
    func useNew(playerInterface: SHMAVPlayerInterface)
    {
        bag = DisposeBag()
        self.playerInterface = playerInterface
        
        setupPlaybackPositionSubscription(with: playerInterface)
        setupPausePlayButtonBindigs(with: playerInterface)
        setupSubscriptionToSliderTouchEvents()
        setupSubscriptionToSliderValue()
    }
    
    // MARK: - Subscription and binding to UI
    
    /// This method use playback position observable and bind it to seek slider and to position labels.
    /// Signals from this observable are filtered so it's emitting only when `self.updateSliderUsingPlaybackPosition` is `true`.
    ///
    /// - Parameter playerInterface: Player interface to use.
    func setupPlaybackPositionSubscription(with playerInterface: SHMAVPlayerInterface)
    {
        let positionObservable = playerInterface.player.rx.playbackPosition(updateInterval: 1.0, updateQueue: nil)
            .filter({[weak self] _ in
                
                return self?.updateSliderUsingPlaybackPosition ?? false
            })
            .share()
        
        positionObservable
            .map({[weak self] position -> Float in
                
                guard let duration = self?.playerInterface?.duration, duration > 0.0 else { return 0.0 }
                
                return Float(position / duration)
            })
            .bind(to: slider.rx.value)
            .disposed(by: bag)
        
        bindObservableToPositionLabels(observable: positionObservable)
    }
    
    /// Use paused observable and bind it to play button.
    ///
    /// - Parameter playerInterface: Player interface to use.
    func setupPausePlayButtonBindigs(with playerInterface: SHMAVPlayerInterface)
    {
        playerInterface.player.rx.paused(options: [.initial, .new])
            .map({ $0 ? ">" : "||" })
            .bind(to: playButton.rx.title(for: .normal))
            .disposed(by: bag)
    }
    
    /// This method listents to slider's touch events and track them. 
    ///
    /// When user start touching slider then `self.updateSliderUsingPlaybackPosition` is set to `false`. Thanks to this slider position is take from
    /// it's value not from playback position.
    ///
    /// When user stop touch slider then `self.updateSliderUsingPlaybackPosition` is set to `true` and playback seek to current slider position.
    /// Slider position is now updated using playback position.
    ///
    func setupSubscriptionToSliderTouchEvents()
    {
        slider.eventsObservable
            .subscribe(
                onNext: {[weak self] event in
                    
                    guard let me = self else { return }
                    
                    switch event
                    {
                    case .touchBegin:
                        me.updateSliderUsingPlaybackPosition = false
                        
                    case .touchEnded:
                        guard let duration = me.playerInterface?.duration, duration > 0.0 else { return }
                        
                        let position = duration * TimeInterval(me.slider.value)
                        
                        me.playerInterface?.seek(to: position, completionHandler: { _ in
                            
                            self?.updateSliderUsingPlaybackPosition = true
                            self?.playerInterface?.play()
                        })
                    }
                }
            )
            .disposed(by: bag)
    }
    
    /// This value observe slider value and when `self.updateSliderUsingPlaybackPosition` is `false` then update position labels.
    func setupSubscriptionToSliderValue()
    {
         let sliderPositionObservable = slider.rx.value
            .asObservable()
            .filter({[weak self] (_: Float) in
                
                return !(self?.updateSliderUsingPlaybackPosition ?? true)
            })
            .map({[weak self] (value: Float) -> TimeInterval in
                
                guard let duration = self?.playerInterface?.duration, duration > 0.0 else { return 0.0 }
                
                return duration * TimeInterval(value)
            })
            .share()
        
        bindObservableToPositionLabels(observable: sliderPositionObservable)
    }
    
    /// This method takes observable which emitt some playback position and bind it to position labels.
    ///
    /// - Parameter observable: Observable which emitt some playback position.
    func bindObservableToPositionLabels(observable: Observable<TimeInterval>)
    {
        observable
            .timeToText()
            .bind(to: playbackPositionLabel.rx.text)
            .disposed(by: bag)
        
        observable
            .map({[weak self] position -> TimeInterval in
                
                guard let duration = self?.playerInterface?.duration, duration > 0.0 else { return 0.0 }
                
                return duration - position
            })
            .timeToText()
            .map({ "-\($0)" })
            .bind(to: playbackRemainingLabel.rx.text)
            .disposed(by: bag)
    }
}

// MARK: - Misc

extension TimeInterval
{
    /// Convert some number of seconds to "time string". For example: 131 -> 02:11
    ///
    /// - Returns: String which contains time in human readable form.
    func timeToText() -> String
    {
        if self.isNaN || self < 0
        {
            return "00:00"
        }
        
        let hours = Int(self / 3600)
        let minutes = Int(floor(self / 60.0))
        let minutes60 = minutes - hours * 60
        let seconds = Int(floor(self - (Double(minutes) * 60.0)))
        
        var res = ""
        
        if hours > 0
        {
            let appendStr = String(format: "%d:", hours)
            
            res += appendStr
        }
        
        let appendStr = String(format: "%02d:%02d", minutes60, seconds)
        
        res += appendStr
        
        return res
    }
}

extension Observable where Element == TimeInterval
{
    func timeToText() -> Observable<String>
    {
        return map({ $0.timeToText() })
    }
}

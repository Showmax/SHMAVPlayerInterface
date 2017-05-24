//
//  MyPlayerControllerOverlayView.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 23/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa

class MyPlayerControllerOverlayView: UIView
{
    var                 bag = DisposeBag()
    
    @IBOutlet var       indicator: UIActivityIndicatorView!
    @IBOutlet var       slider: CustomSlider!
    @IBOutlet var       playButton: UIButton!
    @IBOutlet var       playbackPositionLabel: UILabel!
    @IBOutlet var       playbackRemainingLabel: UILabel!
    
    var                 updateSlider = true
    
    var                 playerInterface: SHMAVPlayerInterface? = nil
    var                 closeClosure: (() -> Void)? = nil
    
    // MARK: - Actions
    
    @IBAction func playPause()
    {
        guard let playerInterface = self.playerInterface else { return }
        
        playerInterface.paused ? playerInterface.play() : playerInterface.pause()
    }
    
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
    
    @IBAction func close()
    {
        closeClosure?()
    }
    
    // MARK: - API

    func useNew(playerInterface: SHMAVPlayerInterface)
    {
        bag = DisposeBag()
        self.playerInterface = playerInterface
        
        setupPositionSubscription(with: playerInterface)
        setupPausePlayButtonBindigs(with: playerInterface)
        setupSubscriptionToSlider()
    }
    
    func setupPositionSubscription(with playerInterface: SHMAVPlayerInterface)
    {
        let positionObservable = playerInterface.player.rx.playbackPosition(updateInterval: 1.0, updateQueue: nil)
            .filter({[weak self] position in
                
                return self?.updateSlider ?? false
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
    
    func setupPausePlayButtonBindigs(with playerInterface: SHMAVPlayerInterface)
    {
        playerInterface.player.rx.paused(options: [.initial, .new])
            .map({ $0 ? ">" : "||" })
            .bind(to: playButton.rx.title(for: .normal))
            .disposed(by: bag)
    }
    
    func setupSubscriptionToSlider()
    {
        slider.eventsObservable
            .subscribe(
                onNext: {[weak self] event in
                    
                    guard let me = self else { return }
                    
                    switch event
                    {
                    case .touchBegin:
                        me.updateSlider = false
                        
                    case .touchEnded:
                        guard let duration = me.playerInterface?.duration, duration > 0.0 else { return }
                        
                        let position = duration * TimeInterval(me.slider.value)
                        
                        me.playerInterface?.seek(to: position, completionHandler: { _ in
                            
                            self?.updateSlider = true
                            self?.playerInterface?.play()
                        })
                    }
                }
            )
            .disposed(by: bag)
        
         let sliderPositionObservable = slider.rx.value
            .asObservable()
            .filter({[weak self] (position: Float) in
                
                return !(self?.updateSlider ?? true)
            })
            .map({[weak self] (value: Float) -> TimeInterval in
                
                guard let duration = self?.playerInterface?.duration, duration > 0.0 else { return 0.0 }
                
                return duration * TimeInterval(value)
            })
            .share()
        
        bindObservableToPositionLabels(observable: sliderPositionObservable)
    }
    
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

extension TimeInterval
{
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

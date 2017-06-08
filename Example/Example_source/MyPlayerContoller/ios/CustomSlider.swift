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

enum CustomSliderEvent
{
    case touchBegin
    case touchEnded
}

/// This class is custom implementation of `UISlider` which helps tracking user interaction with this slider.
class CustomSlider: UISlider
{
    private var     eventsSubject = PublishSubject<CustomSliderEvent>()
    
    var             eventsObservable: Observable<CustomSliderEvent>
    {
        return eventsSubject.asObservable()
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool
    {
        // local touch point
        let touchPoint = touch.location(in: self)
        
        // Check if the knob isn't touched
        if !thumbRect().contains(touchPoint)
        {
            let percentage = (touchPoint.x / bounds.size.width)
            let diff = percentage * (CGFloat(maximumValue) - CGFloat(minimumValue))
            let value = CGFloat(minimumValue) + CGFloat(diff)
            
            setValue(Float(value), animated: true)
        }
        
        eventsSubject.onNext(.touchBegin)
        
        return super.beginTracking(touch, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        eventsSubject.onNext(.touchEnded)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>?, with event: UIEvent?)
    {
        eventsSubject.onNext(.touchEnded)
    }
    
    func thumbRect() -> CGRect
    {
        let trackRect = self.trackRect(forBounds: bounds)
        
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        
        return thumbRect
    }
}

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

import RxSwift

protocol OptionalWrapper
{
    associatedtype Wrapped
    
    var value: Wrapped? { get }
}

extension Optional: OptionalWrapper
{
    var value: Wrapped?
    {
        return self
    }
}

extension Observable where Element: OptionalWrapper
{
    /// This operator ignore `next` events which contains nil. Output is non-optional type.
    ///
    /// - Returns: Observable with non-optional type.
    func ignoreNil() -> Observable<E.Wrapped>
    {
        return flatMap({ element -> Observable<E.Wrapped> in
            
            guard let value = element.value else
            {
                return Observable<E.Wrapped>.empty()
                
            }
            
            return Observable<E.Wrapped>.just(value)
        })
    }
}

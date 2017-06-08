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

import XCTest
import Nimble
import RxSwift
import RxBlocking

class ObservableIgnoreNilTests: SHMTestCase
{
    func test__userIgnoreNilOperator__emittedNilItemsAreIgnored()
    {
        let array: [Int?] = [5, nil, 6, nil, nil, 3]
        let expectedArray = ["5", "6", "3"]
        
        do
        {
            let finalArray = try Observable<Int?>.from(array)
                .ignoreNil()
                .map({ number in
                    
                    return "\(number)"
                })
                .toBlocking()
                .toArray()
            
            expect(finalArray.count) == expectedArray.count
            guard finalArray.count == expectedArray.count else { return }
            
            for i in 0..<finalArray.count
            {
                expect(finalArray[i]) == expectedArray[i]
            }
            
        } catch let err
        {
            XCTFail("Error when ignoring nil \(err).")
        }
    }
}

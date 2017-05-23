//
//  Observable+IgnoreNilTests.swift
//  SHMAVPlayerIntefaceExample
//
//  Created by Michal Fousek on 23/05/2017.
//  Copyright © 2017 Showmax. All rights reserved.
//

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

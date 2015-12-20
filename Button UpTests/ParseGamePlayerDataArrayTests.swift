//
//  parseGamePlayerDataArrayTests.swift
//  Button Up
//
//  Created by Ricky Buchanan on 19/12/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import XCTest
@testable import Button_Up

class parseGamePlayerDataArrayTests: XCTestCase {
    
    func testParseGamePlayerDataArray() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("playerDataArray", ofType:
            "json")
        let data = NSData(contentsOfFile: path!)
        
        let parser = APIClient()
        let results = parser.parseJSON(data!)
        let playerData = parser.parseGamePlayerDataArray(results as! [[String: AnyObject]])
        
        XCTAssertNotNil(playerData)
        
        XCTAssertEqual(false, playerData![0].hasDismissedGame)
        XCTAssertEqual("itachi", playerData![1].button.name)
        XCTAssertEqual("2015-12-19 00:19:18 +0000", playerData![1].lastActionTime)
    }

}

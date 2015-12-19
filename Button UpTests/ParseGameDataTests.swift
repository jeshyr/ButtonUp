//
//  ParseGameDataTests.swift
//  Button Up
//
//  Created by Ricky Buchanan on 19/12/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import XCTest
@testable import Button_Up

class ParseGameDataTests: XCTestCase {
 
    func testParseGameData() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("loadGameData", ofType:
            "json")
        let data = NSData(contentsOfFile: path!)
        
        let parser = APIClient()
        let results = parser.parseJSON(data!)
        let game = parser.parseGameData(results as! [String: AnyObject])
        
        XCTAssertNotNil(game)
        XCTAssertEqual(8936, game!.id)
        XCTAssertEqual(1, game?.activePlayerIndex)
        XCTAssertEqual("Nickie", game?.playerData[1].button.name)
    }
    
    func testParseGameDataInvalidResults() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("invalid", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        
        let parser = APIClient()
        let results = parser.parseJSON(data!)
        XCTAssertNil(results)
    }

}

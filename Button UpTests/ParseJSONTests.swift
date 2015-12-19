//
//  parseJSONTests.swift
//  Button Up
//
//  Created by Ricky Buchanan on 19/12/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import XCTest
@testable import Button_Up

class parseJSONTests: XCTestCase {
    
    func testParseJSON() {
        let bundle = NSBundle(forClass: self.dynamicType)
        var path = bundle.pathForResource("loadActiveGames", ofType:
            "json")
        var data = NSData(contentsOfFile: path!)
        
        let parser = APIClient()
        var results = parser.parseJSON(data!)
        
        XCTAssertNotNil(results)
        let opponentNameArray = results!["opponentNameArray"] as AnyObject as! [String]
        XCTAssertEqual(9, opponentNameArray.count)
        
        path = bundle.pathForResource("loadGameData", ofType: "json")
        data = NSData(contentsOfFile: path!)
        results = parser.parseJSON(data!)

        XCTAssertNotNil(results)

        XCTAssertEqual(0, results!["gameChatEditable"])
        
        let log = results!["gameChatLog"] as AnyObject as! [[String: AnyObject]]
        XCTAssertEqual(8, log.count)
    }
    
    func testParseInvalidResults() {
            let bundle = NSBundle(forClass: self.dynamicType)
            let path = bundle.pathForResource("invalid", ofType: "json")
            let data = NSData(contentsOfFile: path!)
            
            let parser = APIClient()
            let results = parser.parseJSON(data!)
            XCTAssertNil(results)
    }
    
}

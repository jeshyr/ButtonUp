//
//  ParseDieData
//  Button Up
//
//  Created by Ricky Buchanan on 19/12/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import XCTest
@testable import Button_Up

class ParseDieData: XCTestCase {
    func testParseGamePlayerDataArray() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("dieData", ofType:
            "json")
        let data = NSData(contentsOfFile: path!)
        
        let parser = APIClient()
        let results = parser.parseJSON(data!)
        let die = parser.parseDieData(results as! [String: AnyObject])
        
        XCTAssertNotNil(die)
        
            //{"value":1,"sides":4,"skills":["Focus","Null","Speed"],"properties":[],"recipe":"fnz(4)","description":"Focus Null Speed 4-sided die"}
        XCTAssertEqual(1, die!.value)
        XCTAssertEqual(4, die!.sides)
        XCTAssertEqual("Focus Null Speed 4-sided die", die!.text)
    }
    
}

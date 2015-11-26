//
//  SkillTests.swift
//  Button Up
//
//  Created by Ricky Buchanan on 26/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import XCTest

class SkillTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSkillShortInit() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let skill = Skill(skill: "B")
        
        XCTAssertEqual(skill!.short, "B")
        XCTAssertEqual(skill!.description, "Berserk")
        
    }
    
    func testSkillLongInit() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let skill = Skill(skill: "Berserk")
        
        XCTAssertEqual(skill!.short, "B")
        XCTAssertEqual(skill!.description, "Berserk")
        
    }
    
    func testSkillInvalidInit() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let skill = Skill(skill: "Beserk")
        
        XCTAssertNil(skill)
        
    }
    
}

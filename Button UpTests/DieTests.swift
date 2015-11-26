//
//  DieTests.swift
//  Button Up
//
//  Created by Ricky Buchanan on 26/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import XCTest

class DieTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRecipeExtractionExpansion() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var die = Die()
        die.recipe = "B(U)"
        die.sides = 10
        die.skills.append(Skill(skill: "Berserk"))
        
        XCTAssertEqual(die.coreRecipe, "U")
        XCTAssertEqual(die.expandedCoreRecipe, "U=10")
        XCTAssertEqual(die.description, "B(U=10)")
    }
    
}

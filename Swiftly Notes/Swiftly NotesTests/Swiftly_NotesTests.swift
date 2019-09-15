//
//  Swiftly_NotesTests.swift
//  Swiftly NotesTests
//
//  Created by Michal Géci on 12/09/2019.
//  Copyright © 2019 Michal Géci. All rights reserved.
//

import XCTest
@testable import Swiftly_Notes

class Swiftly_NotesTests: XCTestCase {

    func testMapping() {
        let id = 0
        let title = ""
        
        let dict: [String: Any] = ["id": id, "title": title]
        
        do {
            let model = try RestAPI.mapDictToNoteModel(dict: dict)
            XCTAssertEqual(model?.id, id, "Wrong ID in model")
            XCTAssertEqual(model?.title, title, "Wrong title in model")
        } catch {
            XCTFail("Mapping failed")
        }
    }
    
    func testGetAllNotes() {
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        
        RestAPI.getAllNotes { (notes, err) in
            error = err
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 5)
        XCTAssertNil(error)
    }

}

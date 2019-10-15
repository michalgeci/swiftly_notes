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

    func testNoteMapping1() {
        let id: Int? = 0
        let title: String? = ""
        
        checkMapping(id: id, title: title)
    }
    
    func testNoteMapping2() {
        let id: Int? = nil
        let title: String? = ""
        
        checkMapping(id: id, title: title)
    }
    
    func testNoteMapping3() {
        let id: Int? = 0
        let title: String? = nil
        
        checkMapping(id: id, title: title)
    }
    
    func checkMapping(id: Int?, title: String?) {
        let note = NoteModel(id: id, title: title)
        
        do {
            let data = RestAPI.createJSONData(from: note)
            guard let dataU = data else {
                XCTFail("Failed durnig encoding data")
                return
            }
            let mappedNote = try JSONDecoder().decode(NoteModel.self, from: dataU)
            XCTAssertEqual(mappedNote.id, id, "Wrong ID in model")
            XCTAssertEqual(mappedNote.title, title, "Wrong title in model")
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

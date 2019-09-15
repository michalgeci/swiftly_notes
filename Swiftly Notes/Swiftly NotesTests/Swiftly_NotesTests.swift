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
            XCTFail("Mapping failer")
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
    
    func testOtherRestCalls() {
        let text1 = "TestNote"
        let text2 = "TestNoteEdited"
        
        // Test create note
        RestAPI.createNote(text: text1) { (model1, error1) in
            if error1 != nil {
                XCTFail()
            }
            XCTAssertEqual(model1?.title, text1, "Wrong text when creating note.")
            XCTAssertNotNil(model1?.id, "Newly created note is missing ID")
            
            // Test get note
            RestAPI.getNoteById(id: model1!.id, completion: { (model2, error2) in
                if error2 != nil {
                    XCTFail()
                }
                XCTAssertEqual(model2?.title, text1, "Wrong text when get note.")
                XCTAssertNotNil(model2?.id, "Getted note is missing ID")
                
                // Test edit note
                RestAPI.updateNoteWithId(id: model2!.id, text: text2, completion: { (model3, error3) in
                    if error3 != nil {
                        XCTFail()
                    }
                    
                    XCTAssertEqual(model3?.title, text2, "Wrong text when editing note.")
                    XCTAssertNotNil(model3?.id, "Edited note is missing ID")
                    
                    RestAPI.removeNoteById(id: model3!.id, completion: { (error4) in
                        XCTAssertNil(error4, "Error when deleting note.")
                    })
                })
                
            })
            
        }
        
    }

}

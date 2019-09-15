//
//  RestAPI+Extension.swift
//  Swiftly Notes
//
//  Created by Michal Géci on 14/09/2019.
//  Copyright © 2019 Michal Géci. All rights reserved.
//

import Foundation

extension RestAPI {
    
    /** List all notes */
    static func getAllNotes(completion: @escaping (_ response: [NoteModel]?, _ error: Error?) -> Void) {
        baseRequest(method: .get, url: BASE_URL + "/notes") { data, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data as? [[String: Any]] else {
                completion(nil, mappingError)
                return
            }
            
            // Mapping response
            do {
                let parsedData = try data.map{ try mapDictToNoteModel(dict: $0) }
                if let parsedData = parsedData as? [NoteModel] {
                    completion(parsedData, nil)
                }
            } catch {
                completion(nil, mappingError)
            }
        }
    }
    
    
    /** Create new note, return created note */
    static func createNote(text: String, completion: @escaping (_ response: NoteModel? ,_ error: Error?) -> Void) {
        
        // Create body
        guard let body = createNoteBody(text: text) else {
            completion(nil, RestAPI.jsonError)
            return
        }
        
        // Call base request
        baseRequest(method: .post, url: BASE_URL + "/notes", body: body, headers: nil) { (response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let dict = response as? [String: Any] else {
                completion(nil, mappingError)
                return
            }
            
            do {
                let model = try mapDictToNoteModel(dict: dict)
                completion(model, nil)
            } catch {
                completion(nil, mappingError)
            }
        }
    }
    
    
    /** Retrieve a note */
    static func getNoteById(id: Int, completion: @escaping (_ response: NoteModel? ,_ error: Error?) -> Void) {
        baseRequest(method: .get, url: BASE_URL + "/notes/\(id)") { (response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let dict = response as? [String: Any] else {
                completion(nil, mappingError)
                return
            }
            
            do {
                let model = try mapDictToNoteModel(dict: dict)
                completion(model, nil)
            } catch {
                completion(nil, mappingError)
            }
        }
    }
    
    
    /** Update a note */
    static func updateNoteWithId(id: Int, text: String, completion: @escaping (_ note: NoteModel?, _ error: Error?) -> Void) {
        
        guard let body = createNoteBody(text: text) else {
            completion(nil, RestAPI.jsonError)
            return
        }
        
        // Call  base request
        baseRequest(method: .put, url: BASE_URL + "/notes/\(id)", body: body) { (response, error) in
            // check for error
            if let error = error {
                completion(nil, error)
                return
            }
            
            // cast response to dict
            guard let dict = response as? [String: Any] else {
                completion(nil, mappingError)
                return
            }
            
            // map dict to model
            do {
                let model = try mapDictToNoteModel(dict: dict)
                completion(model, nil)
            } catch {
                completion(nil, mappingError)
            }
        }
    }
    
    /** Remove a note */
    static func removeNoteById(id: Int, completion: @escaping (_ error: Error?) -> Void) {
        // Call base request
        baseRequest(method: .delete, url: BASE_URL + "/notes/\(id)", expectResponseBody: false) { (response, error) in
            // check for error
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
}

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
            
            // Check error
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            // Check nil response
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, mappingError)
                }
                return
            }
            
            // Map response to model
            do {
                let parsedData = try JSONDecoder().decode([NoteModel].self, from: data)
                DispatchQueue.main.async {
                    completion(parsedData, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, mappingError)
                }
            }
            
        }
    }
    
    
    /** Create new note, return created note */
    static func createNote(text: String, completion: @escaping (_ response: NoteModel? ,_ error: Error?) -> Void) {
        
        // Create body
        let note = NoteModel(id: nil, title: text)
        guard let body = createJSONData(from: note) else {
            completion(nil, RestAPI.jsonError)
            return
        }
        
        // Call base request
        baseRequest(method: .post, url: BASE_URL + "/notes", body: body, headers: nil) { (response, error) in
            
            // Check error
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            // Check nil response
            guard let data = response else {
                DispatchQueue.main.async {
                    completion(nil, mappingError)
                }
                return
            }
            
            // Map response to model
            do {
                let model = try JSONDecoder().decode(NoteModel.self, from: data)
                DispatchQueue.main.async {
                    completion(model, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, mappingError)
                }
            }
        }
    }
    
    
    /** Retrieve a note */
    static func getNoteById(id: Int, completion: @escaping (_ response: NoteModel? ,_ error: Error?) -> Void) {
        baseRequest(method: .get, url: BASE_URL + "/notes/\(id)") { (response, error) in
            
            // Check error
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Check nil response
            guard let data = response else {
                DispatchQueue.main.async {
                    completion(nil, mappingError)
                }
                return
            }
            
            // Map response to model
            do {
                let model = try JSONDecoder().decode(NoteModel.self, from: data)
                DispatchQueue.main.async {
                    completion(model, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, mappingError)
                }
            }
        }
    }
    
    
    /** Update a note */
    static func updateNoteWithId(id: Int, text: String, completion: @escaping (_ note: NoteModel?, _ error: Error?) -> Void) {
        
        // Create request body
        let note = NoteModel(id: id, title: text)
        guard let body = createJSONData(from: note) else {
            DispatchQueue.main.async {
                completion(nil, RestAPI.jsonError)
            }
            return
        }
        
        // Call  base request
        baseRequest(method: .put, url: BASE_URL + "/notes/\(id)", body: body) { (response, error) in
            // Check error
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Check nil response
            guard let data = response else {
                DispatchQueue.main.async {
                    completion(nil, mappingError)
                }
                return
            }
            
            // Map response to model
            do {
                let model = try JSONDecoder().decode(NoteModel.self, from: data)
                DispatchQueue.main.async {
                    completion(model, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, mappingError)
                }
            }
        }
    }
    
    
    /** Remove a note */
    static func removeNoteById(id: Int, completion: @escaping (_ error: Error?) -> Void) {
        // Call base request
        baseRequest(method: .delete, url: BASE_URL + "/notes/\(id)", expectResponseBody: false) { (response, error) in
            // Check error
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }

}

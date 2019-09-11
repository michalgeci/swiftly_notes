//
//  NotesAPI.swift
//  Swiftly Notes
//
//  Created by Michal Géci on 10/09/2019.
//  Copyright © 2019 Michal Géci. All rights reserved.
//

import UIKit

class RestAPI {
    
    // MARK: - Common
    
    /** Base url for requests */
    static let BASE_URL = "https://private-9aad-note10.apiary-mock.com" //"https://private-c855e-note10.apiary-mock.com"
    
    /** Http methods */
    enum HttpMethod: String {
        case delete = "DELETE"
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    // Error types
    private static let jsonError = NSError(domain: "JSONSerialization error", code: 1, userInfo: nil)
    private static let mappingError = NSError(domain: "Error During mapping", code: 2, userInfo: nil)
    
    
    
    // MARK: Help functions
    
    /** Base request used for api, maps JSON response */
    static func baseRequest(method: HttpMethod, url: String, body: Data? = nil, expectResponseBody: Bool = true, headers: [String:String]? = nil, completion: @escaping (_ jsonData: Any?, _ error: Error?) -> Void ) {
        
        guard let url = URL(string: url) else {
            print("Could not create url.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            #if DEBUG
            // Print data for debugging purposes
            print(response ?? "Error while printing response")
            print(String(data: data ?? Data(), encoding: .utf8) ?? "Error while printing data")
            #endif
            
            if let error = error {
                completion(nil, error)
            }
            
            if expectResponseBody {
                do {
                    guard let data = data else {
                        print("NO DATA TO PARSE")
                        return
                    }
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    completion(json, nil)
                } catch {
                    completion(nil, jsonError)
                }
            }
            
            completion(nil, nil)
        }
        task.resume()
    }
    
    
    /** Map dictionary to NoteModel */
    private static func mapDictToNoteModel(dict: [String: Any]) throws -> NoteModel? {
        var id: Int?
        var title: String?
        do {
            guard let _id = dict["id"] as? Int else {
                throw mappingError
            }
            guard let _title = dict["title"] as? String else {
                throw mappingError
            }
            
            id = _id
            title = _title
        }
        
        if let id = id, let title = title {
            return NoteModel(id: id, title: title)
        }
        
        return nil
    }
    
    
    
    // MARK: - Specific request calls
    
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
        
        // Create body of request
        let dictBody = ["title", text]
        var body: Data?
        do {
            body = try JSONSerialization.data(withJSONObject: dictBody, options: [])
        } catch {
            completion(nil, jsonError)
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
        // Create body of request
        let dictBody = ["title", text]
        var body: Data?
        do {
            body = try JSONSerialization.data(withJSONObject: dictBody, options: [])
        } catch {
            completion(nil, jsonError)
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

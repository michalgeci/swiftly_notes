//
//  NotesAPI.swift
//  Swiftly Notes
//
//  Created by Michal Géci on 10/09/2019.
//  Copyright © 2019 Michal Géci. All rights reserved.
//

import Foundation

class RestAPI {
    
    // MARK: - Common
    
    /** Base url for requests */
    static let BASE_URL = "https://swiftly-notes.herokuapp.com"
    //"http://localhost:8080"
    //"https://private-9aad-note10.apiary-mock.com"
    //"https://private-c855e-note10.apiary-mock.com"
    
    /** Http methods */
    enum HttpMethod: String {
        case delete = "DELETE"
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    // Error types
    static let jsonError = NSError(domain: "JSONSerialization error", code: 1, userInfo: nil)
    static let mappingError = NSError(domain: "Error During mapping", code: 2, userInfo: nil)
    
    
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
            } else {
                completion(nil, nil)
            }
        }
        task.resume()
    }
    
    
    /** Map dictionary to NoteModel */
    static func mapDictToNoteModel(dict: [String: Any]) throws -> NoteModel? {
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
    
    /** Create JSON Data object */
    static func createJsonDataObject(obj: Any) -> Data? {
        var body: Data?
        do {
            body = try JSONSerialization.data(withJSONObject: obj, options: [])
            return body
        } catch {
            return nil
        }
    }
    
    
    /** Create body of note for request */
    static func createNoteBody(text: String) -> Data? {
        let dictBody = ["title": text]
        return createJsonDataObject(obj: dictBody)
    }
    
}

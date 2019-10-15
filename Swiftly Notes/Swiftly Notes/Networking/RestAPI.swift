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
    
    
    // MARK: - Help functions
    
    /** Base request used for api, maps JSON response */
    static func baseRequest(method: HttpMethod, url: String, body: Data? = nil, expectResponseBody: Bool = true, headers: [String:String]? = nil, completion: @escaping (_ jsonData: Data?, _ error: Error?) -> Void ) {
        
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
            let requestStr = "\(method.rawValue) \(request)"
            let body = body != nil ? String(data: body!, encoding: .utf8) ?? "Empty Body" : "Empty Body"
            let responseDataStr = String(data: data ?? Data(), encoding: .utf8) ?? "Error while printing data"
            let debugString = "\n\n----------\nREST CALL BEGIN\n\(requestStr)\n\(body)\n\(responseDataStr)\nREST CALL END\n----------\n\n"
            print(debugString)
            #endif
            
            if let error = error {
                completion(nil, error)
            }
            
            if expectResponseBody {
                guard let data = data else {
                    print("NO DATA TO PARSE")
                    return
                }
                completion(data, nil)
            } else {
                completion(nil, nil)
            }
        }
        task.resume()
    }

    /** Create JSON Data object */
    static func createJSONData<T: Codable>(from: T) -> Data? {
        do {
            let data = try JSONEncoder().encode(from)
            return data
        } catch {
            return nil
        }
    }
}

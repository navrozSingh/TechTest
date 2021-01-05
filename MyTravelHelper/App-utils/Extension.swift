//
//  URL+Extension.swift
//  MyTravelHelper
//
//  Created by Navroz on 04/01/21.
//  Copyright © 2021 Sample. All rights reserved.
//

import Foundation
import XMLParsing

extension URL {
    static var baseUrl: URL {
        guard let url = URL(string: "http://api.irishrail.ie/") else {
            fatalError("Invalid base URL")
        }
        return url
    }
    mutating func addPath(_ path: String) {
        guard var urlComponents = URLComponents(string: absoluteString) else { return }
        urlComponents.path = path
        self = urlComponents.url ?? self
    }
    mutating func appendQueryItem(_ name: String, value: String?) {
        guard var urlComponents = URLComponents(string: absoluteString) else { return }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        let queryItem = URLQueryItem(name: name, value: value)
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems
        self = urlComponents.url ?? self
    }
}

extension URLSession {
    func perform<T: Decodable>(_ request: URLRequest,
                               decode decodable: T.Type,
                               result: @escaping (Result<T, Error>) -> Void) {
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data
                else {
                    result(.failure(NSError.nilData))
                    return
                }
            guard let object = try? XMLDecoder().decode(decodable.self, from: data)
                else {
                    debugPrint(String(decoding: data, as: UTF8.self))
                    result(.failure(NSError.badResponse))
                    return
                }
            debugPrint(String(decoding: data, as: UTF8.self))
            result(.success(object))
        }.resume()
    }
}

extension NSError {
    static let nilData = NSError(domain: "com.example.com.MyTravelHelper",
                                 code: 404,
                                 userInfo: [NSLocalizedDescriptionKey : "Data is nil"])
    static let badResponse = NSError(domain: "com.example.com.MyTravelHelper",
                                 code: 400,
                                 userInfo: [NSLocalizedDescriptionKey : "Unable to decode response"])
    static let noNetwork = NSError(domain: "com.example.com.MyTravelHelper",
                                     code: -1009,
                                     userInfo: [NSLocalizedDescriptionKey : "The Internet connection appears to be offline."])
}


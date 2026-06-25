//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 14/06/26.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentaion: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: URLRequest(url: url)) { data, response, error in
            completion(Result {
                if let error {
                    throw error
                } else if let data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentaion()
                }
            })
        }.resume()
    }
}

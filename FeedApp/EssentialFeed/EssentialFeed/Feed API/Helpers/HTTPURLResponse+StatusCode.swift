//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 26/07/26.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { 200 }
    
    var isOK: Bool {
        statusCode == HTTPURLResponse.OK_200
    }
}

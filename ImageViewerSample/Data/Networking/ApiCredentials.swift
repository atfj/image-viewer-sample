//
//  ApiCredentials.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/14/25.
//

import Foundation

extension Bundle {
    var baseURL: URL {
        guard let str = object(forInfoDictionaryKey: "API_BASE_URL") as? String, let url = URL(string: str) else {
            fatalError("API_BASE_URL in Info.plist is not found")
        }
        return url
    }
    
    var apiKey: String {
        guard let str = object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("API_KEY in Info.plist is not found")
        }
        return str
    }
}

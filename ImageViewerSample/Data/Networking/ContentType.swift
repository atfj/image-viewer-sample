//
//  ContentType.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

import Foundation

enum ContentType {
    case none
    case fromURLEncoded
    case json

    var headerValue: String {
        switch self {
        case .none:
            return ""
        case .fromURLEncoded:
            return "application/x-www-form-urlencoded; charset=utf-8"
        case .json:
            return "application/json"
        }
    }
}

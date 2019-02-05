//
//  URLDetection.swift
//  Wistia
//
//  Created by Jake Young on 2/5/19.
//

import Foundation

extension String {
    public static let jiraIssueKeyRegex = "/((?!([A-Z0-9a-z]{1,10})-?$)[A-Z]{1}[A-Z0-9]+-\\d+)/g"
    public static let wistiaURLRegex = "https?:\\/\\/(.+)?(wistia\\.com|wi\\.st)\\/.*"
}

extension String {
    /// Accepts a regex pattern and returns an array of matches.
    public func substringsMatchingRegexPattern(_ regex: String) -> [String] {
        let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive)
        let matches = regex?.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) ?? []
        let strings = matches.map { (self as NSString).substring(with: $0.range) }
        return strings
    }
    /// Finds all the fully formed wistia URLs in a block of text.
    ///
    /// - Returns: an array of the urls as strings.
    public func wistiaURLsDetected() -> [String] {
        return self.substringsMatchingRegexPattern(.wistiaURLRegex)
    }
}

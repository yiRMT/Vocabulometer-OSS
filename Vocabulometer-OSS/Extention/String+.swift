//
//  String+.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/10/12.
//

import Foundation

extension String {
    func match(_ pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count))
        else { return [] }
        return (0 ..< matched.numberOfRanges).map {
            NSString(string: self).substring(with: matched.range(at: $0))
        }
    }
}

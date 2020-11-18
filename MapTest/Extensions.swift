//
//  Extensions.swift
//  MapTest
//
//  Created by Maksim Kalik on 18/11/2020.
//

import UIKit

extension StringProtocol {
    // Split a String into the Sequence
    // by separator newline: \n
    var byLines: [SubSequence] { split(whereSeparator: \.isNewline) }
    // by separator semicolon
    var bySemicolon: [SubSequence] { split(separator: ";")}
    
    // Return first word string from the string
    func firstWord() -> String? {
        return self.components(separatedBy: " ").first
    }
    
    // Remove substring from the string
    func removeSubstring(_ substring: String) -> String? {
        // Replacing solution+ + trim whitespaces
        self.replacingOccurrences(of: substring, with: "").trimmingCharacters(in: .whitespaces)
    }
}

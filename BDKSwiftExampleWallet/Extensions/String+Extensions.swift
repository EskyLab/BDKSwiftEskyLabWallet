//
//  String+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import Foundation

extension String {
    var formattedWithSeparator: String {
        guard let number = Int(self) else { return self }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.string(from: NSNumber(value: number)) ?? self
    }
    
    /// Adds the separator for each 3 digits and ensures the decimal part is correctly formatted.
    func formattedDecimalWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        
        if let number = Double(self) {
            return formatter.string(from: NSNumber(value: number)) ?? self
        }
        
        return self
    }
    
    /// Truncates a string and appends ellipses if it exceeds a certain length
    func truncated(to length: Int, addEllipsis: Bool = true) -> String {
        if self.count > length {
            let truncatedString = self.prefix(length)
            return addEllipsis ? "\(truncatedString)..." : String(truncatedString)
        } else {
            return self
        }
    }
    
    /// Converts a string to a URL-safe format by encoding special characters.
    var urlEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
    
    /// Returns the string with whitespace and newline characters trimmed from both ends.
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

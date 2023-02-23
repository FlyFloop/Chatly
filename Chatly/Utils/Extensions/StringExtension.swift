//
//  StringExtension.swift
//  Chatly
//
//  Created by Alper Yorgun on 11.02.2023.
//

import Foundation


extension String {
    func convertToTimeInterval() -> TimeInterval {
        guard self != "" else {
            return 0
        }

        var interval:Double = 0

        let parts = self.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }
     

        return interval
    }
}

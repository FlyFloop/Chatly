//
//  DateManager.swift
//  Chatly
//
//  Created by Alper Yorgun on 7.02.2023.
//

import Foundation


struct DateManager {
    static func getCurrentDateWithLocaleString() -> String {
        let date = Date.localDate()
        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = StringConstants.dateFormatString

        // Convert Date to String
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
}

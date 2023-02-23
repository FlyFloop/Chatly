//
//  DateExtension.swift
//  Chatly
//
//  Created by Alper Yorgun on 7.02.2023.
//


import Foundation




extension Date {
    static func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {
            return nowUTC
        }
        return localDate
    }
}

//
//  Date+RelativeTimestamp.swift
//
//
//  Created by John Behnke on 10/8/23.
//

import Foundation

extension Date {
    func relativeTimestamp() -> String {
        let calendar = Calendar.current
        let minutes = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hours = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let days = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weeks = calendar.date(byAdding: .day, value: -7, to: Date())!
        if minutes < self {
            return "Just Now"
        } else if hours < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) \(diff == 1 ? "minute" : "minutes") ago"
        } else if days < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) \(diff == 1 ? "hour" : "hours") ago"
        } else if weeks < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) \(diff == 1 ? "day" : "days") ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) \(diff == 1 ? "week" : "weeks") ago"
    }
}

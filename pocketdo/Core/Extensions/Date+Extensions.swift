// MARK: - File: Core/Extensions/Date+Extensions.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    var isOverdue: Bool {
        self < Date() && !isToday
    }
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// Human-friendly relative date string (Today, Yesterday, Tomorrow, or date)
    var relativeDateString: String {
        if isToday     { return "Today" }
        if isYesterday { return "Yesterday" }
        if isTomorrow  { return "Tomorrow" }
        let df = DateFormatter()
        df.dateFormat = isThisWeek ? "EEEE" : "MMM d"
        return df.string(from: self)
    }

    /// Short time string: "3:45 PM"
    var timeString: String {
        let df = DateFormatter()
        df.timeStyle = .short
        return df.string(from: self)
    }

    /// Full short date: "Apr 15"
    var shortDateString: String {
        let df = DateFormatter()
        df.dateFormat = "MMM d"
        return df.string(from: self)
    }

    /// Full date + time: "Apr 15 at 3:45 PM"
    var fullDateTimeString: String {
        let df = DateFormatter()
        df.dateFormat = "MMM d 'at' h:mm a"
        return df.string(from: self)
    }

    /// Section header in history — groups completed tasks
    var sectionHeaderString: String {
        if isToday     { return "Today" }
        if isYesterday { return "Yesterday" }
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMM d"
        return df.string(from: self)
    }

    /// Deadline label — shows urgency
    var deadlineLabel: String {
        if isOverdue { return "Overdue · \(shortDateString)" }
        return relativeDateString
    }

    /// Days remaining (positive = future, negative = overdue)
    var daysFromNow: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: self)).day ?? 0
    }
}

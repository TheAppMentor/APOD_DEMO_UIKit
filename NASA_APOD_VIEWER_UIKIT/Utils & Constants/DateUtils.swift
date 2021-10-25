//
//  DateUtils.swift
//  NASA_APOD_VIEWER_UIKIT
//

import Foundation

struct DateUtils {

    static func getStringFromDate(date: Date) -> String {

        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy-MM-dd"

        dateF.dateStyle = .long
        return dateF.string(from: date)
    }
}

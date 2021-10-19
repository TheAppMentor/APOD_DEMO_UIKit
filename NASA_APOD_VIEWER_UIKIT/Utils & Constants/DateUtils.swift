//
//  DateUtils.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 19/10/21.
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

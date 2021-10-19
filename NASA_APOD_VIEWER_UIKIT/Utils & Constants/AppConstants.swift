//
//  AppConstants.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 19/10/21.
//

import Foundation

struct Constants {
    static let apiRequestBatchSize = 5
    static let autoScrollTimerDuration: TimeInterval = 10
    static let imageCachedCount = 10
}

struct ErrorMessage {
    static let rateLimitError = "APOD API rate limit reached for DEMO_KEY. Please try later."
    static let genericAPIError = "APOD API failure, please try relaunching the app."
}

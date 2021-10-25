//
//  AppConstants.swift
//  NASA_APOD_VIEWER_UIKIT
//

import Foundation

struct Constants {
    static let apiRequestBatchSize = 8
    static let autoScrollTimerDuration: TimeInterval = 10
    static let imageCachedCount = 12
    
    static let stopScroll = "Stop Scroll"
    static let autoScroll = "Auto Scroll"
}

struct ErrorMessage {
    static let rateLimitError = "APOD API rate limit reached for DEMO_KEY. Please try later."
    static let genericAPIError = "APOD API failure, please try relaunching the app."
}

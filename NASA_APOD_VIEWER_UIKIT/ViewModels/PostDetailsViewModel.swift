//
//  PostDetailsViewModel.swift
//  NASA_APOD_VIEWER_UIKIT
//

import Foundation
import nasa_apod_dataservice

class PostDetailsViewModel {
    let title: String
    let dateString: String
    let copyright: String?
    let explanation: String
    
    init(post: Post) {
        self.title = post.title
        self.dateString = DateUtils.getStringFromDate(date: post.date)
        self.copyright = post.copyright
        self.explanation = post.explanation
    }
}

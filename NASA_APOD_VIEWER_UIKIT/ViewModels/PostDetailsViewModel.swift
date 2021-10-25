//
//  PostDetailsViewModel.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 20/10/21.
//

import Foundation
import nasa_apod_dataservice
import Combine

//TODO: Does these need to be published?
class PostDetailsViewModel : ObservableObject {
    @Published var title: String
    @Published var dateString: String
    @Published var copyright: String?
    @Published var explanation: String
    
    init(post : Post) {
        self.title = post.title
        self.dateString = DateUtils.getStringFromDate(date: post.date)
        self.copyright = post.copyright
        self.explanation = post.explanation
    }
}

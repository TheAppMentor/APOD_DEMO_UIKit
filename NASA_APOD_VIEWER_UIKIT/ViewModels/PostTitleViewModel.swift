//
//  TitleViewModel.swift
//  NASA_APOD_VIEWER_UIKIT
//

import Foundation
import Combine
import nasa_apod_dataservice

class PostTitleViewModel : ObservableObject {
    
    @Published var title: String
    
    init(post: Post) {
        title = post.title
    }
}

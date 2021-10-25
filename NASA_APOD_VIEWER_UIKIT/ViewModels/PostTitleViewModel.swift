//
//  TitleViewModel.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 20/10/21.
//

import Foundation
import Combine
import nasa_apod_dataservice

enum TitleState {
    case loadingImage
    case loadingAll
    case displayTitle
    case error
}

class PostTitleViewModel : ObservableObject {
    
    @Published var title: String
    @Published var state: TitleState
    
    init(post: Post, state: TitleState) {
        title = post.title
        self.state = state
    }
}

//
//  PostViewModel.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 20/10/21.
//

import Foundation
import nasa_apod_dataservice

class PostViewModel {
    let postTitleViewModel : Dynamic<PostTitleViewModel>
    var postDetailsViewModel : Dynamic<PostDetailsViewModel>
    //var postImageViewModel : Dynamic<PostImageViewModel>
    
    init(post : Post) {
        // Init Post Title View Model
        let postTitleViewModel = PostTitleViewModel(post: post, state: .loadingAll)
        self.postTitleViewModel = Dynamic(postTitleViewModel)
        
        // Init Post Details View Model
        let postDetailsViewModel = PostDetailsViewModel(post: post)
                
    }
    
}

class PostImageViewModel {
    
}

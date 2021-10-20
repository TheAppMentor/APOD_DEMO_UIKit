//
//  PostDetailsViewModel.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 20/10/21.
//

import Foundation
import nasa_apod_dataservice

class PostDetailsViewModel {
    let title: Dynamic<String>
    let dateString: Dynamic<String>
    let copyright: Dynamic<String?>
    let explanation: Dynamic<String>
    
    init(post : Post) {
        self.title = Dynamic(post.title)
        self.dateString = Dynamic(DateUtils.getStringFromDate(date: post.date))
        self.copyright = Dynamic(post.copyright)
        self.explanation = Dynamic(post.explanation)
    }
}

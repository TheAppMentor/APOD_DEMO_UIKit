//
//  TitleViewModel.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 20/10/21.
//

import Foundation
import nasa_apod_dataservice

enum TitleState {
    case loadingImage
    case loadingAll
    case displayTitle
    case error
}

import Combine

class PostTitleViewModel : ObservableObject {
    
    @Published var pubTitle : String
    @Published var pubState : TitleState
    var title: Dynamic<String>
    let state: Dynamic<TitleState>
    
    var someTimer : Timer?

    init(post: Post, state: TitleState) {
        title = Dynamic(post.title)
        self.state = Dynamic(state)
        
        self.pubTitle = post.title
        self.pubState = state

//        DispatchQueue.main.async {
//            self.someTimer = .scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.changeValue), userInfo: nil, repeats: true)
//        }
    }
    
//    @objc func changeValue() {
//        let some = [0,1,2,3,4,5,10].randomElement()!
//        print("View Model : Change Value : \(some)")
//        title.value = "\(some)"
//    }
}

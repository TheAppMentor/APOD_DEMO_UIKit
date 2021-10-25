//
//  PostViewModel.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 20/10/21.
//

import Foundation
import nasa_apod_dataservice
import UIKit

class PostViewModel {
    
    private let apodService = NASA_APOD_Service()
    private var allPosts = [Post]()
    
    private var indexOfSelectedPost = 0
    
    var postboy : PostTitleViewModel!
    
    var postTitleViewModel : Dynamic<PostTitleViewModel>!
    var postDetailsViewModel : Dynamic<PostDetailsViewModel>!
    var postImageViewModel : Dynamic<PostImageViewModel>!
    
    var someTimer : Timer!
    
    init() async {
        do {
            print("PostViewModel : Init was called")
            let fetchedPosts = try await apodService.fetchAPODPost(count: Constants.apiRequestBatchSize)
            allPosts += fetchedPosts
            
            let currentPost = allPosts[indexOfSelectedPost]
            
            //TODO: Need a correct loading state for initial load.
            postTitleViewModel = Dynamic(PostTitleViewModel(post: currentPost, state: .loadingImage))
            print("PostViewModel : title view model is ready")

            postboy = PostTitleViewModel(post: currentPost, state: .loadingImage)
            
            self.postTitleViewModel.bindAndFire { [unowned self] in
                self.postTitleViewModel.value.title = $0.title 
            }

            postDetailsViewModel = Dynamic(PostDetailsViewModel(post: currentPost))
            print("PostViewModel : details view model is ready")

            
            // We dont want image fetching to block.
            //TODO: Fix this.
            // Add place holder image here.
            Task {
                let postImageViewModel = try! await PostImageViewModel(post: currentPost)
                self.postImageViewModel = Dynamic(postImageViewModel)
                print("PostViewModel : Now I have the image model")
            }
            print("PostViewModel : Exiting the Init method")
            
            DispatchQueue.main.async { //TODO: check Self
                self.someTimer = .scheduledTimer(timeInterval: 3.0,
                                                 target: self,
                                                 selector: #selector(self.changeValue),
                                                 userInfo: nil,
                                                 repeats: true)
            }
            
        } catch {
            assertionFailure()
            //TODO: Also Handle the offline scenario.
            //throw APODServiceError.httpError //TODO: Fix this man.
        }
    }
    
    var currentPost: Post {
        return allPosts[indexOfSelectedPost]
    }
    
    @objc func changeValue() {
        let some = [0,1,2,3,4,5,10].randomElement()!
        print("View Model : Change Value : \(some)")
        self.postTitleViewModel.value.title = Dynamic("\(some)")
        self.postboy.pubTitle = "\(some) = From Combine"
        self.postboy.pubState = [TitleState.loadingImage, TitleState.displayTitle].randomElement()!
        print("Pub State is : \(self.postboy.pubState)")
    }
}

class PostImageViewModel {
    var postImage : Dynamic<UIImage>
    
    init(post: Post) async throws {
        do {
            guard var imageURL = post.imageURLString else {
                throw ImageManagerError.urlConversionFailed //TODO:
            }
            
            let dummyImageURL = URL(string: "https://picsum.photos/200/300")!
            let postImage = try await ImageManager.shared.getImageFromURL(url: dummyImageURL)
            self.postImage = Dynamic(postImage)
        } catch {
            throw ImageManagerError.urlConversionFailed
        }
    }
}

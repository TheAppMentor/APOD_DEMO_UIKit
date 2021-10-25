//
//  PostViewModel.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 20/10/21.
//

import Foundation
import nasa_apod_dataservice
import UIKit

class PostViewModel : ObservableObject {
    
    private let apodService = NASA_APOD_Service()
    private var allPosts = [Post]()
    
    private var indexOfSelectedPost = 0 {
        
        didSet {
            if indexOfSelectedPost == allPosts.count - 1 {
                Task {
                    do {
                        try await fetchAPODData()
                    } catch {
                        //titleView.titleLabel.text = "Failed to fetch data from APOD API, please try later."
                    }
                }
            }
        }
    }
    
    @Published var postTitleViewModel : PostTitleViewModel!
    @Published var postDetailsViewModel : PostDetailsViewModel!
    @Published var postImageViewModel : PostImageViewModel!
    
    init() async {
        do {
            try await fetchAPODData()
            configureViewModels()
        } catch {
            assertionFailure()
            //TODO: Also Handle the offline scenario.
            //throw APODServiceError.httpError //TODO: Fix this man.
        }
    }
    
    var currentPost: Post {
        return allPosts[indexOfSelectedPost]
    }
    
    func configureViewModels() {
        let currentPost = allPosts[indexOfSelectedPost]
        
        //TODO: Need a correct loading state for initial load.
        postTitleViewModel = PostTitleViewModel(post: currentPost, state: .loadingImage)
        print("PostViewModel : title view model is ready")
        
        postDetailsViewModel = PostDetailsViewModel(post: currentPost)
        
        //postImageViewModel = PostImageViewModel(withPlaceHolder: true)
        // We dont want image fetching to block.
        //TODO: Fix this.
        // Add place holder image here.
        Task {
            let postImageViewModel = try! await PostImageViewModel(post: currentPost)
            self.postImageViewModel = postImageViewModel
            print("PostViewModel : Now I have the image model")
        }
        print("PostViewModel : Exiting the Init method")
    }
    
    func getNextPost() {
        indexOfSelectedPost += 1
        configureViewModels()
        
        // Fetch Next batch of Posts
    }
    
    func getPreviousPost() {
        if indexOfSelectedPost == 0 {
            return
        }
        indexOfSelectedPost -= 1
        configureViewModels()
    }
    
    func fetchAPODData() async throws {
        do {
            let fetchedPosts = try await NASA_APOD_Service().fetchAPODPost(count: Constants.apiRequestBatchSize)
            allPosts += fetchedPosts
        } catch {
            throw error
        }
        
        let sequence = AnySequence(allPosts)
        Task(priority: .userInitiated) {
            for post in sequence.dropFirst() {  // First Image is fetched manually
                guard let urlString = post.imageURLString,
                      let url = URL(string: urlString),
                      let _ = try? await ImageManager.shared.getImageFromURL(url: url) else {
                          continue
                      }
            }
        }
    }
}



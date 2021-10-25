//
//  PostViewModel.swift
//  NASA_APOD_VIEWER_UIKIT
//

import Foundation
import nasa_apod_dataservice
import UIKit

class PostViewModel : ObservableObject {
    
    @Published var postTitleViewModel : PostTitleViewModel!
    @Published var postDetailsViewModel : PostDetailsViewModel!
    @Published var postImageViewModel : PostImageViewModel!
    
    private let apodService = NASA_APOD_Service()
    private var allPosts = [Post]()
    
    private var scrollDirection = Position.center
    
    private var indexOfSelectedPost = 0 {
        didSet {
            if indexOfSelectedPost == allPosts.count - 1 {
                Task {
                    do {
                        try await fetchAPODData()
                    } catch APODServiceError.apodRateLimitHit {
                        self.postTitleViewModel.title = ErrorMessage.rateLimitError
                    } catch {
                        self.postTitleViewModel.title = ErrorMessage.genericAPIError
                    }
                }
            }
        }
    }
    
    init() async throws {
        do {
            try await fetchAPODData()
            configureViewModels()
        } catch APODServiceError.apodRateLimitHit {
            self.postTitleViewModel.title = ErrorMessage.rateLimitError
        } catch {
            self.postTitleViewModel.title = ErrorMessage.genericAPIError
        }
    }
    
    func getNextPost() {
        // We dont have any more posts to show yet.
        // Fetch of next batch is in progress.
        guard allPosts.count > indexOfSelectedPost + 1 else {
            return
        }
        
        indexOfSelectedPost += 1
        scrollDirection = .right
        configureViewModels()
    }
    
    func getPreviousPost() {
        if indexOfSelectedPost == 0 {
            return
        }
        indexOfSelectedPost -= 1
        scrollDirection = .left
        configureViewModels()
    }
    
    private var currentPost: Post {
        return allPosts[indexOfSelectedPost]
    }
    
    private func configureViewModels() {
        guard indexOfSelectedPost < allPosts.count else {
            assertionFailure()
            return
        }
        
        postTitleViewModel = PostTitleViewModel(post: currentPost)
        postDetailsViewModel = PostDetailsViewModel(post: currentPost)
        
        guard let imageURLString = currentPost.imageURLString,
              let imageURL = URL(string: imageURLString) else {
                  return
              }
            
        if let cachedImage = ImageManager.shared.getImageFromCache(url: imageURL) {
            let postVM = PostImageViewModel(image: cachedImage)
            postVM.scrollDirection = scrollDirection
            postVM.isPlaceHolder = false
            self.postImageViewModel = postVM
            return
        }
        
        
        let postVM = PostImageViewModel(image: ImageManager.placeHolderImage)
        postVM.scrollDirection = scrollDirection
        postVM.isPlaceHolder = true
        self.postImageViewModel = postVM
        
        // Kick off a background task to replace the image
        Task {
            do {
                // Wait of palce holder animation/tranistion to finish
                try await Task.sleep(nanoseconds: UInt64(0.6 * 1_000_000_000))
                let postVM = try await PostImageViewModel(post: currentPost)
                postVM.scrollDirection = .center
                postVM.isPlaceHolder = false
                self.postImageViewModel = postVM
            }
        }
    }
    
    private func fetchAPODData() async throws {
        do {
            let fetchedPosts = try await NASA_APOD_Service().fetchAPODPost(count: Constants.apiRequestBatchSize)
            // Retain only image media (no support for video)
            let filteredImagePosts = fetchedPosts.filter { $0.mediaType == MediaType.image}
            allPosts += filteredImagePosts
        } catch {
            throw error
        }
        
        // Warm up image cache.
        let sequence = AnySequence(allPosts)
        Task(priority: .userInitiated) {
            for post in sequence.dropFirst() {  // First Image is already fetched
                guard let urlString = post.imageURLString,
                      let url = URL(string: urlString),
                      let _ = try? await ImageManager.shared.getImageFromURL(url: url) else {
                          continue
                      }
            }
        }
    }
}



//
//  PostImageViewModel.swift
//  NASA_APOD_VIEWER_UIKIT
//

import Foundation
import UIKit
import nasa_apod_dataservice
import Combine

class PostImageViewModel {
    @Published var postImage : UIImage
    var scrollDirection = Position.center
    var isPlaceHolder : Bool = false
    
    init(image : UIImage) {
        self.postImage = image
    }
    
    init(post: Post) async throws {
        do {
            guard let imageURLString = post.imageURLString,
            let imageURL = URL(string: imageURLString) else {
                throw ImageManagerError.urlConversionFailed
            }
            
            let postImage = try await ImageManager.shared.getImageFromURL(url: imageURL)
            self.scrollDirection = .center
            self.postImage = postImage
        } catch {
            throw ImageManagerError.urlConversionFailed
        }
    }
}

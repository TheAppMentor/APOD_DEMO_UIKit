//
//  PostImageViewModel.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 25/10/21.
//

import Foundation
import UIKit
import nasa_apod_dataservice
import Combine

class PostImageViewModel {
    @Published var postImage : UIImage
   
    static let placeHolderImage: UIImage = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20,
                                                      weight: .ultraLight,
                                                      scale: .medium)
        let placeHolderImage = UIImage(systemName: "photo",
                                       withConfiguration: largeConfig)?.withTintColor(.lightGray,
                                                                                      renderingMode: .alwaysOriginal)
        return placeHolderImage!
    }()
    
    init(withPlaceHolder: Bool) {
        self.postImage = PostImageViewModel.placeHolderImage //TODO: Fix this.
    }
    
    init(post: Post) async throws {
        do {
            guard let imageURLString = post.imageURLString,
            let imageURL = URL(string: imageURLString) else {
                throw ImageManagerError.urlConversionFailed //TODO:
            }
            
            let postImage = try await ImageManager.shared.getImageFromURL(url: imageURL)
            self.postImage = postImage
        } catch {
            throw ImageManagerError.urlConversionFailed
        }
    }
    
    init(post: Post) throws {
        do {
            guard let imageURLString = post.imageURLString,
            let imageURL = URL(string: imageURLString) else {
                throw ImageManagerError.urlConversionFailed //TODO:
            }
            self.postImage = PostImageViewModel.placeHolderImage
            Task {
                let postImage = try await ImageManager.shared.getImageFromURL(url: imageURL)
                DispatchQueue.main.async {
                    self.postImage = postImage
                }
            }
        } catch {
            throw ImageManagerError.urlConversionFailed
        }
    }
}

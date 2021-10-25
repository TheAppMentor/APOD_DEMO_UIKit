//
//  File.swift
//  NASA_APOD_VIEWER_UIKIT
//
//

import Foundation
import UIKit

struct ImageManager {
    let imageCache = NSCache<NSString, UIImage>()
    
    static let shared = ImageManager()
    
    static let placeHolderImage: UIImage = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20,
                                                      weight: .ultraLight,
                                                      scale: .medium)
        let placeHolderImage = UIImage(systemName: "photo",
                                       withConfiguration: largeConfig)?.withTintColor(.lightGray,
                                                                                      renderingMode: .alwaysOriginal)
        return placeHolderImage!
    }()
    
    private init() {
        imageCache.countLimit = Constants.imageCachedCount
    }
    
    func getImageFromCache(url: URL) -> UIImage? {
        guard let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) else {
            return nil
        }
        
        return cachedImage
    }
    
    @discardableResult
    func getImageFromURL(url: URL) async throws -> UIImage {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            return cachedImage
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                      throw HTTPError.genericHTTPError
                  }
            guard let image = UIImage(data: data as Data) else {
                throw ImageManagerError.unknownError
            }
            imageCache.setObject(image, forKey: url.absoluteString as NSString)
            return image
            
        } catch {
            throw error
        }
    }
}

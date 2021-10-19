//
//  File.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 19/10/21.
//

import Foundation
import UIKit

struct ImageManager {
    let imageCache = NSCache<NSString, UIImage>()

    static let shared = ImageManager()

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
                      throw HTTPError.someError
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

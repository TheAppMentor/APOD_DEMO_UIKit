//
//  File.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 19/10/21.
//

import Foundation

struct ImageManager {
    let imageCache = NSCache<NSString, NSData>()
    
    static let shared = ImageManager()

    private init() {
        imageCache.countLimit = 6
    }
    
    func getImageFromURL(url : URL) async throws -> Data {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            return Data(cachedImage)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                      throw HTTPError.someError
                  }
            imageCache.setObject(data as NSData, forKey: url.absoluteString as NSString)
            return data

        }catch {
            throw error
        }
    }
}

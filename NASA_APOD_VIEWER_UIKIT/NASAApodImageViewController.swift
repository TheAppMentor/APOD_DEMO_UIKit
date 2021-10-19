//
//  ViewController.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 15/10/21.
//

import UIKit
import nasa_apod_dataservice

enum ImageManagerError : Error {
    case URLConversionFailed
    case UknownError
}

class NASAApodImageViewController: UIViewController {
    
    var allPosts = [Post]()
    
    var currentlyDisplayedPostIndex = 0 {
        didSet {
            if (currentlyDisplayedPostIndex == (allPosts.count - 1)) {
                Task{
                    await fetchAPODData()
                }
            }
        }
    }
    
    func getPostURL(urlString : String) throws -> URL {
        guard let url = URL(string: urlString) else {
            throw ImageManagerError.URLConversionFailed
        }
        return url
    }
    

    
    
    @IBOutlet weak var titleView: TitleView!
    @IBOutlet weak var carouselView : CarouselView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            await fetchAPODData()
            carouselView.delegate = self
            carouselView.setupImageView()
        }
        
        titleView.onTapAction = openDetailPanel
    }
    
    func fetchAPODData() async {
        do {
            let allPosts = try await NASA_APOD_Service().fetchAPODPost(count: 5)
            self.allPosts += allPosts
        } catch {
            print(error.localizedDescription)
        }
        
        let mySequnce = AnySequence(allPosts)
        
        Task(priority: .userInitiated) {
            for post in mySequnce.dropFirst() {  // First Image is fetched manually
                let urlString = post.imageURLString
                let url = URL(string: urlString!)!
                let _ = try! await ImageManager.shared.getImageFromURL(url: url)
            }
        }
    }
    
    func openDetailPanel() {
        let detailsVC = PostDetailsVC(postViewModel: allPosts[currentlyDisplayedPostIndex])
        
        let navController = UINavigationController(rootViewController: detailsVC)
        navController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        guard let formSheetController = navController.presentationController as? UISheetPresentationController else {
            return
        }
        formSheetController.detents = [.medium()]
        formSheetController.prefersGrabberVisible = true
        present(navController, animated: true, completion: nil)
    }
}


extension NASAApodImageViewController : CarouselDelegate {
    func getImageFromCache(index: Int) -> UIImage? {
        guard let imageURLString = allPosts[index].imageURLString,
              let postURL = try? getPostURL(urlString: imageURLString) else {
                  return nil
              }
        return ImageManager.shared.getImageFromCache(url: postURL)
    }
    
    var getTotalImageCount: Int {
        return allPosts.count
    }
    
    func getImage(index: Int) async throws -> UIImage {
        
        currentlyDisplayedPostIndex = index
        titleView.titleLabel.text = allPosts[currentlyDisplayedPostIndex].title
        
        guard let imageURLString = allPosts[index].imageURLString,
              let postURL = try? getPostURL(urlString: imageURLString) else {
                  throw ImageManagerError.UknownError
              }
        
        do {
            let fetchedImageData = try await ImageManager.shared.getImageFromURL(url: postURL)
            if let image = UIImage(data: fetchedImageData) {
                return image
            }
            throw ImageManagerError.UknownError
        } catch {
            throw error
        }
    }
    
}


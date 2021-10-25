//
//  ViewController.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 15/10/21.
//

import UIKit
import nasa_apod_dataservice
import Combine

class NASAApodImageViewController: UIViewController {
    
    var postViewModel : PostViewModel! {
        didSet {
            //TODO: Simplify this. Maybe move the post.
            configure(postTitleViewModel: postViewModel.postTitleViewModel, postDetailsViewModel : postViewModel.postDetailsViewModel)
        }
    }
    
    private var postTitleViewModel : PostTitleViewModel! {
        didSet {
            titleView.titleLabel.text = postTitleViewModel.title
        }
    }

    private var postDetailsViewModel : PostDetailsViewModel! {
        didSet {
            print("Post Details View Model Did Set : \(postDetailsViewModel.title)")
        }
    }
    
    private var postImageViewModel : PostImageViewModel! {
        didSet {
            DispatchQueue.main.async {
                guard let postImageViewModel = self.postImageViewModel else {
                    return
                }
                
                //print("Fetched Image : \(self.postImageViewModel.postImage.size)")
                print("Post image View Model did set.")
                if self.carouselView.presentedImageView != nil {
                    self.carouselView.currentImage = self.postImageViewModel.postImage
                    //self.carouselView.presentedImageView.image = self.postImageViewModel.postImage
                }
            }
        }
    }
    
    func configure(postTitleViewModel : PostTitleViewModel, postDetailsViewModel : PostDetailsViewModel) {
        
        self.postViewModel.$postTitleViewModel.sink { postTitleVM in
            self.postTitleViewModel = postTitleVM
            self.postTitleViewModel.title = postTitleVM!.title //TODO: this is not right, need to set the entire model.
            print("Next Title : \(self.postTitleViewModel.title)")
        }.store(in: &cancellables)
        
        self.postViewModel.$postDetailsViewModel.sink { postDetailsVM in
            self.postDetailsViewModel = postDetailsVM
        }.store(in: &cancellables)
        
        self.postViewModel.$postImageViewModel.sink { postImageVM in
            self.postImageViewModel = postImageVM
        }.store(in: &cancellables)
        
    }
    
    //var allPosts = [Post]()
    
    var autoScrollTimer: Timer!
    
    var isScrolling = false
    
    @IBOutlet weak var titleView: TitleView!
    @IBOutlet weak var carouselView: CarouselView!
    @IBOutlet var autoScrollButton: UIButton!
    
    //    var currentlyDisplayedPostIndex = 0 {
    //        didSet {
    //            if currentlyDisplayedPostIndex == allPosts.count - 1 {
    //                Task {
    //                    do {
    //                        try await fetchAPODData()
    //                    } catch {
    //                        //titleView.titleLabel.text = "Failed to fetch data from APOD API, please try later."
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoScrollButton.isHidden = true
        
        
        //        Task {
        //            do {
        //                try await fetchAPODData()
        //                carouselView.delegate = self
        //                carouselView.setupImageView()
        //                autoScrollButton.isHidden = false
        //
        //                //titleView.configure(viewModel: PostTitleViewModel(post: allPosts.first!, state: .displayTitle))
        //
        //
        //
        //                postViewModel.postTitleViewModel.$state.sink { state in
        //
        //                    if (state == .loadingAll || state == .loadingImage) {
        //                        self.titleView.loadingIndicator.isHidden = false
        //                        self.titleView.loadingIndicator.startAnimating()
        //                        return
        //                    }
        //
        //                    if self.titleView.loadingIndicator.isAnimating {
        //                        self.titleView.loadingIndicator.stopAnimating()
        //                        self.titleView.loadingIndicator.isHidden = true
        //                    }
        //
        //
        //                }.store(in: &cancellables)
        //
        //
        //            } catch APODServiceError.apodRateLimitHit {
        //                //titleView.titleLabel.text = ErrorMessage.rateLimitError
        //            } catch {
        //                //titleView.titleLabel.text = ErrorMessage.genericAPIError
        //            }
        //        }
        
        titleView.onTapAction = openDetailPanel
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard postViewModel != nil else {
            return
        }
        
        //        self.postTitleViewModel.value.title.bindAndFire { value in
        //            print("From binding")
        //            self.titleView.titleLabel.text = value
        //        }
        
    }
    
    //    func fetchAPODData() async throws {
    //        do {
    //            let fetchedPosts = try await NASA_APOD_Service().fetchAPODPost(count: Constants.apiRequestBatchSize)
    //            allPosts += fetchedPosts
    //        } catch {
    //            throw error
    //        }
    //
    //        let sequence = AnySequence(allPosts)
    //        Task(priority: .userInitiated) {
    //            for post in sequence.dropFirst() {  // First Image is fetched manually
    //                guard let urlString = post.imageURLString,
    //                      let url = URL(string: urlString),
    //                      let _ = try? await ImageManager.shared.getImageFromURL(url: url) else {
    //                          continue
    //                      }
    //            }
    //        }
    //    }
    
    @IBAction func rightTapDetected(_ sender: UITapGestureRecognizer) {
        
    }
    
    @IBAction func leftTapDetected(_ sender: UITapGestureRecognizer) {
    }
    
    @IBAction func swipeGestureDetected(_ sender: UISwipeGestureRecognizer) {
        openDetailPanel()
    }
    
    func openDetailPanel() {
        
        //        guard !allPosts.isEmpty,
        //              currentlyDisplayedPostIndex < allPosts.count else {
        //                  return
        //              }
        
        let detailsVC = PostDetailsVC(postDetailsViewModel: self.postDetailsViewModel)
        
        let navController = UINavigationController(rootViewController: detailsVC)
        navController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        guard let formSheetController = navController.presentationController as? UISheetPresentationController else {
            return
        }
        formSheetController.detents = [.medium()]
        formSheetController.prefersGrabberVisible = true
        
        stopScrollTimer() // Stop Auto Scroll, user is interested in current image.
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func autoScrollClicked(_ sender: UIButton) {
        isScrolling ? stopScrollTimer() : startScrollTimer()
    }
    
    func startScrollTimer() {
        autoScrollTimer = .scheduledTimer(timeInterval: Constants.autoScrollTimerDuration,
                                          target: self,
                                          selector: #selector(self.startScrolling),
                                          userInfo: nil,
                                          repeats: true)
        isScrolling = true
        
        autoScrollButton.setTitle("Stop Scroll", for: .normal)
    }
    
    func stopScrollTimer() {
        if isScrolling {
            isScrolling = false
            autoScrollTimer.invalidate()
            autoScrollButton.setTitle("Auto Scroll", for: .normal)
            
            return
        }
    }
    
    @objc func startScrolling() {
        if carouselView != nil {
            carouselView.rightTapDetected(UITapGestureRecognizer())
        }
    }
}



extension NASAApodImageViewController: CarouselDelegate {
    func rightTapDetected() {
        postViewModel.getNextPost()
    }
    
    func leftTapDetected() {
        postViewModel.getPreviousPost()
    }
    
    func getImageFromCache(index: Int) -> UIImage? {
        return nil
        //        guard index < allPosts.count,
        //              let imageURLString = allPosts[index].imageURLString,
        //              let postURL = try? getPostURL(urlString: imageURLString) else {
        //                  return nil
        //              }
        //        currentlyDisplayedPostIndex = index
        //
        //        DispatchQueue.main.async {
        //            //self.titleView.titleLabel.text = self.allPosts[self.currentlyDisplayedPostIndex].title
        //        }
        //        return ImageManager.shared.getImageFromCache(url: postURL)
    }
    
    var getTotalImageCount: Int {
        return 1
        //return allPosts.count
    }
    
    func getImage(index: Int) async throws -> UIImage {
        
        return UIImage()
        
        //        guard index < allPosts.count else {
        //            throw ImageManagerError.unknownError
        //        }
        
        //        currentlyDisplayedPostIndex = index
        //        DispatchQueue.main.async {
        //            //self.titleView.titleLabel.text = self.allPosts[self.currentlyDisplayedPostIndex].title
        //        }
        //
        //        guard index < allPosts.count,
        //              let imageURLString = allPosts[index].imageURLString,
        //              let postURL = try? getPostURL(urlString: imageURLString) else {
        //                  throw ImageManagerError.unknownError
        //              }
        //
        //        do {
        //            return try await ImageManager.shared.getImageFromURL(url: postURL)
        //        } catch {
        //            throw error
        //        }
    }
    
    func getPostURL(urlString: String) throws -> URL {
        guard let url = URL(string: urlString) else {
            throw ImageManagerError.urlConversionFailed
        }
        return url
    }
}

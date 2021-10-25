//
//  ViewController.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  
//

import UIKit
import nasa_apod_dataservice
import Combine

class NASAApodImageViewController: UIViewController {
    
    private var autoScrollTimer: Timer!
    private var isScrolling = false
    private var cancellables: Set<AnyCancellable> = []
    
    @IBOutlet weak var titleView: TitleView!
    @IBOutlet weak var carouselView: CarouselView!
    @IBOutlet var autoScrollButton: UIButton!
    
    var postViewModel : PostViewModel! {
        didSet {
            configureViewModels()
        }
    }
    
    private var postTitleViewModel : PostTitleViewModel! {
        didSet {
            titleView.titleLabel.text = postTitleViewModel.title
        }
    }
    
    private var postDetailsViewModel : PostDetailsViewModel!
    
    private var postImageViewModel : PostImageViewModel! {
        didSet {
            DispatchQueue.main.async {
                guard self.postImageViewModel != nil else {
                    return
                }
                self.autoScrollButton.isHidden = false
                self.carouselView.displayImage(image: self.postImageViewModel.postImage,
                                               isPlaceHolder: self.postImageViewModel.isPlaceHolder,
                                               scrollDirection: self.postImageViewModel.scrollDirection,
                                               shouldAnimate: true)
            }
        }
    }
    
    func configureViewModels() {
        
        self.postViewModel.$postTitleViewModel.sink { postTitleVM in
            self.postTitleViewModel = postTitleVM
        }.store(in: &cancellables)
        
        self.postViewModel.$postDetailsViewModel.sink { postDetailsVM in
            self.postDetailsViewModel = postDetailsVM
        }.store(in: &cancellables)
        
        self.postViewModel.$postImageViewModel.sink { postImageVM in
            self.postImageViewModel = postImageVM
        }.store(in: &cancellables)
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoScrollButton.isHidden = true
        titleView.onTapAction = openDetailPanel
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard postViewModel != nil else {
            return
        }
    }
    
    @IBAction func swipeGestureDetected(_ sender: UISwipeGestureRecognizer) {
        openDetailPanel()
    }
    
    private func openDetailPanel() {
        
        guard let postDetailsViewModel = self.postDetailsViewModel else {
            return
        }
        
        let detailsVC = PostDetailsVC(postDetailsViewModel: postDetailsViewModel)
        
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
    
    private func startScrollTimer() {
        autoScrollTimer = .scheduledTimer(timeInterval: Constants.autoScrollTimerDuration,
                                          target: self,
                                          selector: #selector(self.startScrolling),
                                          userInfo: nil,
                                          repeats: true)
        isScrolling = true
        
        autoScrollButton.setTitle(Constants.stopScroll, for: .normal)
    }
    
    private func stopScrollTimer() {
        guard isScrolling else {
            return
        }
        
        isScrolling = false
        autoScrollTimer.invalidate()
        autoScrollButton.setTitle(Constants.autoScroll, for: .normal)
        return
    }
    
    @objc
    private func startScrolling() {
        rightTapDetected()
    }
}

extension NASAApodImageViewController: CarouselViewDelegate {
    
    func rightTapDetected() {
        postViewModel.getNextPost()
    }
    
    func leftTapDetected() {
        postViewModel.getPreviousPost()
    }
}

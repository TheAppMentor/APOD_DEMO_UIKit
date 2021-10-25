//
//  PostDetailsVC.swift
//  NASA_APOD_VIEWER_UIKIT
//

import UIKit
import nasa_apod_dataservice

class PostDetailsVC: UIViewController {

    var postDetailsViewModel : PostDetailsViewModel?

    @IBOutlet var postTitle: UILabel!
    @IBOutlet var postDate: UILabel!
    @IBOutlet var postCopyright: UILabel!
    @IBOutlet var postExplanation: UITextView!

    convenience init(postDetailsViewModel: PostDetailsViewModel) {
        self.init()
        self.postDetailsViewModel = postDetailsViewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let postDetailsViewModel = postDetailsViewModel else {
            return
        }
        configure(postDetailsViewModel: postDetailsViewModel)
    }
    
    func configure(postDetailsViewModel : PostDetailsViewModel) {
        postTitle.text = postDetailsViewModel.title
        postCopyright.text = postDetailsViewModel.copyright
        postExplanation.text = postDetailsViewModel.explanation
        postDate.text = postDetailsViewModel.dateString
    }
}

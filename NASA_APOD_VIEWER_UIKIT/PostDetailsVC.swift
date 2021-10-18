//
//  PostDetailsVC.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 18/10/21.
//

import UIKit

class PostDetailsVC: UIViewController {
    
    var postViewModel : PostViewModel?
    
    @IBOutlet var postTitle: UILabel!
    @IBOutlet var postDate: UILabel!
    @IBOutlet var postCopyright: UILabel!
    @IBOutlet var postExplanation: UITextView!
     
    convenience init(postViewModel : PostViewModel) {
        self.init()
        self.postViewModel = postViewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        postTitle.text = postViewModel?.title
        postDate.text = postViewModel?.date
        postCopyright.text = postViewModel?.copyright
        postExplanation.text = postViewModel?.explanation
    }

}

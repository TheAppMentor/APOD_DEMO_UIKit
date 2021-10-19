//
//  PostDetailsVC.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 18/10/21.
//

import UIKit
import nasa_apod_dataservice

class PostDetailsVC: UIViewController {

    var postViewModel: Post?

    @IBOutlet var postTitle: UILabel!
    @IBOutlet var postDate: UILabel!
    @IBOutlet var postCopyright: UILabel!
    @IBOutlet var postExplanation: UITextView!

    convenience init(postViewModel: Post) {
        self.init()
        self.postViewModel = postViewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        postTitle.text = postViewModel?.title
        postCopyright.text = postViewModel?.copyright
        postExplanation.text = postViewModel?.explanation

        if let validDate = postViewModel?.date {
            postDate.text = DateUtils.getStringFromDate(date: validDate)

        }

    }

}

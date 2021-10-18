//
//  ViewController.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 15/10/21.
//

import UIKit

struct PostViewModel {
    let title : String
    let date : String
    let copyright : String
    let explanation : String
    let imageURL : String
}

class ViewController: UIViewController, CarouselDelegate {
    
    var currentlyDisplayedPostIndex = 0
    
    let allPosts = [
        PostViewModel(title: "POST 1", date: "TODAY", copyright: "CP1", explanation: "BLAH BLAH 1", imageURL: "https://apod.nasa.gov/apod/image/0004/m78_sdss.jpg"),
        PostViewModel(title: "POST 2", date: "TODAY + 1", copyright: "CP2", explanation: "BLAH BLAH 2", imageURL: "https://apod.nasa.gov/apod/image/0703/barnard163_noao_big.jpg"),
        PostViewModel(title: "POST 3", date: "TODAY + 2", copyright: "CP3", explanation: "BLAH BLAH 3", imageURL: "https://apod.nasa.gov/apod/image/1302/moonjupitermoons_gibbs_2000.jpg"),
        PostViewModel(title: "POST 4", date: "TODAY + 3", copyright: "CP4", explanation: "BLAH BLAH 4", imageURL: "https://apod.nasa.gov/apod/image/1209/airglow120824_ladanyi_1800px.jpg"),
        PostViewModel(title: "POST 5", date: "TODAY + 4", copyright: "CP5", explanation: "BLAH BLAH 5", imageURL: "https://apod.nasa.gov/apod/image/9612/novacyg_cfa_big.gif"),
    ]
    
    
    func getImage(index: Int) async -> UIImage {
        
        currentlyDisplayedPostIndex = index
        titleView.titleLabel.text = allPosts[currentlyDisplayedPostIndex].title
        
        let urlString = allPosts[index].imageURL
        let url = URL(string: urlString)!
        let startA = CFAbsoluteTimeGetCurrent()
        let fetchedImageData = try! await ImageManager.shared.getImageFromURL(url: url)
        print("Data Fetch : \(CFAbsoluteTimeGetCurrent() - startA)")
        
        let startB = CFAbsoluteTimeGetCurrent()
        let image = UIImage(data: fetchedImageData)!
        print("Data To Image : \(CFAbsoluteTimeGetCurrent() - startB)")

        return image
    }
    
    var getTotalImageCount: Int {
        return allPosts.count
    }
    
    @IBOutlet weak var titleView: TitleView!
    @IBOutlet weak var carouselView : CarouselView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            await fetchAPODData()
        }
                    
        titleView.onTapAction = openDetailPanel
    }
    
    func fetchAPODData() async {
        
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


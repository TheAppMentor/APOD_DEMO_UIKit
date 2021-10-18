//
//  ViewController.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 15/10/21.
//

import UIKit

class ViewController: UIViewController {
    
    var imageViewStack : [UIImageView] = []
    
    @IBOutlet var centeImageView: UIImageView!
    @IBOutlet var centerImageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rightImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightImageView: UIImageView!
    
    
    @IBOutlet weak var titleView: TitleView!
    
    @IBAction func tappedRight(_ sender: UITapGestureRecognizer) {
        
        centerImageViewWidthConstraint.constant = -self.view.frame.width + 0.5
        
        print("Tapped Right")
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        } completion: { success in
            print("Animation Done")
        }

    }
    
    @IBAction func tappedLeft(_ sender: UITapGestureRecognizer) {
        print("Tapped Left")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageViewStack.append(centeImageView)
    
        // Do any additional setup after loading the view.
        titleView.titleLabel.text = "From the View Controller"
        titleView.onTapAction = openSheet
    }
    
    func openSheet() {
            //let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController")
            let secondVC = DetailsViewController()
            // Create the view controller.
            if #available(iOS 15.0, *) {
                let formNC = UINavigationController(rootViewController: secondVC)
                formNC.modalPresentationStyle = UIModalPresentationStyle.pageSheet
                guard let sheetPresentationController = formNC.presentationController as? UISheetPresentationController else {
                    return
                }
                sheetPresentationController.detents = [.medium(), .large()]
                sheetPresentationController.prefersGrabberVisible = true
                present(formNC, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
       }


}


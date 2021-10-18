//
//  CarouselView.swift
//  CarouselTester
//
//  Created by Moorthy, Prashanth on 16/10/21.
//

import UIKit

enum Position {
    case left
    case right
    case center
    
    func constraints(currentView : UIView, parentView : UIView) -> [NSLayoutConstraint] {
        
        let heightConstraint = NSLayoutConstraint(item: currentView,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: parentView.frame.height)
        
        let widthConstraint = NSLayoutConstraint(item: currentView,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: parentView.frame.width)
        
        var constraints = [heightConstraint, widthConstraint]
        switch self {
        case .left:
            let trailingConstraint = NSLayoutConstraint(item: currentView,
                                                               attribute: .trailing,
                                                               relatedBy: .equal,
                                                               toItem: parentView,
                                                               attribute: .leading,
                                                               multiplier: 1,
                                                               constant: 0)
            trailingConstraint.identifier = "leftTrailing"
            constraints.append(trailingConstraint)
            
        case .right:
            let leadingConstraint = NSLayoutConstraint(item: currentView,
                                                       attribute: .leading,
                                                       relatedBy: .equal,
                                                       toItem: parentView,
                                                       attribute: .trailing,
                                                       multiplier: 1,
                                                       constant: 0)
            leadingConstraint.identifier = "rightLeading"
            constraints.append(leadingConstraint)
            
            
        case .center:
            break;
        }
        
        return constraints
    }
    
    func getLeadingConstraint(view : UIImageView) -> NSLayoutConstraint {
        switch self {
        case .left:
            assertionFailure()
        case .right:
            let leadingConstraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            leadingConstraint.identifier = "rightLeading" //TODO: this needs to change, based on teh view
            return leadingConstraint
        case .center:
            assertionFailure()
        }
        
        assertionFailure()
        return NSLayoutConstraint() //TODO:
    }
    
    func origin(frame : CGRect) -> CGPoint {
        switch self {
        case .left:
            return CGPoint(x: -frame.width, y: 0)
        case .right:
            return CGPoint(x: frame.width, y: 0)
        case .center:
            return .zero
        }
    }
}

@objc
protocol CarouselDelegate : AnyObject {
    func getImage(index : Int) async -> UIImage
    var getTotalImageCount : Int { get }
}

class CarouselView: UIView {
    
    var currentlyPresentedIndex = 0
    @IBOutlet weak var delegate : CarouselDelegate?
    
    var presentedImageView : UIImageView!
    
    fileprivate func addNewImageView(position : Position) -> UIImageView {
        
        let newView = UIImageView(frame: CGRect(origin:position.origin(frame: frame), size: frame.size))
        newView.clipsToBounds = true

        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .ultraLight, scale: .medium)
        let largeBoldDoc = UIImage(systemName: "photo", withConfiguration: largeConfig)?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        newView.image = largeBoldDoc
        
        newView.contentMode = .scaleAspectFit
        newView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(newView)
        
        let constraints = position.constraints(currentView: newView, parentView: self)
        self.addConstraints(constraints)
       
        return newView
    }
    
    @IBAction func leftTapDetected(_ sender: UITapGestureRecognizer) {
        print("leftTap")
        
        guard currentlyPresentedIndex != 0 else {
            print("We are already at the left most image")
            return
        }
        
        let leftImageView = addNewImageView(position: .left)
        
        guard let delegate = delegate else {
            return
        }

        currentlyPresentedIndex = currentlyPresentedIndex - 1

        Task {
            let newImage = await delegate.getImage(index: currentlyPresentedIndex)
            
            leftImageView.contentMode = .scaleAspectFill
            print("NOW I GOT THE REAL IMAGE")
            
            UIView.transition(with: leftImageView,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { leftImageView.image = newImage },
                              completion: nil)

        }
        
        sender.isEnabled = false
        

                        
        // Animate the right View (expand)
        let leftFilteredConstraints = constraints.filter { $0.identifier == "leftTrailing" }
        layoutIfNeeded()
        
        if let leftTrailingConstriant = leftFilteredConstraints.first {
            removeConstraint(leftTrailingConstriant)
            
            // Add a new leading constraint. This caused the view to move.
            let trailingConstraint = NSLayoutConstraint(item: leftImageView,
                                                       attribute: .trailing,
                                                       relatedBy: .equal,
                                                       toItem: self,
                                                       attribute: .trailing,  // superview, trailing
                                                       multiplier: 1,
                                                       constant: 0)
            trailingConstraint.identifier = "UpdatedLeftTrailingConstraint"
            addConstraint(trailingConstraint)
        }
        
        // This is to slide the center view to the right
        let  leadingConstraint = NSLayoutConstraint(item: presentedImageView!,
                                                     attribute: .leading,
                                                     relatedBy: .equal,
                                                     toItem: self,
                                                     attribute: .trailing,
                                                     multiplier: 1,
                                                     constant: 0)
        addConstraint(leadingConstraint)
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            // Animate and apply the constraints.
            self.layoutIfNeeded()
        } completion: { [self] success in
            // Remove the old Center View
            self.presentedImageView.removeFromSuperview()
            
            let updateLeftTrailing = constraints.filter { $0.identifier == "UpdatedLeftTrailingConstraint" }
            if let theGuy = updateLeftTrailing.first {
                removeConstraint(theGuy)
            }
            
            self.presentedImageView = leftImageView
            
            print("Animation Done")
            print("SubView Count : \(subviews.count)")
            sender.isEnabled = true
            //TODO: In the background : Load Next right Image to load it when needed.
        }
    }
        
    @objc
    @IBAction func rightTapDetected(_ sender: UITapGestureRecognizer) {
        print("Tapped Right")
        
        guard let delegate = delegate else {
            return
        }
        
        guard (currentlyPresentedIndex + 1) < delegate.getTotalImageCount else {
            return
        }
        
        let rightImageView = addNewImageView(position: .right)

        currentlyPresentedIndex = currentlyPresentedIndex + 1
        
        Task {
            let newImage = await delegate.getImage(index: currentlyPresentedIndex)
            rightImageView.contentMode = .scaleAspectFill
            print("NOW I GOT THE REAL IMAGE")
            
            UIView.transition(with: rightImageView,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { rightImageView.image = newImage },
                              completion: nil)
        }
        sender.isEnabled = false
                
        // Animate the right View (expand)
        let rightFilteredConstraints = constraints.filter { $0.identifier == "rightLeading" }
        //layoutIfNeeded()
        
        if let rightLeadingConstriant = rightFilteredConstraints.first {
            removeConstraint(rightLeadingConstriant)
            
            // Add a new leading constraint. This caused the view to move.
            let leadingConstraint = NSLayoutConstraint(item: rightImageView,
                                                       attribute: .leading,
                                                       relatedBy: .equal,
                                                       toItem: self,
                                                       attribute: .leading,  // superview, leading
                                                       multiplier: 1,
                                                       constant: 0)
            leadingConstraint.identifier = "UpdatedRightLeadingConstraint"
            addConstraint(leadingConstraint)
        }
        
        // This is to slide the center view to the left
        let  trailingConstraint = NSLayoutConstraint(item: presentedImageView!,
                                                     attribute: .trailing,
                                                     relatedBy: .equal,
                                                     toItem: self,
                                                     attribute: .leading,
                                                     multiplier: 1,
                                                     constant: 0)
        addConstraint(trailingConstraint)
        
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            // Animate and apply the constraints.
            self.layoutIfNeeded()
        } completion: { [self] success in
            // Remove the old Center View
            self.presentedImageView.removeFromSuperview()
            
            let updateRightLeading = constraints.filter { $0.identifier == "UpdatedRightLeadingConstraint" }
            if let theGuy = updateRightLeading.first {
                removeConstraint(theGuy)
            }
            
            self.presentedImageView = rightImageView
            sender.isEnabled = true

            
            print("Animation Done")
            print("SubView Count : \(subviews.count)")
            
            //TODO: In the background : Load Next right Image to load it when needed.
            
        }
    }
    
    func prepareNextImageView() {
        
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        //setupImageView()

    }
    
    @objc func someFunc() {
        print("Something Running")
        rightTapDetected(UITapGestureRecognizer())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        setupImageView()
        //Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.someFunc), userInfo: nil, repeats: true)
       // Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.someFunc), userInfo: nil, repeats: true)

    }
    
    func setupImageView() {
        presentedImageView = addNewImageView(position: .center)
        presentedImageView.contentMode = .scaleAspectFill
        presentedImageView.image = UIImage(named: "testImage") //TODO: HACK !!

        guard let imageCount = delegate?.getTotalImageCount,
        imageCount > 0 else {
            return
        }
    }
    
    private func setupFromNib() {
        
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        //view.backgroundColor = UIColor.red
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }
}

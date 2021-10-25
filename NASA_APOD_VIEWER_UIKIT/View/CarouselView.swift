//
//  CarouselView.swift
//  CarouselTester
//

import UIKit

@objc
protocol CarouselViewDelegate: AnyObject {
    func rightTapDetected()
    func leftTapDetected()
}

class CarouselView: UIView {
    
    @IBOutlet weak var delegate: CarouselViewDelegate?
    
    private var presentedImageView: UIImageView!
    private var currentImage : UIImage!
    private var imageAnimationDuration = 0.3
    private var isAnimating = false
    
    func displayImage(image: UIImage,
                      isPlaceHolder: Bool,
                      scrollDirection: Position,
                      shouldAnimate: Bool){
        
        let imageView = addNewImageView(position: scrollDirection, image: image)
        imageView.contentMode = isPlaceHolder ? .scaleAspectFit : .scaleAspectFill
        
        switch scrollDirection {
        case .left:
            imageView.image = image
            animateLeftImage(leftImageView: imageView)
        case .right:
            imageView.image = image
            animateRightImage(rightImageView: imageView)
        case .center:
            DispatchQueue.main.asyncAfter(deadline: .now() + self.imageAnimationDuration) {
                UIView.transition(with: imageView,
                                  duration: 1.5 * self.imageAnimationDuration,
                                  options: .transitionCrossDissolve,
                                  animations: { imageView.image = image },
                                  completion: { _ in
                    self.presentedImageView.removeFromSuperview()
                    self.presentedImageView = imageView
                    
                })
            }
        }
    }
    
    fileprivate func addNewImageView(position: Position, image: UIImage? = nil) -> UIImageView {
        
        let newView = UIImageView(frame: CGRect(origin: position.origin(frame: frame), size: frame.size))
        newView.clipsToBounds = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        
        //newView.image = image
        newView.contentMode = image == nil ? .scaleAspectFit : .scaleAspectFill
        
        addSubview(newView)
        
        let constraints = position.constraints(currentView: newView, parentView: self)
        self.addConstraints(constraints)
        
        return newView
    }
    
    @IBAction func leftTapDetected(_ sender: UITapGestureRecognizer) {
        
        guard let delegate = delegate,
              presentedImageView != nil else {
                  return
              }
        
        delegate.leftTapDetected()
    }
    
    @IBAction func rightTapDetected(_ sender: UITapGestureRecognizer) {
        
        guard let delegate = delegate,
              presentedImageView != nil else {
                  return
              }
        
        delegate.rightTapDetected()
    }
    
    func animateRightImage(rightImageView : UIImageView) {
        
        guard let presentedImageView = presentedImageView else {
            return
        }
        
        layoutIfNeeded()
        isAnimating = true
        
        // Animate the right View (expand)
        let rightFilteredConstraints = constraints.filter { $0.identifier == "rightLeading" }
        
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
        let  trailingConstraint = NSLayoutConstraint(item: presentedImageView,
                                                     attribute: .trailing,
                                                     relatedBy: .equal,
                                                     toItem: self,
                                                     attribute: .leading,
                                                     multiplier: 1,
                                                     constant: 0)
        addConstraint(trailingConstraint)
        
        UIView.animate(withDuration: imageAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
            // Animate and apply the constraints.
            self.layoutIfNeeded()
        }, completion: { [self] _ in
            // Remove the old Center View
            isAnimating = false
            self.presentedImageView.removeFromSuperview()
            removeConstraint(name: "UpdatedRightLeadingConstraint")
            self.presentedImageView = rightImageView
        })
    }
    
    func animateLeftImage(leftImageView: UIImageView) {
        
        guard let presentedImageView = presentedImageView else {
            return
        }
        
        isAnimating = true
        
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
        let  leadingConstraint = NSLayoutConstraint(item: presentedImageView,
                                                    attribute: .leading,
                                                    relatedBy: .equal,
                                                    toItem: self,
                                                    attribute: .trailing,
                                                    multiplier: 1,
                                                    constant: 0)
        addConstraint(leadingConstraint)
        
        UIView.animate(withDuration: imageAnimationDuration, delay: 0, options: .curveEaseOut,
                       animations: {
            // Animate and apply the constraints.
            self.layoutIfNeeded()
        }, completion: {_ in
            self.isAnimating = false
            // Remove the old Center View
            self.presentedImageView.removeFromSuperview()
            self.removeConstraint(name: "UpdatedLeftTrailingConstraint")
            self.presentedImageView = leftImageView
        })
    }
    
    func removeConstraint(name: String) {
        let matchedConstraints = constraints.filter { $0.identifier == name }
        if let constraint = matchedConstraints.first {
            removeConstraint(constraint)
        }
    }
    
    func populateImage(imageView: UIImageView, shouldAnimate: Bool = false) {
        
        Task {
            imageView.contentMode = .scaleAspectFill
            
            UIView.transition(with: imageView,
                              duration: shouldAnimate ? imageAnimationDuration : 0.0,
                              options: .transitionCrossDissolve,
                              animations: { imageView.image = self.currentImage },
                              completion: nil)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        setupImageView()
    }
    
    @objc func autoScroll() {
        rightTapDetected(UITapGestureRecognizer())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        setupImageView()
    }
    
    func setupImageView() {
        presentedImageView = addNewImageView(position: .center)
        presentedImageView.contentMode = .scaleAspectFit
        
        populateImage(imageView: presentedImageView, shouldAnimate: true)
    }
    
    private func setupFromNib() {
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        guard let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return UIView()
        }
        
        return nibView
    }
}

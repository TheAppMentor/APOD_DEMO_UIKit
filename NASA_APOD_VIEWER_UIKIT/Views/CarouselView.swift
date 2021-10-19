//
//  CarouselView.swift
//  CarouselTester
//
//  Created by Moorthy, Prashanth on 16/10/21.
//

import UIKit

@objc
protocol CarouselDelegate: AnyObject {
    var getTotalImageCount: Int { get }

    func getImage(index: Int) async throws -> UIImage
    func getImageFromCache(index: Int) -> UIImage?
}

class CarouselView: UIView {

    var currentlyPresentedIndex = 0
    @IBOutlet weak var delegate: CarouselDelegate?

    var presentedImageView: UIImageView!

    lazy var placeHolderImage: UIImage = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20,
                                                      weight: .ultraLight,
                                                      scale: .medium)
        let placeHolderImage = UIImage(systemName: "photo",
                                       withConfiguration: largeConfig)?.withTintColor(.lightGray,
                                                                                      renderingMode: .alwaysOriginal)
        return placeHolderImage!
    }()

    fileprivate func addNewImageView(position: Position, image: UIImage? = nil) -> UIImageView {

        let newView = UIImageView(frame: CGRect(origin: position.origin(frame: frame), size: frame.size))
        newView.clipsToBounds = true

        newView.translatesAutoresizingMaskIntoConstraints = false
        newView.image = image ?? placeHolderImage
        newView.contentMode = image == nil ? .scaleAspectFit : .scaleAspectFill

        addSubview(newView)

        let constraints = position.constraints(currentView: newView, parentView: self)
        self.addConstraints(constraints)

        return newView
    }

    @IBAction func leftTapDetected(_ sender: UITapGestureRecognizer) {

        // Check if we are at the left most image.
        guard currentlyPresentedIndex != 0,
              let delegate = delegate,
              let presentedImageView = presentedImageView else {
                  return
              }

        currentlyPresentedIndex -= 1

        let cachedImage = delegate.getImageFromCache(index: currentlyPresentedIndex)
        let leftImageView = addNewImageView(position: .left, image: cachedImage)
        //leftImageView.contentMode = .scaleAspectFill

        if cachedImage == nil {
            populateImage(imageView: leftImageView, shouldAnimate: true)
        }

        // Disable User interation when animation is in progress.
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
        let  leadingConstraint = NSLayoutConstraint(item: presentedImageView,
                                                    attribute: .leading,
                                                    relatedBy: .equal,
                                                    toItem: self,
                                                    attribute: .trailing,
                                                    multiplier: 1,
                                                    constant: 0)
        addConstraint(leadingConstraint)

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut,
                       animations: {
            // Animate and apply the constraints.
            self.layoutIfNeeded()
        },
                       completion: {_ in
            // Remove the old Center View
            self.presentedImageView.removeFromSuperview()

            self.removeConstraint(name: "UpdatedLeftTrailingConstraint")

            self.presentedImageView = leftImageView

            sender.isEnabled = true
        })
    }

    @objc
    @IBAction func rightTapDetected(_ sender: UITapGestureRecognizer) {

        guard let delegate = delegate,
              let presentedImageView = presentedImageView else {
                  return
              }

        currentlyPresentedIndex += 1

        let cachedImage = delegate.getImageFromCache(index: currentlyPresentedIndex)
        let rightImageView = addNewImageView(position: .right, image: cachedImage)

        if cachedImage == nil {
            populateImage(imageView: rightImageView, shouldAnimate: true)
        }

        sender.isEnabled = false

        // Animate the right View (expand)
        let rightFilteredConstraints = constraints.filter { $0.identifier == "rightLeading" }
        layoutIfNeeded()

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

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            // Animate and apply the constraints.
            self.layoutIfNeeded()
        }, completion: { [self] _ in
            // Remove the old Center View
            self.presentedImageView.removeFromSuperview()

            removeConstraint(name: "UpdatedRightLeadingConstraint")

            self.presentedImageView = rightImageView
            sender.isEnabled = true

        })
    }

    func removeConstraint(name: String) {
        let matchedConstraints = constraints.filter { $0.identifier == name }
        if let constraint = matchedConstraints.first {
            removeConstraint(constraint)
        }
    }

    func populateImage(imageView: UIImageView, shouldAnimate: Bool = false) {

        guard let delegate = delegate else {
            return
        }

        Task {
            let newImage = try await delegate.getImage(index: currentlyPresentedIndex)
            imageView.contentMode = .scaleAspectFill

            UIView.transition(with: imageView,
                              duration: shouldAnimate ? 0.3 : 0.0,
                              options: .transitionCrossDissolve,
                              animations: { imageView.image = newImage },
                              completion: nil)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }

    @objc func autoScroll() {
        rightTapDetected(UITapGestureRecognizer())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
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

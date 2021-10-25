//
//  TitleView.swift
//  NASA_APOD_VIEWER_UIKIT
//

import UIKit
import Combine
class TitleView: UIView {
    
    private var viewModel: PostTitleViewModel?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var blurEffectView: UIView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!

    var onTapAction : (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private var cancellables: Set<AnyCancellable> = []

    func configure(viewModel: PostTitleViewModel) {
        self.viewModel = viewModel
    }

    private func nibSetup() {
        backgroundColor = .clear

        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true

        view.layer.cornerRadius = 20.0
        view.clipsToBounds = true

        addSubview(view)
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        guard let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            assertionFailure("Failed to create UIView from Nib")
            return UIView()
        }

        return nibView
    }

    class func instanceFromNib() -> UIView {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: nil)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? UIView else {
            assertionFailure("Failed to create UIView from Nib")
            return UIView()
        }
        return view
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        onTapAction?()
    }

}

//
//  TitleView.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 15/10/21.
//

import UIKit

class TitleView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var blurEffectView: UIView!
    @IBOutlet weak var moreInfoButton: UIButton!
    
    var onTapAction : (()->())? = nil
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        print("View was Tapped")
        onTapAction?()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }

    private func nibSetup() {
        backgroundColor = .clear
                
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true

        view.layer.cornerRadius = 20.0;
        view.clipsToBounds = true
        
        titleLabel.text = "Hello World"
        
        addSubview(view)
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView

        return nibView
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "TitleView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    override class func awakeFromNib() {
        print("Awaking from Nim Man")
        
    }

}

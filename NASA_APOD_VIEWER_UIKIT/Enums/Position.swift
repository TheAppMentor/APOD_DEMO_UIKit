//
//  Position.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 19/10/21.
//

import Foundation
import UIKit

enum Position {
    case left
    case right
    case center

    func constraints(currentView: UIView, parentView: UIView) -> [NSLayoutConstraint] {

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
            break
        }

        return constraints
    }

    func origin(frame: CGRect) -> CGPoint {
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

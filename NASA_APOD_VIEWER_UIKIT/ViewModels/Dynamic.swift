//
//  Dynamic.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 20/10/21.
//

import Foundation

class Dynamic<T> {
    typealias Listener = (T) -> ()
    var listener: Listener?
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(_ listener: Listener?) {
        print("Dynamic : Setting the Listener : \(listener)")
        self.listener = listener
        listener?(value)
    }
    
    var value: T {
        didSet {
            print("Dynamic : \(listener) : \(value)")
            listener?(value)
        }
    }
    
    init(_ val: T) {
        value = val
    }
}

//
//  IndentedTextFiled.swift
//  OnTheMap
//
//  Created by Yetkin Timocin on 14/10/15.
//  Copyright © 2015 basetech. All rights reserved.
//

import UIKit

extension UITextField {
    @IBInspectable var padding_left: CGFloat {
        get {
            return 0
        }
        set (f) {
            layer.sublayerTransform = CATransform3DMakeTranslation(f, 0, 0)
        }
    }
    
    @IBInspectable var padding_top: CGFloat {
        get {
            return 0
        }
        set (f) {
            layer.sublayerTransform = CATransform3DMakeTranslation(0, f, 0)
        }
    }
}

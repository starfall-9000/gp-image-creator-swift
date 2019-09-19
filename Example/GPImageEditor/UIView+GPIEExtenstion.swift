//
//  UIView+GPIEExtenstion.swift
//  GPImageEditor
//
//  Created by Ngoc Thang on 9/18/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            var rect = frame
            rect.origin.y = newValue
            frame = rect
        }
    }
    
    var bottom: CGFloat {
        return frame.origin.y + frame.size.height
    }
    
    var left: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            var rect = frame
            rect.origin.x = newValue
            frame = rect
        }
    }
    
    var right: CGFloat {
        return frame.origin.x + frame.size.width
    }
    
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            var rect = frame
            rect.size.width = newValue
            frame = rect
        }
    }
    
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            var rect = frame
            rect.size.height = newValue
            frame = rect
        }
    }
    
}

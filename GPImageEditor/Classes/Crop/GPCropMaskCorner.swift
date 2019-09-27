//
//  GPCropMaskCorner.swift
//  GPImageEditor_Example
//
//  Created by An Binh on 9/20/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import DTMvvm
import PureLayout

public class GPCropMaskCorner {
    public static func createAndAddCorner(to imageMask: UIView) -> [UIView] {
        var children: [UIView] = []
        children.append(addCornerWithLayout(imageMask: imageMask, tag: GPCropCorner.topLeft.rawValue, edge1: .top, edge2: .left))
        children.append(addCornerWithLayout(imageMask: imageMask, tag: GPCropCorner.topRight.rawValue, edge1: .top, edge2: .right))
        children.append(addCornerWithLayout(imageMask: imageMask, tag: GPCropCorner.bottomLeft.rawValue, edge1: .bottom, edge2: .left))
        children.append(addCornerWithLayout(imageMask: imageMask, tag: GPCropCorner.bottomRight.rawValue, edge1: .bottom, edge2: .right))
        return children
    }
    
    private static func addCornerWithLayout(imageMask: UIView, tag: Int, edge1: ALEdge, edge2: ALEdge) -> UIView {
        let corner = UIImageView()
        corner.backgroundColor = .clear
        corner.isUserInteractionEnabled = true
        if let superView = imageMask.superview {
            superView.addSubview(corner)
            corner.tag = tag
            corner.autoSetDimensions(to: .init(width: 32, height: 32))
            corner.autoPinEdge(edge1, to: edge1, of: imageMask)
            corner.autoPinEdge(edge2, to: edge2, of: imageMask)
        }
        return corner
    }
}

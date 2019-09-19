//
//  GPCropMask.swift
//  GPImageEditor_Example
//
//  Created by An Binh on 9/13/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import DTMvvm

public class GPCropMask: UIView {
    public var type: GPCropType? = .free
    let imageMask = UIView()
    
    convenience init() {
        self.init(frame: CGRect.zero)
        self.subviews.forEach({ $0.removeFromSuperview() })
        // blur
//        let blurView = UIView()
//        self.addSubview(blurView)
//        blurView.backgroundColor = .init(r: 0, g: 0, b: 0, a: 0.5)
//        blurView.autoPinEdgesToSuperviewEdges()
        // mask
        self.addSubview(imageMask)
        imageMask.autoPinEdgesToSuperviewEdges()
        
        createVerticalStack()
        createHorizontalStack()
    }
    
    private func createVerticalStack() {
        createStack(isVertical: true)
    }
    
    private func createHorizontalStack() {
        createStack(isVertical: false)
    }
    
    private func createStack(isVertical: Bool) {
        let stackLayout = StackLayout().justifyContent(.equalCentering).children(getStackDividers(isVertical))
        stackLayout.axis = isVertical ? .vertical : .horizontal
        imageMask.addSubview(stackLayout)
        stackLayout.autoPinEdgesToSuperviewEdges()
    }
    
    private func getStackDividers(_ isVertical: Bool) -> [UIView] {
        var children: [UIView] = []
        let NUM_OF_DIVIDER = 4
        for _ in 1...NUM_OF_DIVIDER {
            let divider = UIView()
            divider.backgroundColor = .white
            children.append(divider)
            if (isVertical) {
                divider.autoSetDimension(.height, toSize: 1)
            } else {
                divider.autoSetDimension(.width, toSize: 1)
            }
        }
        return children
    }
    
}

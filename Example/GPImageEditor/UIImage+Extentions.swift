//
//  UIImage+Extentions.swift
//  GPImageEditor
//
//  Created by Ngoc Thang on 9/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func thumbImage() -> UIImage {
        let k = size.width / size.height
        let scale = UIScreen.main.scale
        let thumbnailHeight: CGFloat = 150 * scale
        let thumbnailWidth = thumbnailHeight * k
        let thumbnailSize = CGSize(width: thumbnailWidth, height: thumbnailHeight)
        UIGraphicsBeginImageContext(thumbnailSize)
        draw(in: CGRect(x: 0, y: 0, width: thumbnailSize.width, height: thumbnailSize.height))
        let smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return smallImage!
    }
    
    func toCIImage() -> CIImage? {
        return self.ciImage ?? CIImage(cgImage: self.cgImage!)
    }
    
}

internal extension CIImage {
    
    func toUIImage() -> UIImage {
        /* If need to reduce the process time, than use next code. But ot produce a bug with wrong filling in the simulator.
         return UIImage(ciImage: self)
         */
        let context: CIContext = CIContext.init(options: nil)
        let cgImage: CGImage = context.createCGImage(self, from: self.extent)!
        let image: UIImage = UIImage(cgImage: cgImage)
        return image
    }
    
    func toCGImage() -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(self, from: self.extent) {
            return cgImage
        }
        return nil
    }
    
}

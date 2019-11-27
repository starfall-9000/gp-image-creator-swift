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
    
    public func fixedOrientation() -> UIImage {
        
        // Image has no orientation, so keep the same
        if imageOrientation == .up {
            return self
        }
        
        // Process the transform corresponding to the current orientation
        var transform = CGAffineTransform.identity
        switch imageOrientation {
        case .down, .downMirrored:           // EXIF = 3, 4
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            
        case .left, .leftMirrored:           // EXIF = 6, 5
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
            
        case .right, .rightMirrored:          // EXIF = 8, 7
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -CGFloat((Double.pi / 2)))
        default:
            ()
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:     // EXIF = 2, 4
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:   //EXIF = 5, 7
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            ()
        }
        
        // Draw a new image with the calculated transform
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: cgImage!.bitsPerComponent,
                                bytesPerRow: 0,
                                space: cgImage!.colorSpace!,
                                bitmapInfo: cgImage!.bitmapInfo.rawValue)
        context?.concatenate(transform)
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        if let newImageRef =  context?.makeImage() {
            let newImage = UIImage(cgImage: newImageRef)
            return newImage
        }
        
        // In case things go wrong, still return self.
        return self
    }
    
    func cropImage(_ bounds: CGRect) -> UIImage? {
        let imageRef = cgImage?.cropping(to: bounds)
        var croppedImage: UIImage? = nil
        if let imageRef = imageRef {
            croppedImage = UIImage(cgImage: imageRef)
        }
        return croppedImage
    }
    
    func cropByWidth(percent: CGFloat) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: percent * size.width, height: size.height)
        return cropImage(rect)
    }
    
    func sizeForEditing(with bounds: CGSize) -> CGSize {
        let scale = bounds.width / size.width
        let height = size.height * scale
        if height <= bounds.height {
            return CGSize(width: bounds.width / scale, height: height / scale)
        }
        return CGSize(width: bounds.width / scale, height: bounds.height / scale)
    }
    
    func croppedImageForEditing(with bounds: CGSize) -> UIImage? {
        let cropSize = sizeForEditing(with: bounds)
        if size.height <= cropSize.height {
            return self
        }
        let cropRect = CGRect(x: 0,
                              y: (size.height - cropSize.height) / 2,
                              width: cropSize.width,
                              height: cropSize.height)
        return cropImage(cropRect)
    }
    
    func imageWithBottomFrame(frame: UIImage?) -> UIImage? {
        guard let frame = frame else {
            return self
        }
        let frameDrawSize = CGSize(width: size.width, height: size.width * frame.size.height / frame.size.width)
        let frameDrawRect = CGRect(x: 0, y: size.height - frameDrawSize.height, width: size.width, height: frameDrawSize.height)
        let imageRect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContext(size)
        draw(in: imageRect)
        frame.draw(in: frameDrawRect)
        let endImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return endImage
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

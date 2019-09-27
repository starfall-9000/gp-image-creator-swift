//
//  GPCropItem.swift
//  GPImageEditor_Example
//
//  Created by An Binh on 9/13/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import DTMvvm

public enum GPCropType: String {
    case flip = "flip"
    case free = "free"
    case ratioOneOne = "ratioOneOne"
    case ratioFourThree = "ratioFourThree"
    case ratioThreeFour = "ratioThreeFour"
    
    public static func getRatio(_ type: GPCropType) -> [String: CGFloat] {
        var widthRatio: CGFloat = 1
        var heightRatio: CGFloat = 1
        switch type {
        case .ratioOneOne:
            widthRatio = 1
            heightRatio = 1
            break
        case .ratioFourThree:
            widthRatio = 4
            heightRatio = 3
            break
        case .ratioThreeFour:
            widthRatio = 3
            heightRatio = 4
        default:
            break
        }
        return ["width": widthRatio, "height": heightRatio]
    }
}

public class GPCropItem: UIView {
    public var type: GPCropType? = nil
}

extension GPCropItem {
    public struct gapo {
        public static var flip: GPCropItem {
            return itemWithType(.flip)
        }
        
        public static var free: GPCropItem {
            return itemWithType(.free)
        }
        
        public static var ratioOneOne: GPCropItem {
            return itemWithType(.ratioOneOne)
        }
        
        public static var ratioFourThree: GPCropItem {
            return itemWithType(.ratioFourThree)
        }
        
        public static var ratioThreeFour: GPCropItem {
            return itemWithType(.ratioThreeFour)
        }
        
        public static let all: [GPCropItem] = [gapo.flip, gapo.free, gapo.ratioOneOne, gapo.ratioFourThree, gapo.ratioThreeFour]
        
        public static func itemWithType(_ type: GPCropType) -> GPCropItem {
            let item = GPCropItem()
            item.type = type
            item.autoSetDimensions(to: .init(width: 32, height: 52))
            
            let bundle = GPImageEditorBundle.getBundle()
            let imageView = UIImageView(image: UIImage(named: getImageName(type), in: bundle, compatibleWith: nil))
            item.addSubview(imageView)
            imageView.autoSetDimensions(to: .init(width: 24, height: 24))
            imageView.autoAlignAxis(.vertical, toSameAxisOf: item)
            imageView.autoPinEdge(toSuperviewEdge: .top)
            imageView.contentMode = .scaleAspectFit
            
            let title = UILabel()
            title.text = titleWithType(type)
            title.font = .systemFont(ofSize: 11)
            title.textColor = .white
            title.textAlignment = .center
            item.addSubview(title)
            title.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 8)
            title.autoAlignAxis(.vertical, toSameAxisOf: item)
            title.autoMatch(.width, to: .width, of: item)
            
            return item
        }
        
        public static func titleWithType(_ type: GPCropType) -> String {
            switch type {
            case .flip:
                return "Flip"
            case .free:
                return "Free"
            case .ratioOneOne:
                return "1:1"
            case .ratioFourThree:
                return "4:3"
            case .ratioThreeFour:
                return "3:4"
            }
        }
        
        private static func getImageName(_ type: GPCropType) -> String {
            return "ic_crop_" + type.rawValue
        }
    }
}

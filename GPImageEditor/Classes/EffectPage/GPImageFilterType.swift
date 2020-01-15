//
//  GPImageFilterType.swift
//  Action
//
//  Created by An Binh on 12/13/19.
//

import UIKit

public enum GPImageFilterType {
    case matbiec1
    case matbiec2
    case matbiec3
    case matbiec4
    case matbiec5
    
    public func getImageFilter() -> GPImageFilter {
        var filter: GPImageFilter
        var allowGesture = true
        switch self {
        case .matbiec1:
            filter = GPImageFilter(name: "Mắt biếc 1", applier: GPImageFilter.matbiec1Frame)
            break
        case .matbiec2:
            filter = GPImageFilter(name: "Mắt biếc 2", applier: GPImageFilter.matbiec2Frame)
            break
        case .matbiec3:
            filter = GPImageFilter(name: "Mắt biếc 3", applier: GPImageFilter.matbiec3Frame)
            break
        case .matbiec4:
            filter = GPImageFilter(name: "Mắt biếc 4", applier: GPImageFilter.matbiec4Frame)
            break
        case .matbiec5:
            filter = GPImageFilter(name: "Filter MB", applier: GPImageFilter.matbiec5Filter)
            allowGesture = false
            break
        }
        filter.allowGesture = allowGesture
        filter.frameImage = getFrame()
        filter.thumbImage = GPImageEditorBundle.imageFromBundle(imageName: getThumbIcon())
        return filter
    }
    
    public func getFrame() -> UIImage? {
        switch self {
        case .matbiec1:
            return GPImageFilter.matbiec1FrameImage()
        case .matbiec2:
            return GPImageFilter.matbiec2FrameImage()
        case .matbiec3:
            return GPImageFilter.matbiec3FrameImage()
        case .matbiec4:
            return GPImageFilter.matbiec4FrameImage()
        case .matbiec5:
            return nil
        }
    }
    
    public func getThumbIcon() -> String {
        switch self {
        case .matbiec1:
            return "matbiec_thumb_1"
        case .matbiec2:
            return "matbiec_thumb_2"
        case .matbiec3:
            return "matbiec_thumb_3"
        case .matbiec4:
            return "matbiec_thumb_4"
        case .matbiec5:
            return "matbiec_thumb_5"
        }
    }
    
    public func getDefaultForegroundSize() -> CGSize {
        var width = UIScreen.main.bounds.width
        let imageRatio = width / 375
        var height: CGFloat = 0
        switch self {
        case .matbiec1, .matbiec5, .matbiec4:
            height = 500 * imageRatio
            break
        case .matbiec2, .matbiec3:
            width = 343 * imageRatio
            height = 396 * imageRatio
            break
        }
        return CGSize(width: width, height: height)
    }
}

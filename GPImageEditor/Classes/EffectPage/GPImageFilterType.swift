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
        switch self {
        case .matbiec1:
            filter = GPImageFilter(name: "Mắt biếc 1", applier: GPImageFilter.matbiec1Frame)
        case .matbiec2:
            filter = GPImageFilter(name: "Mắt biếc 2", applier: GPImageFilter.matbiec2Frame)
        case .matbiec3:
            filter = GPImageFilter(name: "Mắt biếc 3", applier: GPImageFilter.matbiec3Frame)
        case .matbiec4:
            filter = GPImageFilter(name: "Mắt biếc 4", applier: GPImageFilter.matbiec4Frame)
        case .matbiec5:
            filter = GPImageFilter(name: "Filter MB", applier: GPImageFilter.matbiec1Frame)
        }
        filter.allowGesture = true
        filter.frame = getFrame()
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
            return GPImageFilter.matbiec1FrameImage()
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
}

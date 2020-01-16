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
    case party
    case petro
    case comic
    
    public func getImageFilter() -> GPImageFilter {
        var filter: GPImageFilter
        var allowGesture = false
        switch self {
        case .matbiec1, .matbiec2, .matbiec3, .matbiec4:
            allowGesture = true
            break
        case .matbiec5, .party, .petro, .comic:
            break
        }
        let name = getFrameName()
        filter = GPImageFilter(name: name, applier: nil)
        filter.applier = filter.applyFrame
        filter.allowGesture = allowGesture
        filter.frameImage = getFrameIcon()
        filter.thumbImage = getThumbIcon()
        return filter
    }
    
    public func getFrameName() -> String {
        switch self {
        case .matbiec1:
            return "Mắt biếc 1"
        case .matbiec2:
            return "Mắt biếc 2"
        case .matbiec3:
            return "Mắt biếc 3"
        case .matbiec4:
            return "Mắt biếc 4"
        case .matbiec5:
            return "Mắt biếc 5"
        case .party:
            return "Party"
        case .petro:
            return "Petro"
        case .comic:
            return "Comic"
        }
    }
    
    public func getFrameIcon() -> UIImage? {
        var frameIcon = ""
        switch self {
        case .matbiec1:
            frameIcon = "matbiec_filter_1"
            break
        case .matbiec2:
            frameIcon = "matbiec_filter_2"
            break
        case .matbiec3:
            frameIcon = "matbiec_filter_3"
            break
        case .matbiec4:
            frameIcon = "matbiec_filter_4"
            break
        case .matbiec5:
            return nil
        case .party:
            frameIcon = "Frame 1"
            break
        case .petro:
            frameIcon = "Frame 2"
            break
        case .comic:
            frameIcon = "Frame 3"
            break
        }
        return GPImageEditorBundle.imageFromBundle(imageName: frameIcon)
    }
    
    public func getThumbIcon() -> UIImage? {
        var thumbIcon = ""
        switch self {
        case .matbiec1:
            thumbIcon = "matbiec_thumb_1"
            break
        case .matbiec2:
            thumbIcon = "matbiec_thumb_2"
            break
        case .matbiec3:
            thumbIcon = "matbiec_thumb_3"
            break
        case .matbiec4:
            thumbIcon = "matbiec_thumb_4"
            break
        case .matbiec5:
            thumbIcon = "matbiec_thumb_5"
            break
        case .party:
            thumbIcon = "Frame 1"
            break
        case .petro:
            thumbIcon = "Frame 2"
            break
        case .comic:
            thumbIcon = "Frame 3"
            break
        }
        return GPImageEditorBundle
            .imageFromBundle(imageName: thumbIcon)?
            .thumbImage()
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
        case .party, .petro, .comic:
            break
        }
        return CGSize(width: width, height: height)
    }
}

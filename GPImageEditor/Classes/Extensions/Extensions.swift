//
//  StringExtensions.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/12/19.
//

import Foundation

extension UIImage {
    class func imageWithLabel(label: UILabel, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        label.layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

extension String {
    static func getListEmojis() -> [String] {
        var emojis: [String] = []
        for cateName in emojiCategoryNames {
            let cate = emojiCategories[cateName] ?? []
            emojis.append(contentsOf: cate)
        }
        return emojis
    }
}

//
//  GPImageEditorBundle.swift
//  Action
//
//  Created by ToanDK on 9/10/19.
//

import Foundation

open class GPImageEditorBundle {
    class func getBundle() -> Bundle {
        let bundle = Bundle(for: self)
        guard let url = bundle.url(forResource: "GPImageEditor", withExtension: "bundle") else { return bundle }
        guard let podBundle = Bundle(url: url) else { return bundle }
        return podBundle
    }
    
    class func imageFromBundle(imageName: String, ext: String) -> UIImage! {
        let bundlePath = getBundle().path(forResource: imageName, ofType: ext)
        return UIImage(named: bundlePath!)!
    }
}

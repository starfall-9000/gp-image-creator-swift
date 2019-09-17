//
//  GPImageEditor.swift
//  GPImageEditor
//
//  Created by Ngoc Thang on 9/17/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public struct GPImageEditor {
    
    public static func present(from viewController: UIViewController, image: UIImage, animated: Bool, finished: @escaping ((UIImage) -> Void), completion: (() -> Void)? = nil) {
        let viewModel = EffectPageViewModel(image: image)
        let vc = EffectPage.create(with: viewModel)
        vc.doneBlock = finished
        viewController.present(vc, animated: animated, completion: completion)
    }
    
}

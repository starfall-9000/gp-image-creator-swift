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
    
    public static func present(from viewController: UIViewController, image: UIImage, animated: Bool, finished: @escaping ((UIImage) -> Void), completion: (() -> Void)? = nil, didDismissScreen: ((Bool) -> Void)? = nil) {
        let viewModel = EffectPageViewModel(image: image)
        let vc = EffectPage.create(with: viewModel)
        vc.modalPresentationStyle = .fullScreen
        vc.doneBlock = finished
        vc.didDismissScreen = didDismissScreen
        viewController.present(vc, animated: animated, completion: completion)
    }
    
    public static func presentEditPage(from viewController: UIViewController, image: UIImage, animated: Bool, finished: @escaping ((UIImage) -> Void)) {
        EditPage.present(from: viewController, image: image, animated: animated, finished: finished)
    }
    
}

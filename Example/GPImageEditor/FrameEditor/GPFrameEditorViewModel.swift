//
//  GPFrameEditorViewModel.swift
//  GPImageEditor_Example
//
//  Created by An Binh on 12/10/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import DTMvvm
import RxCocoa
import RxSwift

class GPFrameEditorViewModel: ViewModel<UIImage> {
    var finishedBlock: ((UIImage) -> Void)?
    let rxImage = BehaviorRelay<UIImage?> (value: nil)
    
    override func react() {
        rxImage.accept(model)
    }
}

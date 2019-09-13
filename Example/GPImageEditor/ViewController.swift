//
//  ViewController.swift
//  GPImageEditor
//
//  Created by starfall-9000 on 09/10/2019.
//  Copyright (c) 2019 starfall-9000. All rights reserved.
//

import UIKit
import FittedSheets
//import GPImageEditor
import RxCocoa
import DTMvvm
import RxSwift

class ViewController: UIViewController {
    @IBOutlet weak var originalImageView: UIImageView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var stickerLayer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIFont.familyNames.forEach({ familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            print(familyName, fontNames)
        })
    }
    
    @IBAction func showStickerPicker() {
        let stickerVC = StickerPickerPage.addSticker(toView: stickerLayer, completion: nil)
        let sheetController = SheetViewController(controller: stickerVC, sizes: [SheetSize.fullScreen])
        sheetController.topCornersRadius = 16
        sheetController.adjustForBottomSafeArea = false
        sheetController.blurBottomSafeArea = false

        self.present(sheetController, animated: false, completion: nil)
    }

    @IBAction func doneAction() {
        StickerPickerPage.mixedImage(originalImage: originalImageView.image!, view: stickerLayer) { [weak self] (image) in
            self?.resultImageView.image = image
        }
    }
    
    @IBAction func addTextAction() {
        GPTextEditorTool.show(inView: stickerLayer)
    }

    @IBAction func showEffectScreen() {
        let effectVC = EffectPage.create(with: originalImageView.image)
        present(effectVC!, animated: true, completion: nil)
    }
}


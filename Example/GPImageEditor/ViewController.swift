//
//  ViewController.swift
//  GPImageEditor
//
//  Created by starfall-9000 on 09/10/2019.
//  Copyright (c) 2019 starfall-9000. All rights reserved.
//

import UIKit
import FittedSheets
import GPImageEditor

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showStickerPicker() {
        let stickerVM = StickerPickerViewModel(model: nil)
        let stickerVC = StickerPickerPage(viewModel: stickerVM, completion:({ [weak self] image
            let sticker = UIImageView(image: image)
            self.view.addSubview(sticker)
        }))
        var sheetController = SheetViewController(controller: stickerVM, sizes: [SheetSize.fullScreen])
        sheetController.topCornersRadius = 16
        sheetController.adjustForBottomSafeArea = true
        sheetController.blurBottomSafeArea = true
        self.present(sheetController, animated: false, completion: nil)
    }

}


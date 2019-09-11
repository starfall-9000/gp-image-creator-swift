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
    @IBOutlet weak var stickerLayer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showStickerPicker() {
        let stickerVC = StickerPickerPage.addSticker(toView: stickerLayer, completion: { [weak self] (sticker) in
            self?.dismiss(animated: true, completion: nil)
        })
        let sheetController = SheetViewController(controller: stickerVC, sizes: [SheetSize.fullScreen])
        sheetController.topCornersRadius = 16
        sheetController.adjustForBottomSafeArea = false
        sheetController.blurBottomSafeArea = false

        self.present(sheetController, animated: false, completion: nil)
    }

}


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
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pickPhoto(sender: UIButton!) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func editPhoto(sender: UIButton!) {
        if let image = imageView.image {
            moveToEditor(with: image)
        }
    }

    func moveToEditor(with image: UIImage?) {
        guard let image = image else {
            return
        }
        GPImageEditor.present(from: self, image: image, animated: true, finished: { [weak self] (image) in
            self?.imageView.image = image
            }, completion: nil)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        dismiss(animated: true) {
            self.moveToEditor(with: image)
        }
    }
}


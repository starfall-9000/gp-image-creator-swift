//
//  StickerCell.swift
//  Action
//
//  Created by ToanDK on 9/10/19.
//

import Foundation
import DTMvvm
import RxSwift
import RxCocoa
import Action

public class StickerCellViewModel: CellViewModel<StickerModel> {
    let rxImageUrl = BehaviorRelay<String?>(value: nil)
    let rxImageName = BehaviorRelay<String?>(value: nil)
    
    override public func react() {
        super.react()
        guard let model = model else { return }
        if !model.localFileName.isEmpty {
            rxImageName.accept(model.localFileName)
        }
        else {
            rxImageUrl.accept(model.imageURL)
        }
    }
}

public class StickerCell: CollectionCell<StickerCellViewModel> {
    
    var photoImg: UIImageView = {
        let photo = UIImageView()
        photo.contentMode = UIView.ContentMode.scaleAspectFit
        return photo
    }()
    
    override public func initialize() {
        backgroundColor = .clear
        contentView.addSubview(photoImg)
        photoImg.autoPinEdgesToSuperviewEdges()
    }
    
    override public func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        guard let viewModel = viewModel else { return }
        
        viewModel.rxImageName.subscribe(onNext: { [weak self] (name) in
            guard let self = self, let name = name, !name.isEmpty else { return }
            self.photoImg.image = UIImage(named: name)
        }) => disposeBag
        
        viewModel.rxImageUrl.subscribe(onNext: { [weak self] imgUrl in
            guard let self = self, let imgUrl = imgUrl, let url = URL(string: imgUrl) else { return }
            self.photoImg.af_setImage(withURL: url)
        }) => disposeBag
    }
}

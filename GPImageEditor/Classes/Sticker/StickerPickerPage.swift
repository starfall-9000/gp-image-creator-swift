//
//  StickerPickerPage.swift
//  Action
//
//  Created by ToanDK on 9/10/19.
//

import Foundation
import RxCocoa
import RxSwift
import DTMvvm

let padding: CGFloat = 20

public class StickerPickerPage: CollectionPage<StickerPickerViewModel> {
    public static func getInstance(completion: ((UIImage?) -> Void)?) -> StickerPickerPage {
        let vm = StickerPickerViewModel(model: nil)
        return StickerPickerPage(viewModel: vm, completion: completion)
    }
    
    private var completion: ((UIImage?) -> Void)? = nil
    
    init(viewModel: StickerPickerViewModel? = nil, completion: ((UIImage?) -> Void)?) {
        super.init(viewModel: viewModel)
        self.completion = completion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func initialize() {
        super.initialize()
        collectionView.register(StickerCell.self, forCellWithReuseIdentifier: StickerCell.identifier)
    }
    
    override public func bindViewAndViewModel() {
        super.bindViewAndViewModel()
    }
    
    override public func cellIdentifier(_ cellViewModel: StickerCellViewModel) -> String {
        return StickerCell.identifier
    }
    
    override public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewWidth = collectionView.frame.width
        
        let numOfCols: CGFloat = 3
        
        let contentWidth = viewWidth - ((numOfCols + 1) * padding)
        let width = contentWidth / numOfCols
        return CGSize(width: width, height: width)
    }
    
    override public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    override public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    override public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .all(padding)
    }
    
    override public func selectedItemDidChange(_ cellViewModel: StickerCellViewModel) {
        guard let indexPath = cellViewModel.indexPath,
            let cell = collectionView(collectionView, cellForItemAt: indexPath) as? StickerCell
            else { return }
        completion?(cell.photoImg.image)
    }
}

public class StickerPickerViewModel: ListViewModel<Model, StickerCellViewModel> {
    override public func react() {
        guard let filePath = GPImageEditorBundle.getBundle().path(forResource: "stickers", ofType: "json")
            else { return }
        let contentString = try? String(contentsOfFile: filePath)
        let stickers: [StickerModel] = StickerModel.fromJSONArray(contentString)
        let items = stickers.map ({ (model) -> StickerCellViewModel in
            return StickerCellViewModel(model: model)
        })
        itemsSource.reset([items], animated: false)
    }
}

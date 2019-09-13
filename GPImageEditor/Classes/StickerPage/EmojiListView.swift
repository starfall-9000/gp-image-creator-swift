//
//  File.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/12/19.
//

import Foundation
import RxCocoa
import RxSwift
import DTMvvm

private let padding: CGFloat = 20

public class EmojiListView: CollectionView<EmojiListViewModel> {
    
    private var completion: ((UIImage?, CGSize) -> Void)? = nil
    
    init(viewModel: EmojiListViewModel? = nil, completion: ((UIImage?, CGSize) -> Void)?) {
        super.init(viewModel: viewModel)
        self.completion = completion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func initialize() {
        super.initialize()
        
        backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
    }
    
    override public func cellIdentifier(_ cellViewModel: EmojiCellViewModel) -> String {
        return EmojiCell.identifier
    }
    
    override public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewWidth = collectionView.frame.width
        
        let numOfCols: CGFloat = 6
        
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
    
    override public func selectedItemDidChange(_ cellViewModel: EmojiCellViewModel) {
        guard let indexPath = cellViewModel.indexPath,
            let cell = collectionView(collectionView, cellForItemAt: indexPath) as? EmojiCell
            else { return }
        completion?(UIImage.imageWithLabel(label: cell.emojiLabel, size: cell.bounds.size), cell.bounds.size)
    }
}

public class EmojiListViewModel: ListViewModel<Model, EmojiCellViewModel> {
    
    override public func react() {
        let emojis = String.getListEmojis()
        let items = emojis.map{ EmojiCellViewModel(model: $0) }
        itemsSource.reset([items], animated: false)
    }
}

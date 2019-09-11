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
    
    private var completion: ((UIImage?) -> Void)? = nil
    private var loadingView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    init(viewModel: StickerPickerViewModel? = nil, completion: ((UIImage?) -> Void)?) {
        super.init(viewModel: viewModel)
        self.completion = completion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func initialize() {
        super.initialize()
        view.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.3)
        collectionView.backgroundColor = .clear
        collectionView.register(StickerCell.self, forCellWithReuseIdentifier: StickerCell.identifier)
        
        view.addSubview(loadingView)
        loadingView.autoCenterInSuperview()
    }
    
    override public func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        guard let viewModel = viewModel else { return }
        viewModel.rxLoading ~> loadingView.rx.isAnimating => disposeBag
        viewModel.rxLoading.map{ !$0 } ~> loadingView.rx.isHidden => disposeBag
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
        dismiss(animated: true) {
            self.destroy()
        }
    }
}

extension StickerPickerPage {
    public static func addSticker(toView view: UIView, completion: ((StickerView?) -> Void)?) -> StickerPickerPage {
        let vm = StickerPickerViewModel(model: nil)
        return StickerPickerPage(viewModel: vm, completion: { image in
            if let image = image {
                let stickerView = StickersLayerView.addSticker(image: image, toView: view)
                completion?(stickerView)
            }
        })
    }
    
    static func getInstance(completion: ((UIImage?) -> Void)?) -> StickerPickerPage {
        let vm = StickerPickerViewModel(model: nil)
        return StickerPickerPage(viewModel: vm, completion: completion)
    }
    
    public static func mixedImage(originalImage: UIImage, view: UIView, completion: @escaping ((UIImage?) -> Void)) {
        guard let stickersLayer = view.subviews.first(where: { (subView) -> Bool in
                subView is StickersLayerView
            }) as? StickersLayerView
            else {
                completion(nil)
                return
        }
        DispatchQueue.global(qos: .background).async {
            let image = stickersLayer.buildImage(image: originalImage)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}

public class StickerPickerViewModel: ListViewModel<Model, StickerCellViewModel> {
    let rxLoading = BehaviorRelay<Bool>(value: false)
    let stickerService: StickerAPIService? = GPImageEditorConfigs.dependencyManager?.getService()
    var page: Int = 0
    
    override public func react() {
        rxLoading.accept(true)
        
        getStickers(page: 0)
    }
    
    func getStickers(page: Int) {
        self.page = page
        if page == 0 {
            itemsSource.reset([[]], animated: false)
        }
        stickerService?.getStickerList(page: page)
            .subscribe(onSuccess: { [weak self] (response) in
                guard let self = self else { return }
                self.rxLoading.accept(false)
                if response.code == .success {
                    let stickers = response.stickers.map{ StickerCellViewModel(model: $0) }
                    self.itemsSource.append(stickers, animated: false)
                }
            }, onError: { [weak self] (error) in
                self?.rxLoading.accept(false)
            }) => disposeBag
    }
}

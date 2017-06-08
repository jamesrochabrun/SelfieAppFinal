//
//  FilterView.swift
//  SelfieAppFinal
//
//  Created by James Rochabrun on 6/7/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol FilterViewDelegate: class {
    func performUpdateAfterImageSaved()
}

class FilterView: UIView {
    
    static let reuseIdentifier = "FilterCell"
    weak var delegate: FilterViewDelegate?
    
    var inputImage: UIImage?  {
        didSet {
            if let inputCoreImage = self.inputImage?.cgImage {
                self.coreImage = CIImage(cgImage: inputCoreImage)
            } else {
                self.coreImage = nil
            }
        }
    }
    
    var coreImage: CIImage?  {
        didSet {
            DispatchQueue.main.async {
                
                let i = IndexPath(item: 0, section: 0)
                self.filtersCollectionView.scrollToItem(at: i, at: .left, animated: false)
                self.filtersCollectionView.reloadData()
            }
        }
    }
    
    let context: CIContext = {
        let openGLContext = EAGLContext(api: .openGLES3)
        let context = CIContext(eaglContext: openGLContext!)
        return context
    }()
    
    lazy var filtersCollectionView: UICollectionView = {
        let layout = ListLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.dataSource = self
        cv.register(FilterCell.self, forCellWithReuseIdentifier: FilterView.reuseIdentifier)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    lazy var saveButton: UIButton = {
        let b = UIButton(type: .custom)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(#imageLiteral(resourceName: "save"), for: .normal)
        b.addTarget(self, action: #selector(saveImageInLibrary), for: .touchUpInside)
        return b
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        addSubview(filtersCollectionView)
        filtersCollectionView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            
            filtersCollectionView.topAnchor.constraint(equalTo: topAnchor),
            filtersCollectionView.leftAnchor.constraint(equalTo: leftAnchor),
            filtersCollectionView.widthAnchor.constraint(equalTo: widthAnchor),
            filtersCollectionView.heightAnchor.constraint(equalTo: heightAnchor),
            
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.widthAnchor.constraint(equalToConstant: 60),
            saveButton.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -80),
            saveButton.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
    }
    
    func saveImageInLibrary() {
        
        let visibleRect = CGRect(origin: self.filtersCollectionView.contentOffset, size: self.filtersCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        if let visibleIndexpath = self.filtersCollectionView.indexPathForItem(at: visiblePoint),
            let filterCell = self.filtersCollectionView.cellForItem(at: visibleIndexpath) as? FilterCell,
            let image = filterCell.photoImageView.image {
            
            print("v I: \(visibleIndexpath.item)")
            try? PHPhotoLibrary.shared().performChangesAndWait { [weak self]  in
                
                guard let strongSelf = self else { return }
                PHAssetChangeRequest.creationRequestForAsset(from: image)
                strongSelf.delegate?.performUpdateAfterImageSaved()
            }
        }
    }
}

extension FilterView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6//number of filters supported by the app
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterView.reuseIdentifier, for: indexPath) as? FilterCell else {
            fatalError()
        }
        if let inputImage = self.coreImage {
            
//            if let outputImage = Filters.init(caseIndex: indexPath.row, inputImage: inputImage).outputImage {
//                if let imageRef = context.createCGImage(outputImage, from: outputImage.extent) {
//                    let newImg = UIImage(cgImage: imageRef)
//                    cell.setUpcell(newImg)
//                }
//            }
        } else {
            cell.setUpcell(nil)
        }
        return cell
    }
}


//
//  ListLayout.swift
//  SelfieAppFinal
//
//  Created by James Rochabrun on 6/7/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit

final class ListLayout: UICollectionViewFlowLayout {
    
    
    override init() {
        super.init()
        minimumLineSpacing = 0
        scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var itemSize: CGSize {
        set {
        }
        get {
            return CGSize(width: (self.collectionView?.frame.width)!, height: (self.collectionView?.frame.height)!)
        }
    }
}

//
//  DynamicHeightCollectionView.swift
//  Calendar
//
//  Created by Paul Tang on 2019-07-12.
//  Copyright © 2019 Paul Tang. All rights reserved.
//

import UIKit

// used on collection view objects to allow dynamic collection view height based on the number of cells,
// source: https://www.freecodecamp.org/news/how-to-make-height-collection-views-dynamic-in-your-ios-apps-7d6ca94d2212/

class DynamicHeightCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

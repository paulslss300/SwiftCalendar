//
//  DynamicHeightTableView.swift
//  Calendar
//
//  Created by Paul Tang on 2019-07-16.
//  Copyright © 2019 Paul Tang. All rights reserved.
//

import UIKit

// source: https://stackoverflow.com/questions/2595118/resizing-uitableview-to-fit-content/48623673#48623673

class DynamicHeightTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

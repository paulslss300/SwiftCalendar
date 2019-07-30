//
//  DateCollectionViewCell.swift
//  Calendar
//
//  Created by Paul Tang on 2019-07-10.
//  Copyright © 2019 Paul Tang. All rights reserved.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var dot: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hideDot()
        resetImageView()
        resetdateLabel()
    }
    
    func showDot() {
        dot.backgroundColor = UIColor(hex: 0xfed798, alpha: 1.0)
        dot.layer.cornerRadius = dot.frame.size.width / 2
        dot.clipsToBounds = true
    }
    
    private func hideDot() {
        dot.backgroundColor = nil
    }
    
    private func resetImageView() {
        imageView.backgroundColor = nil
        imageView.image = nil
    }
    
    private func resetdateLabel() {
        date.text = nil
        date.textColor = UIColor(hex: 0x1b3e46, alpha: 1.0)
    }
    
    func highlightToday() {
        date.textColor = UIColor.orange
    }
    
    func selectToday() {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.backgroundColor = UIColor(hex: 0xf79f6a, alpha: 1.0)
        imageView.clipsToBounds = true
        date.textColor = UIColor.white
    }
    
    func selectDate() {
        imageView.image = UIImage(named: "DateSelected")
    }
}

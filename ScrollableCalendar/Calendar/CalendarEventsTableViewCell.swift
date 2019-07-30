//
//  CalendarEventsTableViewCell.swift
//  Calendar
//
//  Created by Paul Tang on 2019-07-15.
//  Copyright © 2019 Paul Tang. All rights reserved.
//

import UIKit

class CalendarEventsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
        
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var eventDescription: UITextView!
    
    @IBOutlet weak var lineBreak: UIView!
    
    @IBOutlet weak var locationHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // eventDescription ends with truncating tail if text too long
        eventDescription.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail
        // get rid of padding and inset of eventDescription
        eventDescription.textContainerInset = UIEdgeInsets.zero
        eventDescription.textContainer.lineFragmentPadding = 0        
    }
    
    static let lessonTextColor = UIColor(hex: 0xf79f6a, alpha: 1)
    static let eventTextColor = UIColor(hex: 0xfe9a9a, alpha: 1)
    static let deadlineTextColor = UIColor(hex: 0xe07b64, alpha: 1)
    static let lockedTextColor = UIColor(hex: 0x777777, alpha: 1)
    static let assignmentTextColor = UIColor(hex: 0xfec466, alpha: 1)
}

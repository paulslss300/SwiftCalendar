//
//  CalendarDateCollectionViewCell.swift
//  Calendar
//
//  Created by Paul Tang on 2019-07-10.
//  Copyright © 2019 Paul Tang. All rights reserved.
//

import UIKit

class CalendarDateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var calendarDateView: UIView!
    
    // calendar dates collection view
    @IBOutlet weak var calendarDatesCollection: UICollectionView!
    
    // events table view
    @IBOutlet weak var eventsTable: UITableView!
    
    // to display the month and year of a Calendar Month Cell
    @IBOutlet weak var monthYearLabel: UILabel!
    
    // initialize dateList used to populate calendar
    var datesList: [String] = []
    
    // initialize eventsInMonth that contains object received from CalendarViewController.swift
    var eventsInMonth: [CalendarEvent] = []
    
    // received from CalendarViewController.swift used to pass back to CalendarViewController.swift to reload at specific indexPath
    var calendarMonthIndexPath: IndexPath? = nil
    
    // used to check what cell is supposed to be highlighted prior to cell being reloaded
    var IndexOfSelectedDate: IndexPath? = nil
    
    // list to display on eventsTable
    var eventsOfSelectedDate: [CalendarEvent] = []
    
    // if a date selected but no events, display NoEventCell
    var shouldDisplayNoEvents: Bool = false
    
    // used to highlight today's date, received from CalendarViewController
    var todayIndex: Int = -1
    
    let NotificationDateCellTapped = NSNotification.Name(rawValue: "Calendar.DateCellTapped")
    
    override func prepareForReuse() {
        super.prepareForReuse()
        todayIndex = -1
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // initialize calendarDatesCollection
        self.calendarDatesCollection.dataSource = self
        self.calendarDatesCollection.delegate = self
        
        // initialize eventsTable
        self.eventsTable.delegate = self
        self.eventsTable.dataSource = self
    }
}

// configure DateCollectionViewCell
extension CalendarDateCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard
            let cell: DateCollectionViewCell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell,
            let indexPathOfMonthCell = self.calendarMonthIndexPath,
            cell.date.text?.isEmpty == false
            else { return }
        
        let date = datesList[indexPath.row]
        
        // variables passed to CalendarViewController
        let indexOfSelectedDate = indexPath
        var eventsOfSelectedDate: [CalendarEvent] = []
        for event in eventsInMonth {
            if event.startTime.getDateComponent() == Int(date) {
                eventsOfSelectedDate.append(event)
            }
        }
        selectCell(indexPathOfMonth: indexPathOfMonthCell, indexPathOfDate: indexOfSelectedDate, eventsOnDate: eventsOfSelectedDate)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        guard
            let cell: DateCollectionViewCell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell,
            cell.date.text?.isEmpty == false
            else { return false }
        
        // if cell is already selected, deselect cell
        if cell.isSelected, let indexPathOfCalendarCell = self.calendarMonthIndexPath {
            deselectCell(indexPathOfMonth: indexPathOfCalendarCell)
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell: DateCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCollectionViewCell", for: indexPath) as? DateCollectionViewCell else {
            assertionFailure("Error: Failed to deque DateCollectionViewCell.")
            return UICollectionViewCell()
        }
        
        let date = datesList[indexPath.row]
        
        cell.date.text = date
        
        // add dot to the dates that contain events
        for event in eventsInMonth {
            if event.startTime.getDateComponent() == Int(date) {
                cell.showDot()
            }
        }
        // highlight today
        if todayIndex == indexPath.row {
            cell.highlightToday()
        }
        
        // highlight cell if it is selected before the calendar cell is reloaded (expanded)
        if indexPath == self.IndexOfSelectedDate {
            // selected date is today
            if todayIndex == indexPath.row {
                cell.selectToday()
            } else {
                cell.selectDate()
            }
            cell.isSelected = true
        }
        
        return cell
    }
}

// configure CalendarEventsTableViewCell Delegate Functions
extension CalendarDateCollectionViewCell: UITableViewDelegate {
    
    // NOTE: calculateHeight() in CalendarViewController controlls height of calendar collection view cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if shouldDisplayNoEvents {
            return CalendarHeightConstants.cellHeightWithNoEvents
        }
        return CalendarHeightConstants.cellHeightWithEvents
    }
}

// configure CalendarEventsTableViewCell Datasource Functions
extension CalendarDateCollectionViewCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldDisplayNoEvents {
            return 1
        }
        return eventsOfSelectedDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // no events
        if shouldDisplayNoEvents {
            guard let cell: CalendarEventsEmptyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NoEventsCell", for: indexPath) as? CalendarEventsEmptyTableViewCell else {
                assertionFailure("Error: Failed to deque CalendarEventsEmptyTableViewCell.")
                return UITableViewCell()
            }
            return cell
        }
        
        // there are events
        guard let cell: CalendarEventsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CalendarEventsTableViewCell", for: indexPath) as? CalendarEventsTableViewCell else {
            assertionFailure("Error: Failed to deque CalendarEventsTableViewCell.")
            return UITableViewCell()
        }
        
        let event = eventsOfSelectedDate[indexPath.row]
        
        var textColor: UIColor = UIColor.black
        var locationHeight: CGFloat = 17
        var timeString: String = "Time: \(event.startTime.toString(dateFormat: "H:mm a")) - \(event.endTime.toString(dateFormat: "H:mm a"))"
        
        switch event.type {
        case .lesson:
            textColor = CalendarEventsTableViewCell.lessonTextColor
        case .event:
            textColor = CalendarEventsTableViewCell.eventTextColor
        case .deadline:
            textColor = CalendarEventsTableViewCell.deadlineTextColor
            locationHeight = 0
            timeString = "Time: \(event.startTime.toString(dateFormat: "H:mm a"))"
        case .locked:
            textColor = CalendarEventsTableViewCell.lockedTextColor
        case .assignment:
            textColor = CalendarEventsTableViewCell.assignmentTextColor
            locationHeight = 0
            timeString = "Time: \(event.startTime.toString(dateFormat: "H:mm a"))"
        }
        
        cell.title.text = event.title
        cell.title.textColor = textColor
        cell.time.text = timeString
        cell.eventDescription.text = event.description
        cell.location.text = "Location: \(event.locationString ?? "")"
        cell.locationHeightConstraint.constant = locationHeight
        cell.lineBreak.isHidden = false
        
        // if it's the last cell, hide gray lineBreak view
        if indexPath.row == eventsOfSelectedDate.count - 1 {
            cell.lineBreak.isHidden = true
        }
        
        return cell
    }
}

// configure DateCollectionViewCell UICollectionViewFlowLayout
extension CalendarDateCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        let itemSize: CGFloat = calendarDatesCollection.bounds.width / 7.0
        
        return CGSize(width: itemSize, height: itemSize + CalendarHeightConstants.dateCellAddedHeight)
    }
    
    func collectionView(_: UICollectionView, layout: UICollectionViewLayout, insetForSectionAt: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_: UICollectionView, layout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt: Int) -> CGFloat {
        return 0
    }
}

// helper functions regarding CalendarDateCollectionViewCell
extension CalendarDateCollectionViewCell {
    
    func selectCell(indexPathOfMonth: IndexPath, indexPathOfDate: IndexPath, eventsOnDate: [CalendarEvent]) {
        // pass indexPath to reload the cell at the specific indexPath
        let data :[String: Any] = [
            "indexPathOfCalendarCell": indexPathOfMonth,
            "indexOfSelectedDate": indexPathOfDate,
            "eventsOfSelectedDate": eventsOnDate
        ]
        NotificationCenter.default.post(name: NotificationDateCellTapped, object: nil, userInfo: data as [AnyHashable : Any])
    }
    
    func deselectCell(indexPathOfMonth: IndexPath) {
        let data :[String: Any?] = [
            "indexPathOfCalendarCell": indexPathOfMonth,
            "indexOfSelectedDate": nil,
            "eventsOfSelectedDate": []
        ]
        NotificationCenter.default.post(name: NotificationDateCellTapped, object: nil, userInfo: data as [AnyHashable : Any])
    }
}

//
//  CalendarViewController.swift
//  Calendar
//
//  Created by Paul Tang on 2019-07-10.
//  Copyright © 2019 Paul Tang. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarYearCollectionView: UICollectionView!
    
    @IBOutlet weak var extendedNavBar: UIView!

    // initialize calendarEventList, contains all events
    var calendarEventList: [CalendarEvent] = []

    // today's date, used to highlight today on the calendar
    var today = Date()
    
    // array to populate calendar collection view cells
    var MonthEventsViewModelList: [MonthEventsViewModel] = []
    
    // used to store where the previously selected cell is
    var previouslySelectedCalendarDateCellIndexPath: IndexPath? = nil
    
    // initialize values for the start month and end month of calendar
    var programStartMonth = Date()
    var programEndMonth = Date()
    
    override func  viewWillAppear(_ animated: Bool) {
        // display nav bar
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialization calendarDatesCollection
        calendarYearCollectionView.delegate = self
        calendarYearCollectionView.dataSource = self
        // increase deceleration speed
        calendarYearCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        // set contentInset here so that .scrollToItem() will take into account of the insets
        calendarYearCollectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        // add fake data to calendarEventList
        addFakeData()
        // set up nav bar after it's initialized in ViewWillAppear
        setUpNavBar()
        
        // observer for when a date cell is selected
        let calendarDateCollectionViewCell = CalendarDateCollectionViewCell()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCell), name: calendarDateCollectionViewCell.NotificationDateCellTapped, object: nil)
        
        // set up arbitrary values for the start month and end month of calendar
        // IMPORTANT: THE TWO VALUES HAVE TO BE SET UP PRIOR TO CALLING ANY MonthEventsViewModel FUNCTIONS
        if let startMonth = createDate(formatString: "yyyy-MM", dateString: "2019-06"),
            let endMonth = createDate(formatString: "yyyy-MM", dateString: "2020-01") {
            programStartMonth = startMonth
            programEndMonth = endMonth
        }
        
        // set up MonthEventsViewModelList
        MonthEventsViewModelList = setUpMonthEventsViewModelList()
        // when received events data from server, add events to MonthEventsViewModel objects in MonthEventsViewModelList
        addEventsToMonthEventsViewModelList(events: calendarEventList, modelList: &MonthEventsViewModelList)
    }
    
    func setUpNavBar() {
        // set nav bar color
        navigationController?.navigationBar.barTintColor = UIColor(red: 224.0/255.0, green: 123.0/255.0, blue: 100.0/255.0, alpha: 1)
        // set extendedNavBar color (the color doesn't match when setting it in storyboard)
        extendedNavBar.backgroundColor = UIColor(red: 224.0/255.0, green: 123.0/255.0, blue: 100.0/255.0, alpha: 1)
        // set up nav bar button
        let progressBarButtonItem = UIBarButtonItem(image: UIImage(named: "ProgressBarIcon"), style: .plain, target: self, action: #selector(progressBarButtonItemTapped))
        self.navigationItem.rightBarButtonItem  = progressBarButtonItem
        // set up nav bar title and its attributes
        self.title = "Calendar"
        if let font = UIFont(name: "OpenSans-SemiBold", size: 18) {
            navigationController?.navigationBar.titleTextAttributes =
                [NSAttributedString.Key.foregroundColor: UIColor.white,
                 NSAttributedString.Key.font: font]
        }
    }
    
    @objc func progressBarButtonItemTapped() {
        print("nav bar button touched")
    }
    
    @objc func reloadCell(_ notification: NSNotification){
        
        guard let indexPathOfCalendarCell = notification.userInfo?["indexPathOfCalendarCell"] as? IndexPath,
            let eventsForSelectedDate = notification.userInfo?["eventsOfSelectedDate"] as? [CalendarEvent]
        else { return }
        let indexPathOfSelectedDate = notification.userInfo?["indexOfSelectedDate"] as? IndexPath
        
        if let previouslySelectedCalendarDateCellIndexPath = self.previouslySelectedCalendarDateCellIndexPath {
            // clear data for the previously selected month event
            MonthEventsViewModelList[previouslySelectedCalendarDateCellIndexPath.row].indexPathOfSelectedDate = nil
            MonthEventsViewModelList[previouslySelectedCalendarDateCellIndexPath.row].eventsForSelectedDate = []
            MonthEventsViewModelList[previouslySelectedCalendarDateCellIndexPath.row].shouldDisplayNoEvents = false
        }
        
        // upate selection status
        MonthEventsViewModelList[indexPathOfCalendarCell.row].indexPathOfSelectedDate = indexPathOfSelectedDate
        MonthEventsViewModelList[indexPathOfCalendarCell.row].eventsForSelectedDate = eventsForSelectedDate
        if eventsForSelectedDate.count == 0 && indexPathOfSelectedDate != nil {
            MonthEventsViewModelList[indexPathOfCalendarCell.row].shouldDisplayNoEvents = true
        } else {
            MonthEventsViewModelList[indexPathOfCalendarCell.row].shouldDisplayNoEvents = false
        }
        
        // reload
        if let previouslySelectedCalendarDateCellIndexPath = self.previouslySelectedCalendarDateCellIndexPath {
            // if selected a date from a different month (another CalendarDateCollectionViewCell), reload both the previously selected cell and the current cell
            if previouslySelectedCalendarDateCellIndexPath != indexPathOfCalendarCell {
                self.calendarYearCollectionView.reloadItems(at: [indexPathOfCalendarCell, previouslySelectedCalendarDateCellIndexPath])
            } else {
                self.calendarYearCollectionView.reloadItems(at: [indexPathOfCalendarCell])
            }
        } else {
            self.calendarYearCollectionView.reloadItems(at: [indexPathOfCalendarCell])
        }
        
        // overwrite previouslySelectedCalendarDateCellIndexPath with current one
        self.previouslySelectedCalendarDateCellIndexPath = indexPathOfCalendarCell
        
        // scroll to item after reload
        self.calendarYearCollectionView.scrollToItem(at:IndexPath(item: indexPathOfCalendarCell.row, section: indexPathOfCalendarCell.section), at: .top, animated: true)
    }    
}

// configure calendarYearCollectionView
extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MonthEventsViewModelList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell: CalendarDateCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCollectionViewCell", for: indexPath) as? CalendarDateCollectionViewCell {
            
            let monthEvent = MonthEventsViewModelList[indexPath.row]
            // pass values to cell
            cell.calendarMonthIndexPath = indexPath
            cell.monthYearLabel.text = monthEvent.month.toString(dateFormat: "MMMM y")
            cell.datesList = monthEvent.dates
            cell.eventsInMonth = monthEvent.events
            if isInSameMonth(date1: today, date2: monthEvent.month) {
                if let todayIndex: Int = monthEvent.dates.firstIndex(of: "\(today.getDateComponent())") {
                    cell.todayIndex = todayIndex
                }
            }
            cell.IndexOfSelectedDate = monthEvent.indexPathOfSelectedDate
            cell.eventsOfSelectedDate = monthEvent.eventsForSelectedDate
            cell.shouldDisplayNoEvents = monthEvent.shouldDisplayNoEvents
            // update collectionview/ tableview in cell
            cell.calendarDatesCollection.reloadData()
            cell.eventsTable.reloadData()
            
            // adding rounded corner and drop shadow, source: https://stackoverflow.com/questions/13505379/adding-rounded-corner-and-drop-shadow-to-uicollectionviewcell
            cell.contentView.layer.cornerRadius = 6.0
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.masksToBounds = true
            // solution to fix the top 2 corners not rounded
            cell.layer.backgroundColor = UIColor.clear.cgColor

            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            cell.layer.shadowRadius = 4.0
            cell.layer.shadowOpacity = 0.5
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
                        
            return cell
            
        } else {
            assertionFailure("Error: Failed to deque cell.")
            return UICollectionViewCell()
        }
    }
}

// configure calendarYearCollectionView UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let monthEvent = MonthEventsViewModelList[indexPath.row]
        // calculate size
        let margin: CGFloat = 25
        // note: making sure width is a multiple of 7
        let width = calendarYearCollectionView.bounds.width - margin + (calendarYearCollectionView.bounds.width - margin).truncatingRemainder(dividingBy: 7.0)
        let height = calculateHeight(numberOfEvents: monthEvent.eventsForSelectedDate.count, numberOfDays: monthEvent.dates.count, calendarCellWidth: width, shouldDisplayNoEvents: monthEvent.shouldDisplayNoEvents)
        return CGSize(width: width, height: height)
    }
    
    // set spacing between cells
    func collectionView(_: UICollectionView, layout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat {
        return 20
    }
}

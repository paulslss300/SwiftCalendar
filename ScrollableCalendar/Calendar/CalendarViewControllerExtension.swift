//
//  CalendarViewControllerExtension.swift
//  GoA
//
//  Created by Paul Tang on 2019-07-30.
//  Copyright © 2019 Game of Apps. All rights reserved.
//

import UIKit

extension CalendarViewController {
    
    func addFakeData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        // initialize dates
        guard let date1 = formatter.date(from: "2019-6-08 10:10"),
            let date2 = formatter.date(from: "2019-07-08 10:10"),
            let date3 = formatter.date(from: "2019-12-24 10:10"),
            let date4 = formatter.date(from: "2020-01-01 10:10"),
            let date5 = formatter.date(from: "2019-06-15 10:10"),
            let date6 = formatter.date(from: "2019-12-31 10:10")
            else { return }
        
        // initialize assignments
        let assignment1 = NewAssignment(description: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu.", dueTime: date5)
        let assignment2 = NewAssignment(description: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu.", dueTime: date6)
        
        // initialize lessons
        let lesson1 = NewLesson(documentId: nil, title: "Design Lesson Longggggggg", description: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu.", type: .design, slides: nil, assignment: assignment1, challenge: nil, resources: [])
        let lesson2 = NewLesson(documentId: nil, title: "Dev Lesson", description: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu.", type: .development, slides: nil, assignment: assignment2, challenge: nil, resources: [])
        
        // initialize cohort lessons
        let cohortLesson1 = CohortLesson(lesson: lesson1, startTime: date1, endTime: date1, locationString: "Richmond Public Library")
        let cohortLesson2 = CohortLesson(lesson: lesson2, startTime: date3, endTime: date3, locationString: "Richmond Public Library")
        
        // initialize events
        let event1 = Event(title: "Event 1", startTime: date2, endTime: date2, locationString: "Richmond Public Library", description: "Lorem ipsum dolor sit er elit lamet.")
        let event2 = Event(title: "Event 2 longggggggggggggggggggggggggg", startTime: date4, endTime: date4, locationString: "Richmond Public Library", description: "Lorem ipsum dolor sit er elit lamet.")
        
        // initialize deadlines
        let deadline1 = ProgressStage(title: "Deadline 1 longgggggg", description: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu.", date: date1)
        let deadline2 = ProgressStage(title: "Deadline 2", description: "Lorem ipsum dolor sit er elit lamet", date: date2)
        
        // adding data
        calendarEventList += [
            eventToCalendarEvent(event: event1),
            eventToCalendarEvent(event: event2),
            progressStageToCalendarEvent(progressStage: deadline1),
            progressStageToCalendarEvent(progressStage: deadline2)
        ]
        calendarEventList += cohortLessonToCalendarEvent(cohortLesson: cohortLesson1)
        calendarEventList += cohortLessonToCalendarEvent(cohortLesson: cohortLesson2)
    }

    /** calculation used for the sizeForItemAt of CalendarDateCollectionViewCell */
    func calculateHeight(numberOfEvents: Int, numberOfDays: Int, calendarCellWidth: CGFloat, shouldDisplayNoEvents: Bool) -> CGFloat {
        
        // components of height calculation:
        // 1. dynamic height eventsTable
        // 2. dynamic height calendarDatesCollection
        // 3. fixed height Calendar - Top Banner (CalendarHeightConstants.CalendarHeaderHeight px)
        // 4. fixed height Line Break View (7 px)
        // 5. Expanded Calendar View's overlap with Calendar Date View (2 px)
        // 6. NoEventCell height (CalendarHeightConstants.cellHeightWithNoEvents px)
        
        // calculate height of dates collection
        let numberOfEventsCG = CGFloat(numberOfEvents)
        let height1: CGFloat = CGFloat((((numberOfDays - 1) / 7) + 1)) * (calendarCellWidth / 7 + CalendarHeightConstants.dateCellAddedHeight) // number of rows * height per row
        // calculate height of events table
        let height2: CGFloat = numberOfEventsCG * CalendarHeightConstants.cellHeightWithEvents
        // add height of constant values
        let height3: CGFloat = CalendarHeightConstants.CalendarHeaderHeight + 7 - 2
        // if no events, reserve space for the NoEventsCell
        var height4: CGFloat = 0
        if shouldDisplayNoEvents {
            height4 = CalendarHeightConstants.cellHeightWithNoEvents
        }
        
        return height1 + height2 + height3 + height4
    }
    
    // -------------------------------
    // MARK: FUNCTIONS RELATED TO DATE
    // -------------------------------
    
    /** returns date with "y" and "M" */
    func createMonthsListFor(startDate: Date, endDate: Date) -> [Date] {
        // initialize list to return
        var monthsList: [Date] = []
        
        // get month and year of the date
        let calendar = Calendar.current
        
        // get starting month and year
        let startComponents = calendar.dateComponents([Calendar.Component.month, Calendar.Component.year], from: startDate)
        guard var startMonth = startComponents.month, var startYear = startComponents.year else { return []}
        // get ending month and year
        let endComponents = calendar.dateComponents([Calendar.Component.month, Calendar.Component.year], from: endDate)
        guard let endMonth = endComponents.month, let endYear = endComponents.year else { return []}
        
        var finished: Bool = false
        
        // check if startDate is actually smaller or the same as endDate
        if startMonth >= endMonth && startYear == endYear || startYear >= endYear {
            return []
        }
        
        // create Date objects with year and month components, starting from the startDate till endDate
        while !finished {
            
            // check if done
            if startMonth == endMonth && startYear == endYear {
                finished = true
                // do not break because we still want to add the end month to monthsList
            }
            
            // creating/adding new Date object to return list
            var newComponents = DateComponents()
            newComponents.month = startMonth
            newComponents.year = startYear
            guard let newDate = calendar.date(from: newComponents) else { return []}
            monthsList.append(newDate)
            
            // increase month
            startMonth += 1
            
            // update year/month if passing to the next year
            if startMonth == 13 {
                startMonth = 1
                startYear += 1
            }
        }
        
        return monthsList
    }
    
    /** returns whether two dates are the same (comparing only the year, month, and date components of the 2 dates) */
    func isInSameMonth(date1: Date, date2: Date) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.isDate(date1, equalTo: date2, toGranularity:.month)
    }
    
    func createDate(formatString: String, dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        return formatter.date(from: dateString)
    }
    
    // -------------------------------------
    // MARK: FUNCTIONS RELATED TO VIEW MODEL
    // -------------------------------------
    
    /** including lesson to calendar event and assignment to calendar event */
    func cohortLessonToCalendarEvent(cohortLesson: CohortLesson) -> [CalendarEvent] {
        
        var eventType: CalendarEvent.EventType
        let today = Date()
        
        if cohortLesson.startTime > today {
            eventType = .locked
        } else {
            eventType = .lesson
        }
        
        // lesson to calendar event
        let lesson = cohortLesson.lesson
        let newCalendarEventFromLesson: CalendarEvent = CalendarEvent(lesson: lesson, title: lesson.title, description: lesson.description, startTime: cohortLesson.startTime, endTime: cohortLesson.endTime, locationString: cohortLesson.locationString, type: eventType)
        
        // assignment to calendar event (also using variables from lesson)
        if let assignment = lesson.assignment {
            let newCalendarEventFromAssignment: CalendarEvent = CalendarEvent(lesson: nil, title: "Assignment - \(lesson.title)", description: assignment.description, startTime: assignment.dueTime, endTime: assignment.dueTime, locationString: nil, type: .assignment)
            
            return [newCalendarEventFromLesson, newCalendarEventFromAssignment]
        }
        
        return [newCalendarEventFromLesson]
    }
    
    func eventToCalendarEvent(event: Event) -> CalendarEvent {
        let newCalendarEvent: CalendarEvent = CalendarEvent(lesson: nil, title: event.title, description: event.description, startTime: event.startTime, endTime: event.endTime, locationString: event.locationString, type: .event)
        return newCalendarEvent
    }
    
    func progressStageToCalendarEvent(progressStage: ProgressStage) -> CalendarEvent {
        let newCalendarEvent: CalendarEvent = CalendarEvent(lesson: nil, title: progressStage.title, description: progressStage.description, startTime: progressStage.date, endTime: progressStage.date, locationString: nil, type: .deadline)
        return newCalendarEvent
    }
    
    func setUpMonthEventsViewModelList() -> [MonthEventsViewModel] {
        var returnList: [MonthEventsViewModel] = []
        let monthList = createMonthsListFor(startDate: programStartMonth, endDate: programEndMonth)
        for month in monthList {
            // set up a new MonthEventsViewModel
            var newMonthEventsViewModel = MonthEventsViewModel()
            newMonthEventsViewModel.month = month
            newMonthEventsViewModel.dates = month.createDatesList()
            returnList.append(newMonthEventsViewModel)
        }
        return returnList
    }
    
    func addEventsToMonthEventsViewModelList(events: [CalendarEvent] ,modelList: inout [MonthEventsViewModel]) {
        let (monthOfStartingMonth, yearOfStartingMonth) = modelList[0].month.getMonthAndYearComponents()
        
        for event in events {
            let (monthOfEvent, yearOfEvent) = event.startTime.getMonthAndYearComponents()
            let rebasedTimeEvent = 12 * (yearOfEvent - yearOfStartingMonth) + (monthOfEvent - monthOfStartingMonth)
            modelList[rebasedTimeEvent].events.append(event)
        }
    }
}

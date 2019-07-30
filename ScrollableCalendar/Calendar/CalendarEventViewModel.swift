//
//  CalendarEventViewModel.swift
//  GoA
//
//  Created by Paul Tang on 2019-07-26.
//  Copyright © 2019 Game of Apps. All rights reserved.
//

import Foundation

struct CalendarEvent {
    let lesson: NewLesson?
    let title: String
    let description: String
    let startTime: Date
    let endTime: Date
    let locationString: String?
    let type: EventType
    
    enum EventType: String {
        case lesson
        case event
        case locked
        case deadline
        case assignment
    }
}

struct MonthEventsViewModel {
    var month: Date
    var dates: [String]
    var events: [CalendarEvent]
    var shouldDisplayNoEvents: Bool
    var eventsForSelectedDate: [CalendarEvent]
    var indexPathOfSelectedDate: IndexPath?
    
    init() {
        month = Date()
        dates = []
        events = []
        shouldDisplayNoEvents = false
        eventsForSelectedDate = []
        indexPathOfSelectedDate = nil
    }
}

//
//  DateExtension.swift
//  GoA
//
//  Created by Paul Tang on 2019-07-30.
//  Copyright © 2019 Game of Apps. All rights reserved.
//

import Foundation

extension Date {
    /**
     turn a Date object to a string confirming to the inputted format
     
     How to use:
     let today = Date()
     today.toString(dateFormat: "dd-MM")
     **/
    func toString(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    /** gets the day of the week in type Int, e.g. Sunday -> 0, Monday -> 1, etc. */
    func getDayOfWeekFunc() -> Int {
        let myCalendar = Calendar(identifier: .gregorian)
        // IMPORTANT: THE -1 IS CRUCIAL, myCalendar.component(.weekday, from: todayDate) RETURNS 1 TO 7
        // FROM SUNDAY TO SATURDAY, BUT WE WANT THE VALUES TO BE FROM 0 TO 6, SINCE weekDay
        // DETERMINES THE # OF FILLER (BLANK) ELEMTENTS TO ADD BEFORE THE 1ST DAY OF A MONTH
        // IS ADDED TO BE DISPLAYED
        let weekDay = myCalendar.component(.weekday, from: self) - 1
        return weekDay
    }
    
    /** returns the number of days in a given Date object (month and year) */
    func getNumberOfDaysInMonth() -> Int? {
        
        let calendar = Calendar.current
        
        guard let interval = calendar.dateInterval(of: .month, for: self),
            let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day
            else { return nil}
        
        return days
    }
    
    /** return a datesList for display given a Date object (only the month and year are used in the func) */
    func createDatesList() -> [String] {
        
        // initialize list to return
        var datesList: [String] = []
        
        // get # of days in the month
        guard let days = self.getNumberOfDaysInMonth() else { return []}
        
        // get first date of the week
        let firstDay = self.getDayOfWeekFunc()
        
        // add dates to datesList
        datesList.append(contentsOf: repeatElement("", count: firstDay))
        for date in 1...days {
            datesList.append(String(date))
        }
        return datesList
    }
    
    /** returns the .day component of a Date object */
    func getDateComponent() -> Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: self)
    }
    
    /** returns the .month and .year components of a Date object */
    func getMonthAndYearComponents() -> (Int, Int) {
        let calendar = Calendar.current
        return (calendar.component(.month, from: self), calendar.component(.year, from: self))
    }
}

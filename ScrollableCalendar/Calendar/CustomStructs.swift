//
//  CustomStructs.swift
//  Calendar
//
//  Created by Paul Tang on 2019-07-15.
//  Copyright © 2019 Paul Tang. All rights reserved.
//

import UIKit

struct Event {
    var title: String
    var startTime: Date
    var endTime: Date
    var locationString: String
    var description: String
}

struct CohortLesson {
    let lesson : NewLesson
    let startTime: Date
    let endTime: Date
    let locationString: String
}

struct ProgressStage {
    let title: String
    let description: String
    let date: Date
}

struct Slides {
    
    // MARK: - Public properties
    let documentId: String?
    let urlString: String
}

struct Challenge {
    
    // MARK: - Public properties
    let documentId: String?
    let questions: [Int]
    let badge: String
}

struct Resource {
    
    // MARK: - Public properties
    let documentId: String?
    let description: String
    let format: Format
    let type: ResourceType
    let urlString: String
    let imageUrlString: String
    
    enum Format: String {
        case video
        case website
    }
    
    enum ResourceType: String {
        case development
        case design
    }
}

struct NewLesson {
    let documentId: String?
    let title: String
    let description: String
    let type: LessonType
    let slides: Slides?
    let assignment: NewAssignment?
    let challenge: Challenge?
    let resources: [Resource]
    
    enum LessonType: String {
        case development
        case design
    }
}

struct NewAssignment {
    let description: String
    let dueTime: Date
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

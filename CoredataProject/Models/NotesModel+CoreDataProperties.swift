//
//  NotesModel+CoreDataProperties.swift
//  CoredataProject


import Foundation
import CoreData


extension NotesModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotesModel> {
        return NSFetchRequest<NotesModel>(entityName: "NotesModel")
    }

    @NSManaged public var date: Date?
    @NSManaged public var heading: String?
    @NSManaged public var text: String?
    @NSManaged public var isCompleted: Bool

}

extension NotesModel : Identifiable {
    func month() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        if let dateToBeFormatted = date{
            let month = dateFormatter.string(from: dateToBeFormatted)
            return month.uppercased()
        }
        return ""
    }
    
    func day() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        if let dateToBeFormatted = date{
            let day = dateFormatter.string(from: dateToBeFormatted)
            return day
        }
        return ""
    }
    
    //EEEE, MMM d, yyyy
    func formattedDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        if let dateToBeFormatted = date{
            let formattedDate = dateFormatter.string(from: dateToBeFormatted)
            return formattedDate
        }
        return ""
    }
    
    func DateAndYear() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        if let dateToBeFormatted = date{
            let dateAndYear = dateFormatter.string(from: dateToBeFormatted)
            return dateAndYear
        }
        return ""
    }
}

//
//  OneGainedPoint+CoreDataProperties.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 21/11/2021.
//
//

import Foundation
import CoreData


extension OneGainedPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OneGainedPoint> {
        return NSFetchRequest<OneGainedPoint>(entityName: "OneGainedPoint")
    }

    @NSManaged public var isIcrementingTeamA: Bool
    @NSManaged public var isIcrementingTeamB: Bool
    @NSManaged public var timeStamp: Date?

}

extension OneGainedPoint : Identifiable {

}

//
//  2_3MigrationPolicy.swift
//  CoreDataMigrationGuide
//
//  Created by Philipp Weiß on 16.10.19.
//  Copyright © 2019 PMW. All rights reserved.
//

import UIKit
import CoreData

class MigrationPolicy: NSEntityMigrationPolicy {

	override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
		if sInstance.entity.name == "Person" {
			let firstName = sInstance.primitiveValue(forKey: "firstname") as? String
			let lastName = sInstance.primitiveValue(forKey: "lastname") as? String
			let age = sInstance.primitiveValue(forKey: "age") as? Int
			let isTeacher = sInstance.primitiveValue(forKey: "teacher") as? Bool

			let person = isTeacher == true ? NSEntityDescription.insertNewObject(forEntityName: "Teacher", into: manager.destinationContext) : NSEntityDescription.insertNewObject(forEntityName: "Student", into: manager.destinationContext)

			person.setValue(firstName, forKey: "firstName")
			person.setValue(lastName, forKey: "lastName")
			person.setValue(age, forKey: "age")
		}
	}
}

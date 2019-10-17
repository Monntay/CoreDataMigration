//
//  2_3MigrationPolicy.swift
//  CoreDataMigrationGuide
//
//  Created by Philipp Weiß on 16.10.19.
//  Copyright © 2019 PMW. All rights reserved.
//

import UIKit
import CoreData

class SchoolClassMigrationPolicy: NSEntityMigrationPolicy {

	@objc func convertSchoolClass(_ value: Int, with date: String) -> Int {
//		guard let stateEnum = CoreFarmActivityState(rawValue: value) else { return value }
//
//		return (date.isDate(after: Date()) && stateEnum == CoreFarmActivityState.done) ? CoreFarmActivityState.open.rawValue : value

		return 1
	}
}

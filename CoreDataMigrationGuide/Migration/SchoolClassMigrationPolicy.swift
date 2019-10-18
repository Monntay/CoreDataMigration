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

	@objc func convertSchoolClass(_ value: String, with lastname: String) -> String {

		if value == "8" && lastname == "lastname_" {
			return "3a"
		} else {
			return "1c"
		}
	}
}

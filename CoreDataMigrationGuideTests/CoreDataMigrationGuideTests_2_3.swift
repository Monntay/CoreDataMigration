//
//  CoreDataMigrationGuideTests.swift
//  CoreDataMigrationGuideTests
//
//  Created by Philipp Weiß on 16.10.19.
//  Copyright © 2019 PMW. All rights reserved.
//

import XCTest
import CoreData
@testable import CoreDataMigrationGuide

class CoreDataMigrationGuideTests_2_3: XCTestCase {

	// the url for the sqlite file
	private var url: URL { return self.getDocumentsDirectory().appendingPathComponent("CoreDataMigration2TestURL.sqlite") }
	private var newUrl: URL { return self.getDocumentsDirectory().appendingPathComponent("CoreDataMigration2TestURLNew.sqlite") }


	// helper to get the doctuments dir
	private func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}

	// remore the test sqlite file
	private func clearData() {
		try? FileManager.default.removeItem(at: self.url)
		try? FileManager.default.removeItem(at: self.newUrl)
	}

	override func setUp() {
		self.clearData()
	}

	override func tearDown() {
		self.clearData()
	}

	// we will test the migration from version 1 to 2. the names of a person changed.
    func testHeavyWeightMigration() {
		// read and load the old model
		let oldModelURL = Bundle(for: AppDelegate.self).url(forResource: "CoreDataMigrationGuide.momd/CoreDataMigrationGuide 2", withExtension: "mom")!
		let oldManagedObjectModel = NSManagedObjectModel(contentsOf: oldModelURL)
		XCTAssertNotNil(oldManagedObjectModel)

		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: oldManagedObjectModel!)

		try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)

		let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator

		// adding a person to the old db
		let personTeacher = NSEntityDescription.insertNewObject(forEntityName: "Person", into: managedObjectContext)
		personTeacher.setValue("lastname_", forKey: "lastname")
		personTeacher.setValue("firstname_", forKey: "firstname")
		personTeacher.setValue(true, forKey: "teacher")
		personTeacher.setValue("44", forKey: "age")

		let personStudent = NSEntityDescription.insertNewObject(forEntityName: "Person", into: managedObjectContext)
		personStudent.setValue("lastname_", forKey: "lastname")
		personStudent.setValue("firstname_", forKey: "firstname")
		personStudent.setValue(false, forKey: "teacher")
		personStudent.setValue("8", forKey: "age")

		try! managedObjectContext.save()

		// migrate the store to the new model version

		let newModelURL = Bundle(for: AppDelegate.self).url(forResource: "CoreDataMigrationGuide.momd/CoreDataMigrationGuide 3", withExtension: "mom")!
		let newManagedObjectModel = NSManagedObjectModel(contentsOf: newModelURL)

		let mappingModel = NSMappingModel(from: nil, forSourceModel: oldManagedObjectModel, destinationModel: newManagedObjectModel)
		let migrationManager = NSMigrationManager(sourceModel: oldManagedObjectModel!, destinationModel: newManagedObjectModel!)

		try! migrationManager.migrateStore(from: self.url, sourceType: NSSQLiteStoreType, options: nil, with: mappingModel, toDestinationURL: self.newUrl, destinationType: NSSQLiteStoreType, destinationOptions: nil)

		let newCoordinbator = NSPersistentStoreCoordinator(managedObjectModel: newManagedObjectModel!)
		try! newCoordinbator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.newUrl, options: nil)
		let newManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		newManagedObjectContext.persistentStoreCoordinator = newCoordinbator

		// test the migration
		let newStudentRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
		let newStudent = try! newManagedObjectContext.fetch(newStudentRequest) as! [NSManagedObject]
		XCTAssertEqual(newStudent.count, 1)
		XCTAssertEqual(newStudent.first?.value(forKey: "firstName") as? String, "firstname_")
		XCTAssertEqual(newStudent.first?.value(forKey: "lastName") as? String, "lastname_")
		XCTAssertEqual(newStudent.first?.value(forKey: "age") as? String, "8")

		let newTeacherRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Teacher")
		let newTeacher = try! newManagedObjectContext.fetch(newTeacherRequest) as! [NSManagedObject]
		XCTAssertEqual(newTeacher.count, 1)
		XCTAssertEqual(newTeacher.first?.value(forKey: "firstName") as? String, "firstname_")
		XCTAssertEqual(newTeacher.first?.value(forKey: "lastName") as? String, "lastname_")
		XCTAssertEqual(newTeacher.first?.value(forKey: "age") as? String, "44")
    }
}

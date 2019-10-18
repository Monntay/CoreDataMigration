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

class CoreDataMigrationGuideTests_1_2: XCTestCase {

	// the url for the sqlite file
	private var url: URL { return self.getDocumentsDirectory().appendingPathComponent("CoreDataMigration1TestURL.sqlite") }

	// helper to get the doctuments dir
	private func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}

	// remore the test sqlite file
	private func clearData() {
		try? FileManager.default.removeItem(at: url)
	}

	override func setUp() {
		self.clearData()
	}

	override func tearDown() {
		self.clearData()
	}

	// we will test the migration from version 1 to 2. the names of a person changed.
    func testLightWeightMigration() {
		// read and load the old model
		let oldModelURL = Bundle(for: AppDelegate.self).url(forResource: "CoreDataMigrationGuide.momd/CoreDataMigrationGuide", withExtension: "mom")!
		let oldManagedObjectModel = NSManagedObjectModel(contentsOf: oldModelURL)
		XCTAssertNotNil(oldManagedObjectModel)

		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: oldManagedObjectModel!)

		try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)

		let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator

		// adding a person to the old db
		let person = NSEntityDescription.insertNewObject(forEntityName: "Person", into: managedObjectContext)
		person.setValue("name_", forKey: "name")
		person.setValue("surname_", forKey: "surname")
		person.setValue(true, forKey: "teacher")

		try! managedObjectContext.save()

		// migrate the store to the new model version

		let newModelURL = Bundle(for: AppDelegate.self).url(forResource: "CoreDataMigrationGuide.momd/CoreDataMigrationGuide 2", withExtension: "mom")!
		let newManagedObjectModel = NSManagedObjectModel(contentsOf: newModelURL)

		let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]

		let newCoordinbator = NSPersistentStoreCoordinator(managedObjectModel: newManagedObjectModel!)
		try! newCoordinbator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
		let newManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		newManagedObjectContext.persistentStoreCoordinator = newCoordinbator

		// test the migration
		let newPersonRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
		let newPersons = try! newManagedObjectContext.fetch(newPersonRequest) as! [NSManagedObject]
		XCTAssertEqual(newPersons.count, 1)
		XCTAssertEqual(newPersons.first?.value(forKey: "firstname") as? String, "name_")
		XCTAssertEqual(newPersons.first?.value(forKey: "lastname") as? String, "surname_")
		XCTAssertEqual(newPersons.first?.value(forKey: "teacher") as? Bool, true)
		XCTAssertEqual(newPersons.first?.value(forKey: "age") as? Int, nil)
    }
}

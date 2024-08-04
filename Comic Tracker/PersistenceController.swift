//
//  PersistenceController.swift
//  Comic Tracker
//
//  Created by James Coldwell on 4/8/2024.
//
// This class will be used for loading/unloading and backing up and restoring my data from icloud
// In the case where i change the Data Structures that are saved to disc they wont be able to be
// correctly loaded so ill need to restore from a backed up json file instead

import SwiftUI
import SwiftData
import CloudKit

class PersistenceController: ObservableObject {
	static let shared = PersistenceController()
	
	let container: ModelContainer
	@Published var context: ModelContext
	
	init() {
		let schema = Schema([
			ComicData.self,
		])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
		
		do {
			self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
			self.context = ModelContext(self.container)
		} catch {
			// this shouldnt run since itll never load data from the disc since im only storing it in memory
			// itll load the data from my backup file everytime
			fatalError("Could not create ModelContainer: \(error)")
		}
		
		// lastly load my saved backup data from disc
		loadData()
	}
	
	/// This is not the backup function. This should only be used internally in the Persistance Conteoller to save the context if needed. Ill be writing to my own backup file myself
	func saveContext() {
		do {
			try context.save()
		} catch {
			let nserror = error as NSError
			print("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}
	
	func saveAllData() -> Bool {
		let fetchRequest = FetchDescriptor<ComicData>()
		
		do {
			let comics = try context.fetch(fetchRequest)
			let encoder = JSONEncoder()
			let data = try encoder.encode(comics)
			let url = getBackupDirectory().appendingPathComponent("backup.json")
			try data.write(to: url)
			print("Backup successful")
			return true
		} catch {
			print("Failed to back up data: \(error)")
			return false
		}
	}
	
	private func getBackupDirectory() -> URL {
		let fileManager = FileManager.default
		guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("Could not find directory")
		}
		
		let backupDirectory = documentsDirectory.appendingPathComponent("Comic Tracker")
		
		// Create the directory if it doesn't exist
		if !fileManager.fileExists(atPath: backupDirectory.path) {
			do {
				try fileManager.createDirectory(at: backupDirectory, withIntermediateDirectories: true, attributes: nil)
			} catch {
				fatalError("Could not create backup directory: \(error)")
			}
		}
		
		print(backupDirectory.absoluteString)
		
		return backupDirectory
	}
	
	func loadData() {
		do {
			// load the most recent backup file and get all of the elements from that file
			let url = getBackupDirectory().appendingPathComponent("backup.json")
			guard let data = try? Data(contentsOf: url) else {
				print("No backup file to load, starting with empty context")
				return
			}
			let decoder = JSONDecoder()
			let comics = try decoder.decode([ComicData].self, from: data)
			
			for comic in comics {
				let newComic = ComicData(
					readId: comic.readId,
					brand: comic.brand,
					seriesName: comic.seriesName,
					individualComicName: comic.individualComicName,
					yearFirstPublished: comic.yearFirstPublished,
					issueNumber: comic.issueNumber,
					totalPages: comic.totalPages,
					eventName: comic.eventName,
					purpose: comic.purpose,
					dateRead: comic.dateRead
				)
				self.context.insert(newComic)
			}
			
			self.saveContext()
			print("Successfully loaded " + String(comics.count) + " comics")
		} catch {
			print("Failed to decode data: \(error)")
		}
	}
}

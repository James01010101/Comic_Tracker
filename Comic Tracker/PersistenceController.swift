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
	
	let comicDataBackupFilename: String = "backup_comic_data.json"
	let comicSeriesBackupFilename: String = "backup_comic_series.json"
	let comicEventBackupFilename: String = "backup_comic_event.json"
	
	init() {
		let schema = Schema([
			ComicData.self,
			ComicSeries.self,
			ComicEvent.self,
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
		let loadResult = loadAllData()
		if (loadResult == false) {
			fatalError("Could not load all data files")
		}
		// else if nil or true continue on nil will already print messages to debug
				
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
	
	// get the directory for the back up
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
		
		//print(backupDirectory.absoluteString)
		return backupDirectory
	}
	
	// this just saves the comic data file
	func saveComicData() -> Bool {
		let fetchRequestComicData = FetchDescriptor<ComicData>()

		do {
			let comics = try context.fetch(fetchRequestComicData)
			let encoder = JSONEncoder()
			let data = try encoder.encode(comics)
			let url = getBackupDirectory().appendingPathComponent(comicDataBackupFilename)
			try data.write(to: url)
		} catch {
			print("Failed to back up comic data data: \(error)")
			return false
		}
		return true
	}
	
	// load the comic data file
	func loadComicData() -> Bool? {
		do {
			// load the most recent backup file and get all of the elements from that file
			let url = getBackupDirectory().appendingPathComponent(comicDataBackupFilename)
			guard let data = try? Data(contentsOf: url) else {
				print("No backup file to load, starting with empty comic data")
				return nil
			}
			let decoder = JSONDecoder()
			let comics = try decoder.decode([ComicData].self, from: data)
			
			for comic in comics {
				let newComic = ComicData(
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
			print("Failed to decode comic data: \(error)")
			return false
		}
		return true
	}
	
	
	// this just saves the comic series file
	func saveComicSeries() -> Bool {
		let fetchRequestComicSeries = FetchDescriptor<ComicSeries>()
		
		do {
			let comicsSeries = try context.fetch(fetchRequestComicSeries)
			let encoder = JSONEncoder()
			let data = try encoder.encode(comicsSeries)
			let url = getBackupDirectory().appendingPathComponent(comicSeriesBackupFilename)
			try data.write(to: url)
		} catch {
			print("Failed to back up comic series data: \(error)")
			return false
		}
		return true
	}
	
	// load the comic series file
	func loadComicSeries() -> Bool? {
		do {
			// load the most recent backup file and get all of the elements from that file
			let url = getBackupDirectory().appendingPathComponent(comicSeriesBackupFilename)
			guard let data = try? Data(contentsOf: url) else {
				print("No backup file to load, starting with empty comic series")
				return nil // not failed but the file doesnt exist
			}
			let decoder = JSONDecoder()
			let comicSeries = try decoder.decode([ComicSeries].self, from: data)
			
			for series in comicSeries {
				let newSeries = ComicSeries(
					seriesTitle: series.seriesTitle,
					yearFirstPublished: series.yearFirstPublished,
					issuesRead: series.issuesRead,
					totalIssues: series.totalIssues,
					pagesRead: series.pagesRead
				)
				self.context.insert(newSeries)
			}
			
			self.saveContext()
			print("Successfully loaded " + String(comicSeries.count) + " series")
		} catch {
			print("Failed to decode comic series data: \(error)")
			return false
		}
		return true
	}
	
	
	// this just saves the comic event file
	func saveComicEvent() -> Bool {
		let fetchRequestComicEvent = FetchDescriptor<ComicEvent>()
		
		do {
			let comicsEvents = try context.fetch(fetchRequestComicEvent)
			let encoder = JSONEncoder()
			let data = try encoder.encode(comicsEvents)
			let url = getBackupDirectory().appendingPathComponent(comicEventBackupFilename)
			try data.write(to: url)
		} catch {
			print("Failed to back up comic event data: \(error)")
			return false
		}
		return true
	}
	
	// load the comic series file
	func loadComicEvent() -> Bool? {
		do {
			// load the most recent backup file and get all of the elements from that file
			let url = getBackupDirectory().appendingPathComponent(comicEventBackupFilename)
			guard let data = try? Data(contentsOf: url) else {
				print("No backup file to load, starting with empty comic event")
				return nil
			}
			let decoder = JSONDecoder()
			let comicEvent = try decoder.decode([ComicEvent].self, from: data)
			
			for event in comicEvent {
				let newEvent = ComicEvent(
					eventName: event.eventName,
					issuesRead: event.issuesRead,
					totalIssues: event.totalIssues,
					pagesRead: event.pagesRead
				)
				self.context.insert(newEvent)
			}
			
			self.saveContext()
			print("Successfully loaded " + String(comicEvent.count) + " events")
		} catch {
			print("Failed to decode comic event data: \(error)")
			return false
		}
		return true
	}
	
	
	/// runs through and saves each file seperatly
	/// returns:
	/// true: if all files were successfully saved
	/// false: if any files failed to save
	func saveAllData() -> Bool {
		
		// save each file
		let saveComicDataSuccess: Bool = saveComicData()
		let saveComicSeriesSuccess: Bool = saveComicSeries()
		let saveComicEventSuccess: Bool = saveComicEvent()
		
		
		// check that they were all successful
		if (saveComicDataSuccess && saveComicSeriesSuccess && saveComicEventSuccess) {
			print("Backup Successful")
			return true
		} else {
			return false
		}
	}
	
	
	/// runs through and loads each file seperatly
	/// returns:
	/// false: if any files failed to load
	/// nil: if no files failed to load but some couldnt be found or were new
	/// true: if all files were successfully loaded
	func loadAllData() -> Bool? {
		
		// load each file
		let loadComicDataSuccess: Bool? = loadComicData()
		let loadComicSeriesSuccess: Bool? = loadComicSeries()
		let loadComicEventSuccess: Bool? = loadComicEvent()
		
		// check for any false values first
		if loadComicDataSuccess == false || loadComicSeriesSuccess == false || loadComicEventSuccess == false {
			return false
		}
		// then check for any nil values next
		else if loadComicDataSuccess == nil || loadComicSeriesSuccess == nil || loadComicEventSuccess == nil {
			return nil
		}
		// If none are false or nil, all must be true
		return true
	}
}

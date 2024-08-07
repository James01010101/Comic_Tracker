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
		let fetchRequestComicData = FetchDescriptor<ComicData>()
		let fetchRequestComicSeries = FetchDescriptor<ComicSeries>()
		let fetchRequestComicEvent = FetchDescriptor<ComicEvent>()
		
		// backup ComicData
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
		
		// backup ComicSeries
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
		
		// backup ComicEvent
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
		
		print("Backup Successful")
		return true
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
		
		// load comic data
		do {
			// load the most recent backup file and get all of the elements from that file
			let url = getBackupDirectory().appendingPathComponent(comicDataBackupFilename)
			guard let data = try? Data(contentsOf: url) else {
				print("No backup file to load, starting with empty comic data")
				return
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
		}
		
		// load comic series
		do {
			// load the most recent backup file and get all of the elements from that file
			let url = getBackupDirectory().appendingPathComponent(comicSeriesBackupFilename)
			guard let data = try? Data(contentsOf: url) else {
				print("No backup file to load, starting with empty comic series")
				return
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
		}
		
		// load comic events
		do {
			// load the most recent backup file and get all of the elements from that file
			let url = getBackupDirectory().appendingPathComponent(comicEventBackupFilename)
			guard let data = try? Data(contentsOf: url) else {
				print("No backup file to load, starting with empty comic event")
				return
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
			print("Successfully loaded " + String(comicEvent.count) + " event")
		} catch {
			print("Failed to decode comic event data: \(error)")
		}
	}
}

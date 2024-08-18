//
//  PersistenceController.swift
//  Comic Tracker
//
//  Created by James Coldwell on 4/8/2024.
//

import SwiftUI
import SwiftData
import CloudKit

/// This class will be used for storing/loading/backing up all persistant data
///
/// This data is saved to the file system (not currently icloud). This makes sure that I have saved back-up data so if I change the underlying data structures it wont be currupted when loading in the old data.
///
/// All data structures that are saved are saved into the `JSON` file format, which requires each class to be `Codable`
///
/// Currently there are backup files for: ``ComicData``, ``ComicSeries``, ``ComicEvent``
///
/// > Important: If I change the underlying data structures which are loaded by this class, some conversion function will need to be created to convert the old data from the file into the new format. Most likely using `nil` values for new fields that didn't exist before.
///
/// > Note: If the free 3 month trial of the app runs out, having your data saved to a backup file means you won't lose any data when you go to load the app again the next time.
class PersistenceController: ObservableObject {
	/// This is the static instance of this class, there should only ever be once instance of this class that should be used across the project
	static let shared = PersistenceController()
	
	/// Is the container that defines how the data is stored in the ``context``
	let container: ModelContainer
	/// Contains all os the main data the project uses, data is loaded from files into this, and backed up from this into files
	@Published var context: ModelContext
	
	/// Controls all global variables
	var globalState = GlobalState.shared
	
	/// The filename for the ``ComicData`` backup file
	let comicDataBackupFilename: String = "backup_comic_data.json"
	/// The filename for the ``ComicSeries`` backup file
	let comicSeriesBackupFilename: String = "backup_comic_series.json"
	/// The filename for the ``ComicEvent`` backup file
	let comicEventBackupFilename: String = "backup_comic_event.json"
	
	
	/// Initialises all data the app needs
	///
	/// It will read in all files into there corresponding data structures in the ``context``
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
			// This shouldnt run since itll never load data from the disc since im only storing it in memory
			// It'll load the data from my backup file everytime
			fatalError("Could not create ModelContainer: \(error)")
		}
		
		// Lastly load my saved backup data from disc
		if (!globalState.runningInPreview) {
			let loadResult = loadAllData()
			if (loadResult == false) {
				fatalError("Could not load all data files")
			}
			// Else if nil or true continue on nil will already print messages to debug
		}
	}
	
	/// This is used to save the context data although ModelContext only exists in memory so this isnt used,
	///
	/// This should only be used internally in the ``PersistenceController`` to save the context if needed. I'll be writing to my own backup file myself
	///
	/// > Important: This is not the backup function, and does not write files to disc since data is stored in memory only, it just saves what is in the model context
	///
	/// > Note: To save files to disc call the ``saveAllData()`` function, which will save all data to their files on disc
	func saveContext() {
		do {
			try context.save()
		} catch {
			let nserror = error as NSError
			print("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}
	
	/// Get the directory to save the backup files to
	///
	/// - Returns: ``URL`` - Which contains a directory object to the backup files directory
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
		
		//print("Backup directory: " + backupDirectory.absoluteString)
		
		return backupDirectory
	}
	
	/// Saves the ``ComicData`` from the ``context`` to its own backup file at ``comicDataBackupFilename`` in `JSON` format
	///
	/// - Returns: ``Bool`` - Letting the user know if the save was successful or not
	func saveComicData() -> Bool {
		// dont actually save if running in preview
		if (globalState.runningInPreview) { return true }
		
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
	
	
	/// Loads the ``ComicData`` `JSON` file into the ``context`` from its backup file at ``comicDataBackupFilename``
	///
	///	- Return values:
	///	  - `true`: Successfully loaded.
	///   - `false`: Failed to load.
	///   - `nil`: The file doesn't exist.
	///
	///   Return value of `nil` isn't bad it might just mean that this is a new data structure which is empty so the file doesn't exist yet.
	///
	/// - Returns: `Bool?` - Showing the status of the load, whether it loaded the file correctly or not
	func loadComicData() -> Bool? {
		// dont actually load if running in preview
		if (globalState.runningInPreview) { return true }
		
		do {
			// Load the most recent backup file and get all of the elements from that file
			let url = getBackupDirectory().appendingPathComponent(comicDataBackupFilename)
			guard let data = try? Data(contentsOf: url) else {
				print("No backup file to load, starting with empty comic data")
				return nil
			}
			let decoder = JSONDecoder()
			let comics = try decoder.decode([ComicData].self, from: data)
			
			for comic in comics {
				let newComic = ComicData(
					brandName: comic.brandName,
					shortBrandName: comic.shortBrandName,
					prioritizeShortBrandName: comic.prioritizeShortBrandName,
					
					seriesName: comic.seriesName,
					shortSeriesName: comic.shortSeriesName,
					prioritizeShortSeriesName: comic.prioritizeShortSeriesName,
					
					comicName: comic.comicName,
					shortComicName: comic.shortComicName,
					prioritizeShortComicName: comic.prioritizeShortComicName,
					
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
	
	
	/// Saves the ``ComicSeries`` from the ``context`` to its own backup file at ``comicDataBackupFilename`` in `JSON` format
	///
	/// - Returns: ``Bool`` - Letting the user know if the save was successful or not
	func saveComicSeries() -> Bool {
		// dont actually save if running in preview
		if (globalState.runningInPreview) { return true }
		
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
	
	
	/// Loads the ``ComicSeries`` `JSON` file into the ``context`` from its backup file at ``comicDataBackupFilename``
	///
	///	- Return values:
	///	  - `true`: Successfully loaded.
	///   - `false`: Failed to load.
	///   - `nil`: The file doesn't exist.
	///
	/// > Note: Return value of `nil` isn't bad it might just mean that this is a new data structure which is empty so the file doesn't exist yet.
	///
	/// - Returns: `Bool?` - Showing the status of the load, whether it loaded the file correctly or not
	func loadComicSeries() -> Bool? {
		// dont actually load if running in preview
		if (globalState.runningInPreview) { return true }
		
		do {
			// Load the most recent backup file and get all of the elements from that file
			let url = getBackupDirectory().appendingPathComponent(comicSeriesBackupFilename)
			guard let data = try? Data(contentsOf: url) else {
				print("No backup file to load, starting with empty comic series")
				return nil // Not failed but the file doesnt exist
			}
			let decoder = JSONDecoder()
			let comicSeries = try decoder.decode([ComicSeries].self, from: data)
			
			for series in comicSeries {
				let newSeries = ComicSeries(
					brandName: series.brandName,
					shortBrandName: series.shortBrandName,
					prioritizeShortBrandName: series.prioritizeShortBrandName,
					
					seriesName: series.seriesName,
					shortSeriesName: series.shortSeriesName,
					prioritizeShortSeriesName: series.prioritizeShortSeriesName,
					
					yearFirstPublished: series.yearFirstPublished,
					issuesRead: series.issuesRead,
					totalIssues: series.totalIssues,
					pagesRead: series.pagesRead,
					recentComicIssueNumber: series.recentComicIssueNumber,
					recentComicTotalPages: series.recentComicTotalPages,
					recentComicEventName: series.recentComicEventName,
					recentComicPurpose: series.recentComicPurpose
				)
				self.context.insert(newSeries)
				
				// check if it exists in the dict, if so add one, else add it
				if let count = globalState.seriesNamesUsages[newSeries.seriesName] {
					// if it exists
					globalState.seriesNamesUsages[newSeries.seriesName] = count + 1
				} else {
					globalState.seriesNamesUsages[newSeries.seriesName] = 1
				}
				
			}
			
			self.saveContext()
			print("Successfully loaded " + String(comicSeries.count) + " series")
		} catch {
			print("Failed to decode comic series data: \(error)")
			return false
		}
		return true
	}
	
	
	/// Saves the ``ComicEvent`` from the ``context`` to its own backup file at ``comicDataBackupFilename`` in `JSON` format
	///
	/// - Returns: ``Bool`` - Letting the user know if the save was successful or not
	func saveComicEvent() -> Bool {
		// dont actually save if running in preview
		if (globalState.runningInPreview) { return true }
		
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
	
	
	/// Loads the ``ComicEvent`` `JSON` file into the ``context`` from its backup file at ``comicDataBackupFilename``
	///
	///	- Return values:
	///	  - `true`: Successfully loaded.
	///   - `false`: Failed to load.
	///   - `nil`: The file doesn't exist.
	///
	/// > Note: Return value of `nil` isn't bad it might just mean that this is a new data structure which is empty so the file doesn't exist yet.
	///
	/// - Returns: `Bool?` - Showing the status of the load, whether it loaded the file correctly or not
	func loadComicEvent() -> Bool? {
		// dont actually load if running in preview
		if (globalState.runningInPreview) { return true }
		
		do {
			// Load the most recent backup file and get all of the elements from that file
			let url = getBackupDirectory().appendingPathComponent(comicEventBackupFilename)
			guard let data = try? Data(contentsOf: url) else {
				print("No backup file to load, starting with empty comic event")
				return nil
			}
			let decoder = JSONDecoder()
			let comicEvent = try decoder.decode([ComicEvent].self, from: data)
			
			for event in comicEvent {
				let newEvent = ComicEvent(
					eventBrand: event.eventBrand,
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
	
	
	/// Saves each type of data in the ``context`` to its own file
	///
	///  - Returns:`Bool` - `true`: If all files were successfully saved or else `false`: if any files failed to save
	func saveAllData() -> Bool {
		// Save each file
		let saveComicDataSuccess: Bool = saveComicData()
		let saveComicSeriesSuccess: Bool = saveComicSeries()
		let saveComicEventSuccess: Bool = saveComicEvent()
		
		
		// Check that all saves were successful
		if (saveComicDataSuccess && saveComicSeriesSuccess && saveComicEventSuccess) {
			print("Backup Successful")
			return true
		} else {
			return false
		}
	}
	
	
	/// Loads each file individually into the ``context``
	///
	/// - Return Values:
	///   - `true`: All files were successfully loaded
	///   - `false`: Any file failed to be loaded
	///   - `nil`: If no files failed to load but some couldn't be found or were new
	///
	/// > Note: Return value of `nil` isn't bad it might just mean that this is a new data structure which is empty so the file doesn't exist yet.
	///
	/// - Returns: `Bool?` - Which is lets the user know the status after loading all files
	func loadAllData() -> Bool? {
		
		// Load each file
		let loadComicDataSuccess: Bool? = loadComicData()
		let loadComicSeriesSuccess: Bool? = loadComicSeries()
		let loadComicEventSuccess: Bool? = loadComicEvent()
		
		// Check for any false values first
		if loadComicDataSuccess == false || loadComicSeriesSuccess == false || loadComicEventSuccess == false {
			return false
		}
		// Then check for any nil values next
		else if loadComicDataSuccess == nil || loadComicSeriesSuccess == nil || loadComicEventSuccess == nil {
			return nil
		}
		// If none are false or nil, all must be true
		return true
	}
}

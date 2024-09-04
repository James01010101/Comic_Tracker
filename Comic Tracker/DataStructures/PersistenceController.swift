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
	
	/// The Root folder which will contain all day folders with all of my data
	let rootFolder: URL;
	/// The folder ill read my data in from, initialised in the init method to find the most recent folder, not necessarily today
	let loadFilesFolder: URL?;
	/// The folder ill save files to, will be todays date, and will be created if it doesnt exist
	let saveFilesFolder: URL;
	
	
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
		
		
		
		// get the root folder path
		self.rootFolder = getRootDirectory();
		
		// get the folder to load the files from, if nil then everything is just default this is fine
		self.loadFilesFolder = getMostRecentBackupFolder(rootFolder: self.rootFolder);
		
		// get the folder to save the files to, this will be todays date, if it does not exist i will create it, otherwise ill overwrite whatever files are in it on a save
		self.saveFilesFolder = getOrCreateSaveFilesFolder(rootFolder: self.rootFolder);
		
		
		
		// Lastly load my saved backup data from disc
		if (!globalState.runningInPreview) {
			let loadResult = loadAllData()
			if (loadResult == false) {
				fatalError("Could not load all data files")
			}
			// Else if nil or true continue on nil will already print messages to debug
		}
		
		// If the save folder is new ill need to write my files to it initially so the folder isnt empty, 
		// since the next time i go to read from it it will read from the new file (which might be empty if i didnt make any changes)
		// check this my comparing the save and load folders. if they are different the save was just created
		if (self.saveFilesFolder.lastPathComponent != self.loadFilesFolder?.lastPathComponent) {
			let s = self.saveAllData();
			print("Saving data to new folder: " + (s ? "successful" : "failed"));
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
			let url = self.saveFilesFolder.appendingPathComponent(comicDataBackupFilename)
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
			// Load the most recent backup file and get all of the elements from that file, if it fails to load then
			let url: URL;
			if let temp = self.loadFilesFolder {
				url = temp.appendingPathComponent(comicDataBackupFilename);
			} else {
				// the folder doesnt exist so return
				return nil;
			}
	
			
			guard let data = try? Data(contentsOf: url) else {
				print("No backup file to load, starting with empty comic data")
				return nil
			}
			let decoder = JSONDecoder()
			let comics = try decoder.decode([ComicData].self, from: data)
			
			for comic in comics {
				self.context.insert(comic)
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
			let url = self.saveFilesFolder.appendingPathComponent(comicSeriesBackupFilename)
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
			let url: URL;
			if let temp = self.loadFilesFolder {
				url = temp.appendingPathComponent(comicSeriesBackupFilename);
			} else {
				// the folder doesnt exist so return
				return nil;
			}

			guard let data = try? Data(contentsOf: url) else {
				print("No backup file to load, starting with empty comic series")
				return nil // Not failed but the file doesnt exist
			}
			let decoder = JSONDecoder()
			let comicSeries = try decoder.decode([ComicSeries].self, from: data)
			
			for series in comicSeries {
				self.context.insert(series)
				
				// check if it exists in the dict, if so add one, else add it
				if let count = globalState.seriesNamesUsages[series.seriesName] {
					// if it exists
					globalState.seriesNamesUsages[series.seriesName] = count + 1
				} else {
					globalState.seriesNamesUsages[series.seriesName] = 1
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
			let url = self.saveFilesFolder.appendingPathComponent(comicEventBackupFilename)
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
			let url: URL;
			if let temp = self.loadFilesFolder {
				url = temp.appendingPathComponent(comicEventBackupFilename);
			} else {
				// the folder doesnt exist so return
				return nil;
			}

			guard let data = try? Data(contentsOf: url) else {
				print("No backup file to load, starting with empty comic event")
				return nil
			}
			let decoder = JSONDecoder()
			let comicEvent = try decoder.decode([ComicEvent].self, from: data)
			
			for event in comicEvent {
				self.context.insert(event)
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







// All of these functions need to be outside the class so that they can be used during the initise phase
/// Get the root directory of all of the backup folders
///
/// From here I can then find the most recent folder to load from
/// - Returns: URL which is the path to the root directory
private func getRootDirectory() -> URL {
	let fileManager = FileManager.default
	guard var root = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
		fatalError("Could not find root directory, a restart might fix this problem");
	}
	
	root = root.appendingPathComponent("Comic Tracker");
	print("Root dir: " + root.absoluteString);
	
	return root;
}

/// Function to convert a date string in `day-month-year` format to a `Date` object
private func dateFromString(_ dateString: String) -> Date? {
	// quick check to make sure the string is in the right format
	if dateString.split(separator: "-").count != 3 { return nil; }
	
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "d-M-yyyy"
	return dateFormatter.date(from: dateString)
}

/// Get the most recent backup folder based on the folder names (which are dates)
private func getMostRecentBackupFolder(rootFolder: URL) -> URL? {
	let fileManager = FileManager.default
	
	do {
		let subfolders = try fileManager.contentsOfDirectory(at: rootFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]);
		
		// Filter to only include directories
		let directories = subfolders.filter { url in
			// check that it is a directory
			var isDirectory: ObjCBool = false;
			fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory);
			
			// also check that the file name is in the right format {}-{}-{}, if not return false
			if let _ = dateFromString(url.lastPathComponent) {
				return isDirectory.boolValue;
			}
			return false;
		}
		
		// Sort directories by the date in their name
		let sortedDirectories = directories.sorted { (url1, url2) -> Bool in
			if let date1 = dateFromString(url1.lastPathComponent), let date2 = dateFromString(url2.lastPathComponent) {
				return date1 > date2;
			}
			return false;
		}
		
		// Keep only the 5 most recent folders
		if sortedDirectories.count > 5 {
			let directoriesToDelete = sortedDirectories[5...];
			for folder in directoriesToDelete {
				do {
					try fileManager.removeItem(at: folder);
					print("Deleted old backup folder: \(folder.path)");
				} catch {
					print("Failed to delete folder: \(folder.path), error: \(error)");
				}
			}
		}
		
		// print for debug
		if let v = sortedDirectories.first {
			print("Most recent backup folder to load: " + v.absoluteString);
		} else {
			print("Most recent backup folder to load: nil");

		}
		
		// Return the most recent folder (possiblly nil if non exist)
		return sortedDirectories.first
	} catch {
		// if it fails it need to error here and not continue
		fatalError("Error reading backup directories: \(error)")
	}
}

/// from the root folder get the path to the folder where i will save my files to, this will be todays date. if this folder doesn't exist create it
private func getOrCreateSaveFilesFolder(rootFolder: URL) -> URL {
	// Get today's date as a string in the format "day-month-year"
	let dateFormatter = DateFormatter();
	dateFormatter.dateFormat = "d-M-yyyy";
	let todaysDate = dateFormatter.string(from: Date());
	
	// get the path filename to where i want to save my files too
	let saveFolder = rootFolder.appendingPathComponent(todaysDate);
	
	// Check if the folder exists, if not, create it
	let fileManager = FileManager.default;
	if !fileManager.fileExists(atPath: saveFolder.path) {
		do {
			try fileManager.createDirectory(at: saveFolder, withIntermediateDirectories: true, attributes: nil);
			print("Created new save folder: \(saveFolder.path)");
		} catch {
			fatalError("Could not create save folder: \(error)");
		}
	}
	
	print("Save folder: " + saveFolder.absoluteString)
	return saveFolder;
}

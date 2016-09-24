
import Foundation
import CoreData

class EEBPersistentStoreManager : NSObject {
    let dataModelName = "AppData";
    
    var managedObjectContext: NSManagedObjectContext? = nil;
    var persistentStorePresent = false
    var sortDescriptors : Array<NSSortDescriptor> = []
    
    override init(){
        super.init()
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        sortDescriptors.append(sortDescriptor)
        
        if(self.configureBackingStore() == false){
            print("Could not configure CoreData store for AppData!");
        }
    }
    
    /**
     * @name:   configureBackingStore
     * @brief:  Initializes core data (and the persistent backing store)
     */
    func configureBackingStore() ->(Bool) {
        //Get CD model and open it
        guard let url = Bundle.main.url(forResource: dataModelName, withExtension: "momd") else {
            print("Could not load model from bundle");
            return false;
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: url) else {
            print("Error intializing managed object model from \(url)");
            return false;
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext?.persistentStoreCoordinator = psc
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        
        //find the persistent store
        let storeURL = docURL.appendingPathComponent(self.dataModelName + ".sqlite")
        
        
        
        //Check if we need to migrate the model
        let migrationOptions = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
        var canMigrate = false
        do {
            let sourceMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: migrationOptions)
            let destinationModel = psc.managedObjectModel

            canMigrate = destinationModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sourceMetadata)
        } catch {
            canMigrate = false
        }
        
        if !canMigrate {
            print("Unable to migrate persistent store. Attempting to move old database...")
            let backupURL = docURL.appendingPathComponent(self.dataModelName + ".sqlite.backup")
            
            do {
                try FileManager.default.moveItem(at: storeURL, to: backupURL)
                print("Moved old database to: \(backupURL.absoluteString)")
            } catch {
                print("An error occurred while moving the old database! Restored original state. Please contact support")
            }
            
        }
        
        do {
            //we've found an existing store. Try and migrate (if required)
            if(canMigrate){
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: migrationOptions)
            } else {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            }
            self.persistentStorePresent = true;
        } catch {
            print("Could not + \(canMigrate ? "migrate" : "create") datastore \(error)");
        }
        return true;
    }
    
    /**
     * @name    save
     * @brief   Saves the MOC to backing store (commits to disk)
     */
    func save(){
        guard persistentStorePresent != false else { return }
        do {
            try self.managedObjectContext?.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    /**
    * @name     createObjectOfType
    * @brief    Creates a new object in the managed object context
    **/
    func createObjectOfType(_ type : String) -> AnyObject {
        let createdObject = NSEntityDescription.insertNewObject(forEntityName: type, into: self.managedObjectContext!)
        return createdObject;
    }
    
    /**
     * @name    removeObject
     * @brief   Removes an object from the managed object context
     **/
    func removeObject(_ managedObject : NSManagedObject){
        self.managedObjectContext!.delete(managedObject)
    }
    
    /**
     * @name    allObjectsOfType
     * @brief   Returns all the objects of the given type that are in the managed object context
     */
    func allObjectsOfType(_ type : String) -> [Any]? {
        guard persistentStorePresent != false else { return nil }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: type)
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let fetchedObjects = try self.managedObjectContext?.fetch(fetchRequest)
            return fetchedObjects
        } catch {
            print("Unable to fetch all objects of type: \(type) ");
        }
        return nil;
    }    
    
}

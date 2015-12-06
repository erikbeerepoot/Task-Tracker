//
//  PassController.swift
//  North Cowichan
//
//  Created by Erik Beerepoot on 2015-10-19.
//  Copyright © 2015 Dactyl Studios. All rights reserved.
//

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
            print("Could not CoreData store for AppData!");
        }
    }
    
    /**
     * @name:   configureBackingStore
     * @brief:  Initializes core data (and the persistent backing store)
     */
    func configureBackingStore() ->(Bool) {
        //Get CD model and open it
        guard let url = NSBundle.mainBundle().URLForResource(dataModelName, withExtension: "momd") else {
            print("Could not load model from bundle");
            return false;
        }
        
        guard let mom = NSManagedObjectModel(contentsOfURL: url) else {
            print("Error intializing managed object model from \(url)");
            return false;
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.managedObjectContext?.persistentStoreCoordinator = psc
        
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let docURL = urls[urls.endIndex-1]
        
        //find the persistent store
        let storeURL = docURL.URLByAppendingPathComponent(self.dataModelName + ".sqlite")
        do {
            //we've found an existing store. Try and migrate (if required)
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            self.persistentStorePresent = true;
        } catch {
            print("Error migrating store: \(error)");
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
    func createObjectOfType(type : String) -> AnyObject {
        let createdObject = NSEntityDescription.insertNewObjectForEntityForName(type, inManagedObjectContext: self.managedObjectContext!)
        return createdObject;
    }
    
    /**
     * @name    removeObject
     * @brief   Removes an object from the managed object context
     **/
    func removeObject(managedObject : NSManagedObject){
        self.managedObjectContext!.deleteObject(managedObject)
    }
    
    /**
     * @name    allObjectsOfType
     * @brief   Returns all the objects of the given type that are in the managed object context
     */
    func allObjectsOfType(type : String) -> Array<AnyObject>? {
        guard persistentStorePresent != false else { return nil }
        
        let fetchRequest = NSFetchRequest(entityName: type);
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let fetchedObjects = try self.managedObjectContext?.executeFetchRequest(fetchRequest)
            return fetchedObjects
        } catch {
            print("Unable to fetch all objects of type: \(type) ");
        }
        return nil;
    }    
    
}
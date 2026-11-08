//
//  MocksDataProtocol.swift
//  SITIENSTests
//
//  Created by Modibo on 15/05/2025.
//

import Testing
@testable import SITIENS
import CoreData

@objc(History)
public class MockHistory: NSObject {
    @NSManaged public var name : String
    @NSManaged public var quantity : String
    @NSManaged public var date : String
}

enum HistoryError: Error {
    case emptyData, customError(String)
}

class MocksDataProtocol : HistoryProtocol {
    
   
    var historyManager : [History] = []
    var throwError : Bool = false
    var messageError : String = ""
    var name : String = ""
    var quantity : String = ""
    var date : String = ""

    func deleteHistory(history: SITIENS.History) {
        if throwError {
            messageError = "There are some errors"
        }else {
            messageError = ""
            historyManager.removeAll()
        }
    }
    
    func createInMemoryManagedObjectContext () -> NSManagedObjectContext {
        let persistentContainer = NSPersistentContainer(name: "SitiensModel")
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType //description.type = NSInMemoryStoreType // Detruit la sauegarde en memeoire
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                       fatalError("Erreur lors de la création du store in-memory : \(error)")
                   }
        }
        return persistentContainer.viewContext
    }
    
    
    func createHistors(context:NSManagedObjectContext, name:String,quantity:String) -> SITIENS.History {
        let historyManager = SITIENS.History(context: context)
        historyManager.name = name
        historyManager.quantity = quantity
        
        return historyManager
    }
    
    func getHisoData() throws -> [SITIENS.History] {
        guard  name.isEmpty || quantity.isEmpty else {
             messageError = "There are not data"
            throw  HistoryError.emptyData
        }
        
        guard !throwError else {
             messageError = "There are some errors"
            throw HistoryError.customError("There are some errors")
        }
        
        let data = createHistors(context: createInMemoryManagedObjectContext(), name: name, quantity: quantity)
        
        return [data]
    }

    var liters: Double = 0

    func addtHisoData(name: String, quantity: String, liters: Double) throws {
        self.name = name
        self.quantity = quantity
        self.liters = liters
        
        guard  !name.isEmpty || !quantity.isEmpty  else {
            messageError = "There is no data"
            throw HistoryViewModel.FetchError.fetchFailed
            
        }
        if throwError {
            messageError = "There are some errors"
        }else{
            messageError = ""
        }
    }

}

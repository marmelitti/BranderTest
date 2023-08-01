import Foundation
import CoreData

class DatabaseManager {
    static let shared = DatabaseManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveUser(user: AppUser) {
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "CDUser", into: context) as! CDUser
                
        newUser.nameTitle = user.name.title
        newUser.nameFirst = user.name.first
        newUser.nameLast = user.name.last
        newUser.email = user.email
        newUser.dob = user.dob.date
        newUser.pictureLarge = user.picture.large
        newUser.pictureMedium = user.picture.medium
        newUser.pictureThumbnail = user.picture.thumbnail

        saveContext()
    }
    
    func fetchAllUsers() -> [AppUser] {
        let request: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        let predicate = NSPredicate(format: "isRemoved == nil")
            request.predicate = predicate
        do {
            let usersMO = try context.fetch(request)
            return usersMO.map { userMO in
                let name = Name(title: userMO.nameTitle!, first: userMO.nameFirst!, last: userMO.nameLast!)
                let dob = Dob(date: userMO.dob!)
                let picture = UserPicture(large: userMO.pictureLarge!, medium: userMO.pictureMedium!, thumbnail: userMO.pictureThumbnail!)
                
                return AppUser(name: name, email: userMO.email!, dob: dob, picture: picture)
            }
        } catch {
            print("Error fetching users: \(error)")
            return []
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}

import XCTest
import SwiftUI
import CoreData
@testable import DemoXCTest

class MockManagedObjectContext: NSManagedObjectContext {
    var mockItems: [Item] = []

    func fetchMockItems<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T]? {
        guard let request = request as? NSFetchRequest<Item> else {
            return nil
        }
        return mockItems as? [T]
    }
}

class MockItem: Item {
    var mockTimestamp: Date?
    override var timestamp: Date? {
        get { return mockTimestamp }
        set { mockTimestamp = newValue }
    }
}

class MockCoreDataStack {
    var persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "DemoXCTest")
        persistentContainer.persistentStoreDescriptions = [NSPersistentStoreDescription()]
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}

class ContentViewTests: XCTestCase {
    var viewContext: NSManagedObjectContext!
    var sut: AnyView!

    override func setUpWithError() throws {
        let coreDataStack = MockCoreDataStack()
        viewContext = coreDataStack.viewContext
        
        let mockItem1 = Item(context: viewContext)
        mockItem1.timestamp = Date()
        mockItem1.name = "Item 1"

        let mockItem2 = Item(context: viewContext)
        mockItem2.timestamp = Date().addingTimeInterval(60)
        mockItem2.name = "Item 2"
        
        sut = AnyView(ContentView().environment(\.managedObjectContext, viewContext))
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }

    func testAddItem() throws {
        if let contentView = sut as? ContentView {
            contentView.addItem(viewContext: viewContext)
        }

        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            let items = try viewContext.fetch(fetchRequest)
            XCTAssertEqual(items.count, 2, "Item count should be 2 after adding an item")
        } catch {
            XCTFail("Failed to fetch items: \(error)")
        }
    }

    func testDeleteItem() throws {
        if let contentView = sut as? ContentView {
            contentView.addItem(viewContext: viewContext)
        }

        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        var items: [Item] = []
        do {
            items = try viewContext.fetch(fetchRequest)
        } catch {
            XCTFail("Failed to fetch items: \(error)")
        }

        if let contentView = sut as? ContentView {
            contentView.deleteItems(offsets: IndexSet(integer: 0))
        }

        do {
            items = try viewContext.fetch(fetchRequest)
            XCTAssertEqual(items.count, 0, "Item count should be 0 after deleting the item")
        } catch {
            XCTFail("Failed to fetch items: \(error)")
        }
    }
    
    func testSkipped() throws {
        throw XCTSkip("This test is skipped intentionally")
    }
}

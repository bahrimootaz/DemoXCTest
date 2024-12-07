import XCTest
import CoreData
@testable import DemoXCTest

final class ContentViewTests: XCTestCase {

    var persistenceController: PersistenceController!
    var viewContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Initialize an in-memory persistence controller for testing
        persistenceController = PersistenceController(inMemory: true)
        viewContext = persistenceController.container.viewContext
    }

    override func tearDownWithError() throws {
        viewContext = nil
        persistenceController = nil
        try super.tearDownWithError()
    }

    func testAddItem() throws {
        // Arrange
        let contentView = ContentView().environment(\.managedObjectContext, viewContext)
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()

        // Act
        contentView.addItem()
        let items = try viewContext.fetch(fetchRequest)

        // Assert
        XCTAssertEqual(items.count, 1, "There should be one item added")
        XCTAssertNotNil(items.first?.timestamp, "The item's timestamp should not be nil")
    }

    func testDeleteItem() throws {
        // Arrange
        let contentView = ContentView().environment(\.managedObjectContext, viewContext)
        let newItem = Item(context: viewContext)
        newItem.timestamp = Date()
        try viewContext.save()

        // Act
        contentView.deleteItems(offsets: IndexSet(integer: 0))
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let items = try viewContext.fetch(fetchRequest)

        // Assert
        XCTAssertEqual(items.count, 0, "The item should be deleted")
    }

    func testSkipped() throws {
        // Example of a skipped test
        throw XCTSkip("This test is skipped intentionally")
    }
}

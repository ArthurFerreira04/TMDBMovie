import XCTest
@testable import TMDB_Movie

final class FavoritesStoreTests: XCTestCase {

    private var defaults: UserDefaults!
    private var store: FavoritesStore!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "FavoritesStoreTests")!
        defaults.removePersistentDomain(forName: "FavoritesStoreTests")
        store = FavoritesStore(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "FavoritesStoreTests")
        defaults = nil
        store = nil
        super.tearDown()
    }

    func testAddAndContainsMovie() {
        let movie = FavoriteMovie(id: 1, title: "Avatar", posterURLString: nil, mediaKind: .movie)
        store.add(movie)

        XCTAssertTrue(store.contains(id: 1, mediaKind: .movie))
        XCTAssertEqual(store.all().count, 1)
        XCTAssertEqual(store.all().first?.title, "Avatar")
    }

    func testDoesNotDuplicateSameMovieAndKind() {
        store.add(.init(id: 1, title: "A", posterURLString: nil, mediaKind: .movie))
        store.add(.init(id: 1, title: "A", posterURLString: nil, mediaKind: .movie))

        XCTAssertEqual(store.all().count, 1)
    }

    func testSameIdDifferentMediaKindAreDistinct() {
        store.add(.init(id: 10, title: "Shared", posterURLString: nil, mediaKind: .movie))
        store.add(.init(id: 10, title: "Shared", posterURLString: nil, mediaKind: .tv))

        XCTAssertEqual(store.all().count, 2)
        XCTAssertTrue(store.contains(id: 10, mediaKind: .movie))
        XCTAssertTrue(store.contains(id: 10, mediaKind: .tv))
    }

    func testRemoveAndRemoveAll() {
        store.add(.init(id: 1, title: "A", posterURLString: nil))
        store.add(.init(id: 2, title: "B", posterURLString: nil))

        store.remove(id: 1, mediaKind: .movie)
        XCTAssertFalse(store.contains(id: 1, mediaKind: .movie))
        XCTAssertEqual(store.all().count, 1)

        store.removeAll()
        XCTAssertTrue(store.all().isEmpty)
    }

    func testLegacyDecodeDefaultsMediaKindToMovie() throws {
        let legacyJSON = """
        [{"id":99,"title":"Legado","posterURLString":null}]
        """.data(using: .utf8)!
        defaults.set(legacyJSON, forKey: "favorites.movies.v1")

        let reloaded = FavoritesStore(defaults: defaults)
        XCTAssertEqual(reloaded.all().first?.mediaKind, .movie)
    }
}

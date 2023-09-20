//
//  RemoteFeedLoaderTests.swift
//  QuimaLabsFeedTests
//
//  Created by Raul on 18/07/23.
//

import XCTest
import QuimaLabsFeed

final class RemoteFeedLoaderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitDoesNotRequestURL() throws {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func testLoadRequestDataFromURL() {
        let url: URL = URL(string: "https//:www.give.request.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func testLoadDeliverErrorOnError() {
        let (sut, client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0)
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https//:www.give.request.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(url: url, client: client), client)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] = [URL]()
        var error: Error?
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            requestedURLs.append(url)
        }
    }
}

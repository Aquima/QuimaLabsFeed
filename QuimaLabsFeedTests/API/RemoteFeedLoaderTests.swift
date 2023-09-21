//
//  RemoteFeedLoaderTests.swift
//  QuimaLabsFeedTests
//
//  Created by Raul Quispe on 18/07/23.
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
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }

    func testLoadTwiceRequestDataFromURLTwice() {
        let url: URL = URL(string: "https//:www.give.request.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func testLoadDeliverErrorOnError() {
        let (sut, client) = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    func testLoadDeliverErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }

        client.complete(withStatusCode: 400)

        XCTAssertEqual(capturedErrors, [.invalidData])
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
        private var messages  = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error) {
            messages[0].completion(error, nil)
        }

        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)
            messages[index].completion(nil, response)
        }
    }
}

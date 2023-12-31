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
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func testLoadDeliverErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }

    func testDeliverErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJson = Data.init("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        })
    }

    func testDeliverNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJson = Data.init("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJson)
        })
    }

    func testLoadDeliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let item1 = FeedItem(id: UUID(),
                             description: nil,
                             location: nil,
                             imageURL: URL(string: "http://imageurel.com")!)

        let item1JSON = [ "id": item1.id.uuidString,
                          "image": item1.imageURL.absoluteString]

        let item2 = FeedItem( id: UUID(),
                              description: "a description",
                              location: "a location",
                              imageURL: URL(string: "http://another-url.com")!)

        let item2JSON = ["id": item2.id.uuidString,
                         "description": item2.description,
                         "location": item2.location,
                         "image": item2.imageURL.absoluteString
        ]

        let itemsJSON = [ "items": [item1JSON, item2JSON] ]

        expect(sut, toCompleteWith: .success([item1, item2]), when: {
            if let json = try? JSONSerialization.data(withJSONObject: itemsJSON) {
                client.complete(withStatusCode: 200, data: json)
            }
        })
    }
    // MARK: - Helpers
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWith result: RemoteFeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        action()
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }

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
        private var messages  = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error) {
            messages[0].completion(.failure(error))
        }

        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}

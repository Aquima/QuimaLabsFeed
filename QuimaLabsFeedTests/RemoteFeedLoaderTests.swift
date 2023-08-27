//
//  RemoteFeedLoaderTests.swift
//  QuimaLabsFeedTests
//
//  Created by Raul on 18/07/23.
//

import XCTest
class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    func load() {
        client.get(from: url)
    }
}
protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    func get(from url: URL) {
        requestURL = url
    }
    var requestURL: URL?
}
final class RemoteFeedLoaderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitDoesNotRequestURL() throws {
        let client = HTTPClientSpy()
        let url = URL(string: "https//:www.give.request.com")!
        let _ = RemoteFeedLoader(url: url, client: client)
        XCTAssertNil(client.requestURL)
    }
    
    func testLoadRequestDataFromURL() {
        let client = HTTPClientSpy()
        let url = URL(string: "https//:www.give.request.com")!
        let sut = RemoteFeedLoader(url: url, client: client)
        sut.load()
        XCTAssertNotNil(client.requestURL)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

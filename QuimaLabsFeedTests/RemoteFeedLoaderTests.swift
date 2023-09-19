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
        XCTAssertNil(client.requestURL)
    }
    
    func testLoadRequestDataFromURL() {
        let url: URL = URL(string: "https//:www.give.request.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url,url])
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
        var requestURL: URL?
        var requestedURLs: [URL] = [URL]()
        func get(from url: URL) {
            requestURL = url
            requestedURLs.append(url)
        }
    }
    
}

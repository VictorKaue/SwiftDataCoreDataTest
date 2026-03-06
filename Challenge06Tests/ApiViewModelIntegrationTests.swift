//
//  ApiViewModelIntegrationTests.swift
//  Challenge06Tests
//
//  Created by Késia Silva Viana on 06/03/26.
//

import XCTest
@testable import Challenge06

@MainActor
final class ApiViewModelIntegrationTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func test_Fetch_ShouldFilterGamesAlreadySaved() async throws {
        
        // GIVEN
        let networkService = NetworkService(session: makeSession())
        
        let swiftDataVM = SwiftDataViewModel(dataSource: .shared)
        let coreData = CoreDataController()
        
        let sut = ApiViewModel(
            swiftDataViewModel: swiftDataVM,
            coreDataController: coreData,
            networkService: networkService
        )
        
        let existingGame = ApiModel(
            id: 3498,
            name: "Grand Theft Auto V",
            background_image: "image"
        )
        
        swiftDataVM.addGame(existingGame)
        
        MockURLProtocol.requestHandler = { request in
            
            let mockData = """
                {
                    "results": [
                        {
                            "id": 3498,
                            "name": "Grand Theft Auto V",
                            "background_image": "image"
                        },
                        {
                            "id": 3328,
                            "name": "The Witcher 3",
                            "background_image": "image"
                        }
                    ]
                }
                """.data(using: .utf8)
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
            
            return (mockData, response, nil)
        }
        
        // WHEN
        sut.fetch()
        
        try await Task.sleep(for: .seconds(2))
        
        // THEN
        XCTAssertEqual(sut.gameList.count, 1)
        XCTAssertEqual(sut.gameList.first?.name, "The Witcher 3")
    }
}
extension ApiViewModelIntegrationTests {
    private class MockURLProtocol: URLProtocol {
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        static var requestHandler: ((URLRequest) throws -> (Data?, HTTPURLResponse?, Error?))?
        
        override func startLoading() {
            guard let handler = Self.requestHandler else {
                XCTFail("No handler set for this request")
                return
            }
            
            do {
                let (data, response, error) = try handler(self.request)
                
                if let error {
                    client?.urlProtocol(self, didFailWithError: error)
                    client?.urlProtocolDidFinishLoading(self)
                    return
                }
                
                guard let response, let data else {
                    XCTFail("Expected both data and response")
                    return
                }
                
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                XCTFail("Should not have thrown an error")
            }
            
        }
        
        override func stopLoading() {
        
        }
    }
    
    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
}


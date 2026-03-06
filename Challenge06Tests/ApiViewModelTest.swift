//
//  ApiViewModelTest.swift
//  Challenge06Tests
//
//  Created by Caio Mandarino on 05/03/26.
//

import XCTest
@testable import Challenge006

@MainActor
final class ApiViewModelTest: XCTestCase {


    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func test_ApiViewModel_Fetch_ShouldSaveInGameList() async throws {
        //Given
        let networkService = NetworkService(session: makeSession())
        let sut = ApiViewModel(swiftDataViewModel: .init(dataSource: .shared), coreDataController: .init(), networkService: networkService)
        
        MockURLProtocol.requestHandler = { request in
            let mockData = """
                {
                    "results": [
                        {
                            "id": 3499,
                            "name": "Grand Theft Auto VI",
                            "background_image": "https://media.rawg.io/media/games/20a/20aa03a10cda45239fe22d035c0ebe64.jpg"
                        }
                    ]
                }
                """.data(using: .utf8)
            
            guard let url = request.url else {
                XCTFail("URL should not be nil")
                return (nil, nil, nil)
            }
            
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
            
            return (mockData, response, nil)
        }
        
        // When
        sut.fetch()

        // Then
        try await Task.sleep(for: .seconds(2))
        
        XCTAssertFalse(sut.gameList.isEmpty)
        XCTAssert(sut.gameList.count == 1)
        
    }
}

extension ApiViewModelTest {
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

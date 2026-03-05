//
//  NetworkService.swift
//  Challenge06
//
//  Created by Caio Mandarino on 05/03/26.
//

import Foundation

final class NetworkService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchData(completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        guard let url = URL(string: "https://api.rawg.io/api/games?key=04e139f54ad64c8da513bbec4c03e8ba") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let response, (response as? HTTPURLResponse)?.statusCode == 200 else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            guard let data else {
                completion(.failure(URLError(.dataNotAllowed)))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let apiResponse = try decoder.decode(ApiResponse.self, from: data)
                completion(.success(apiResponse))
            } catch {
                completion(.failure(error))
            }
                
        }
        
        task.resume()
    }
}

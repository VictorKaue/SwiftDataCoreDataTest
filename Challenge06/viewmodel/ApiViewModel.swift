//
//  HomeViewModel.swift
//  Challenge06
//
//  Created by Joao pedro Leonel on 27/06/25.
//


import Foundation
import SwiftUI

class ApiViewModel: ObservableObject {
    @Published var games : ApiResponse?
    @Published var gameList: [ApiModel] = []
    
    @ObservedObject var swiftDataViewModel: SwiftDataViewModel
    @ObservedObject var coreDataController: CoreDataController
    private let networkService: NetworkService
    
    init(swiftDataViewModel: SwiftDataViewModel, coreDataController: CoreDataController, networkService: NetworkService = NetworkService()) {
        self.swiftDataViewModel = swiftDataViewModel
        self.coreDataController = coreDataController
        self.networkService = networkService
    }
    
    func fetch() {
        networkService.fetchData { result in
            switch result {
            case .success(let parsed):
                
                DispatchQueue.main.async {
                    self.games = parsed
                    self.gameList = parsed.results
                    
                    self.swiftDataViewModel.fetchGames()
                    
                    for gameParsed in parsed.results {
                        for game in self.gameList {
                            if gameParsed.name == game.name {
                                self.gameList.removeAll { $0.name == game.name }
                                self.gameList.insert(game, at: 0)
                            }
                        }
                    }
                    
                    self.gameList = self.gameList.filter { game in
                        !self.swiftDataViewModel.games.contains(where: { $0.name == game.name })
                        && !self.coreDataController.games.contains(where: { $0.name == game.name })
                    }
                }
                
                print("GameList: \(self.swiftDataViewModel.games)")
                print("GameList: \(self.coreDataController.games)")
                
            case .failure(let error):
                print(error)
            }
        }
    }
}


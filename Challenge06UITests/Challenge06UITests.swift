//
//  Challenge06UITests.swift
//  Challenge06UITests
//
//  Created by Cauê Carneiro on 08/03/26.
//

import XCTest

final class Challenge06UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testVerDetalhes() throws {
        // Testando a UI de ver detalhes e navegação para tela de informações SwiftData/CoreData
        let app = XCUIApplication()
        app.launch()

        // Aguarda a tela inicial carregar (API) e verifica que o botão "Ver Detalhes" existe
        let verDetalhesButton = app.buttons["Ver Detalhes"]
        XCTAssertTrue(verDetalhesButton.waitForExistence(timeout: 10), "Botão 'Ver Detalhes' deveria estar visível na tela inicial")

        // Navega para a tela de detalhes
        verDetalhesButton.firstMatch.tap()

        // Verifica que a tela de detalhes foi aberta (texto característico da ExecutionTime)
        let detalhesText = "Resultado baseado em um teste de desempenho"
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", detalhesText)).firstMatch.waitForExistence(timeout: 5),
                      "Tela de detalhes deveria exibir o texto de resultado do teste de desempenho")

        // Scroll para o topo para garantir que SwiftData/CoreData estejam visíveis (ficam acima do ExecutionTime)
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 3), "ScrollView deveria existir")
        scrollView.swipeDown()
        scrollView.swipeDown()

        // Toca no card SwiftData (firstMatch resolve ambiguidade quando há múltiplos elementos com mesmo label)
        let swiftDataCard = app.staticTexts["SwiftData"].firstMatch
        XCTAssertTrue(swiftDataCard.waitForExistence(timeout: 5), "Card SwiftData deveria estar visível")
        swiftDataCard.tap()

        // Verifica que o modal SwiftData foi aberto
        let swiftDataModalText = "Pense no SwiftData como um assistente inteligente"
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", swiftDataModalText)).firstMatch.waitForExistence(timeout: 5),
                      "Modal SwiftData deveria exibir o texto explicativo")

        // NSPredicate evita limite de 128 caracteres do XCUITest
        let swiftDataModalContent = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "carro automático")).firstMatch
        if swiftDataModalContent.waitForExistence(timeout: 2) {
            swiftDataModalContent.swipeRight()
        }

        let element = app.scrollViews.firstMatch
        element.swipeUp()
        element.swipeDown()
        element.swipeDown()
        // Toca no card CoreData (firstMatch resolve ambiguidade quando há múltiplos elementos)
        let coreDataCard = app.staticTexts["CoreData"].firstMatch
        XCTAssertTrue(coreDataCard.waitForExistence(timeout: 5), "Card CoreData deveria estar visível")

        
       // XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", coreDataModalText)).firstMatch.waitForExistence(timeout: 5),
                   //   "Modal CoreData deveria exibir o texto explicativo")

        // NSPredicate evita limite de 128 caracteres do XCUITest
        let coreDataModalContent = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "NSManagedObjectContext")).firstMatch
        if coreDataModalContent.waitForExistence(timeout: 2) {
            coreDataModalContent.swipeUp()
        }
       // app.images["CoreData3"].firstMatch.swipeDown()
        element.swipeDown()
        app.buttons["BackButton"].firstMatch.tap()

        // Verifica que voltou para a tela inicial
        //XCTAssertTrue(verDetalhesButton.waitForExistence(timeout: 5), "Deveria retornar à tela inicial após o botão Back")
    }

    @MainActor
    func testLimpar() throws {
        // Testando o botão de limpar (limpa SwiftData, CoreData e reseta lista da API)
        let app = XCUIApplication()
        app.launch()

        // Aguarda a tela inicial carregar e localiza o botão Limpar (SwiftUI expõe como staticText dentro do Button)
        let limparElement = app.staticTexts["Limpar"].firstMatch
        XCTAssertTrue(limparElement.waitForExistence(timeout: 10), "Botão 'Limpar' deveria estar visível na tela inicial")

        limparElement.tap()

        // Após limpar, a lista é repopulada pela API - aguarda algum jogo aparecer
        let grandTheftAuto = app.staticTexts["Grand Theft Auto V"]
        if grandTheftAuto.waitForExistence(timeout: 8) {
            grandTheftAuto.firstMatch.swipeDown()
        }
        limparElement.tap()
        limparElement.tap()

        // Verifica que o botão Limpar permanece disponível (operação concluída sem crash)
        XCTAssertTrue(limparElement.exists, "Botão 'Limpar' deveria permanecer visível após a operação")
    }
    
    @MainActor
    func testScroll() throws {
        // Testando o Scroll Horizontal dos jogos (lista vinda da API)
        let app = XCUIApplication()
        app.launch()

        // Aguarda pelo menos um jogo carregar na lista horizontal
        let payday2 = app.staticTexts["PAYDAY 2"]
        XCTAssertTrue(payday2.waitForExistence(timeout: 15), "Lista de jogos deveria carregar e exibir 'PAYDAY 2'")

        // Usa o ScrollView como alvo do swipe - elementos fora da tela têm frame vazio e não podem ser alvo de gestos
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "ScrollView dos jogos deveria existir")

        // Executa swipes no scroll view para navegar horizontalmente entre os jogos
        scrollView.swipeLeft()
        scrollView.swipeLeft()
        scrollView.swipeRight()
        scrollView.swipeRight()
        scrollView.swipeRight()
        scrollView.swipeRight()
        scrollView.swipeRight()
        scrollView.swipeLeft()

        // Verifica que o scroll funcionou - ao menos um dos jogos deve estar na tela
        let jogosEsperados = ["PAYDAY 2", "Left 4 Dead 2", "The Witcher 3: Wild Hunt", "Portal 2", "Red Dead Redemption 2", "Life is Strange", "Limbo", "Team Fortress 2"]
        let algumJogoVisivel = jogosEsperados.contains { app.staticTexts[$0].firstMatch.exists }
        XCTAssertTrue(algumJogoVisivel, "Após o scroll, pelo menos um jogo da lista deveria estar visível")
    }
    
    @MainActor
        func testDragApartirDaScrollView() {

            let app = XCUIApplication()
                app.launch()

                // origem
                let game = app.staticTexts["Team Fortress 2"].firstMatch

                // destino (card azul)
                let jogueiCard = app.staticTexts["Joguei"].firstMatch

                XCTAssertTrue(game.waitForExistence(timeout: 3))
                XCTAssertTrue(jogueiCard.waitForExistence(timeout: 3))

                // drag
                game.press(forDuration: 0.5, thenDragTo: jogueiCard)
            }
    
    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

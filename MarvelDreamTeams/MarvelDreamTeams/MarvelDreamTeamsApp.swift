//
//  MarvelDreamTeamsApp.swift
//  MarvelDreamTeams
//
//  Created by Jordan Small on 12/5/24.
//


import SwiftUI
import ParseSwift

@main
struct MarvelDreamTeamsApp: App {
    init() {
        // Initialize ParseSwift
        ParseSwift.initialize(applicationId: "j3ckWoV6Sc1xSIbkOPykQyBBFgGiJ4QBX2RnJZ4t",
                               clientKey: "2iLl8RkWiocR7OxP962IMw86KqzbQPQno0vPYKQu",
                               serverURL: URL(string: "https://parseapi.back4app.com")!) // Fixed URL
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
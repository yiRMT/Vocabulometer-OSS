//
//  ContentView.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/03.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var authManager = AuthManager()
    
    var body: some View {
        if authManager.isSignedIn {
            MainView(authManager: authManager)
        } else {
            AuthView(authManager: authManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

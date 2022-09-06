//
//  HomeView.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/06.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var authManager: AuthManager
    
    var body: some View {
        VStack {
            Text("Hello, Home!")
            Button {
                if let error = authManager.signOut() {
                    print(error.localizedDescription)
                }
            } label: {
                Text("Sign out")
            }

        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(authManager: AuthManager())
    }
}

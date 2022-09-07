//
//  MainView.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/06.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            VStack {
                // Top bar UI
                ZStack {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: nil, height: 30.0)
                        
                    HStack {
                        Spacer()
                        NavigationLink(destination: SettingsView(authManager: authManager)) {
                            Label("", systemImage: "gear")
                        }
                    }
                }
                
                MainTabView()
            }
        }        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(authManager: .init())
    }
}

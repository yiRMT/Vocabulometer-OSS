//
//  MainMenuView.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/06.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var authManager: AuthManager
    
    var body: some View {
        MainTabView()
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(authManager: AuthManager())
    }
}

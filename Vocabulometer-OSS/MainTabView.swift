//
//  MainTabView.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/08.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .padding(.leading)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            BrowseView()
                .padding(.horizontal)
                .tabItem {
                    Label("Browse", systemImage: "square.grid.2x2.fill")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

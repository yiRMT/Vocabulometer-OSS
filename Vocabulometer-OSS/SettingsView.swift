//
//  SettingsView.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/08.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authManager: AuthManager
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: AboutView()) {
                    Text("About")
                }
            }
            Section {
                Button {
                    if let error = authManager.signOut() {
                        print(error.localizedDescription)
                    }
                } label: {
                    Text("Sign out").foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(authManager: .init())
    }
}

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
        Button {
            if let error = authManager.signOut() {
                print(error.localizedDescription)
            }
        } label: {
            Text("Sign out")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(authManager: .init())
    }
}

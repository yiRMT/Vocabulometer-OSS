//
//  BrowseView.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/08.
//

import SwiftUI

struct BrowseView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            HStack {
                Text("Browse")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                Spacer()
            }
            Spacer()
        }
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView()
    }
}

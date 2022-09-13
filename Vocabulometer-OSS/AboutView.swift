//
//  AboutView.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/10.
//

import SwiftUI

struct AboutView: View {
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Image("Logo")
                    Text("Vocabulometer OSS")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Version: \(version)")
                }
                Divider()
                VStack {
                    Text("About the App")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    Text("DEVELOPER")
                        .fontWeight(.semibold)
                        .padding(.top, 10.0)
                    VStack {
                        Text("Yuichiro IWASHITA")
                    }
                     
                    Text("ABOUT")
                        .fontWeight(.semibold)
                        .padding(.top, 10.0)
                    Text("This project has been developed by students from the Intelligent Media Processing labratory, in the Osaka Prefecture University / Osaka Metropolitan University.\n\nThis app has been created for research purpose, as part of exploring how to use new technology devices such as smartphones to enhance people's lives.\n\nThe original Vocabulometer web application has been developed by the IMP lab (OPU / OMU) and University of Bordeaux students.")
                        .multilineTextAlignment(.center)
                    
                    Text("CODES")
                        .fontWeight(.semibold)
                        .padding(.top, 10.0)
                    Link("Vocabulometer-OSS@GitHub", destination: URL(string: "https://github.com/yiRMT/Vocabulometer-OSS")!)

                    Text("CONTACT")
                        .fontWeight(.semibold)
                        .padding(.top, 10.0)
                    VStack {
                        Link("imp.vocameter.ios@gmail.com",
                              destination: URL(string: "mailto:imp.vocameter.ios@gmail.com")!)
                    }
                }
                Divider()
                Text("Copyright © 2022 Yuichiro IWASHITA. This software is licensed under the MIT License.")
                    .font(.footnote)
                    .foregroundColor(Color.gray)
                    .padding()
            }
            .padding()
        }
        .navigationTitle("About")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

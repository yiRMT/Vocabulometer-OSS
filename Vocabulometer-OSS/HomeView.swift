//
//  HomeView.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/08.
//

import SwiftUI
import Charts

struct ChartEntry: Identifiable {
    var title: String
    var value: Double
    var color: Color = .green
    var id: String { title + String(value) }
}

struct HomeView: View {
    @State private var userLevel = 5
    @State private var participantID: String?
    
    @State private var wordsRead = WordsRead.newWordsRead
    
    enum WordsRead: String, CaseIterable, Identifiable {
        case newWordsRead = "New Words Read"
        case totalWordsRead = "Total Words Read"
        var id: String { rawValue }
    }
    
    let data: [ChartEntry] = [
        .init(title: "A", value: 5),
        .init(title: "A", value: 10, color: .blue),
        .init(title: "B", value: 10),
        .init(title: "C", value: 8)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            HStack {
                Text("Home")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                Spacer()
            }
            Text("Your Info")
                .font(.title)
                .fontWeight(.bold)
            HStack {
                VStack(spacing: 10.0) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.yellow)
                    Image(systemName: "tag.fill")
                        .foregroundColor(.gray)
                }
                VStack(alignment: .leading, spacing: 10.0) {
                    Text("Your vocabulary level: \(userLevel)")
                    Text("Participant ID: \(participantID ?? "Unregistered")")
                }
            }
            Text("Words Stats")
                .font(.title)
                .fontWeight(.bold)
            
            Chart {
                ForEach(data) { dataPoint in
                    BarMark(
                        x: .value("Category", dataPoint.title),
                        y: .value("Value", dataPoint.value)
                    )
                    .foregroundStyle(dataPoint.color)
                }
            }
            .frame(height: 200)
            
            Picker("Words stats", selection: $wordsRead) {
                        ForEach(WordsRead.allCases) {
                            friend in
                            Text(friend.rawValue).tag(friend)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
            
            Spacer()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

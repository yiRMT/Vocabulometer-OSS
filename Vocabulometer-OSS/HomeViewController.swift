//
//  HomeViewController.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/10/05.
//

import UIKit
import Charts

class HomeViewController: UIViewController {
    let database = DatabaseManager()
    
    @IBOutlet weak var userSkillLabel: UILabel!
    @IBOutlet weak var statsWordsModeControll: UISegmentedControl!
    
    var statsData = [String:Int]()
    var weekStats = [Double]()
    var week = [String]()
    
    @IBOutlet weak var chartView: LineChartView! {
        didSet {
            /// x軸の設定
            chartView.xAxis.labelPosition = .bottom
            chartView.xAxis.labelFont = .systemFont(ofSize: 11)
            chartView.xAxis.labelTextColor = .label
            chartView.xAxis.axisLineColor = .label
            chartView.xAxis.drawGridLinesEnabled = false
            
            /// y軸の設定
            chartView.rightAxis.enabled = false
            chartView.leftAxis.enabled = true
            chartView.leftAxis.axisMinimum = 0
            chartView.leftAxis.labelFont = .systemFont(ofSize: 11)
            chartView.leftAxis.labelTextColor = .label
            chartView.leftAxis.axisLineColor = .label
            chartView.leftAxis.drawAxisLineEnabled = false
            //lineChartView.leftAxis.labelCount = 4
            chartView.leftAxis.drawGridLinesEnabled = true
            chartView.leftAxis.gridColor = .gray
            
            chartView.noDataFont = .systemFont(ofSize: 30)
            chartView.noDataTextColor = .label
            chartView.noDataText = "Keep Waiting"
            chartView.legend.enabled = true
            chartView.legend.font = .systemFont(ofSize: 11)
            //lineChartView.dragDecelerationEnabled = true
            //lineChartView.dragDecelerationFrictionCoef = 0.6
            chartView.chartDescription.text = nil
            
             
            chartView.highlightPerTapEnabled = false
            chartView.doubleTapToZoomEnabled = false
            chartView.pinchZoomEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            do {
                let userInfo = try await database.getUserInfoData()
                userSkillLabel.text = "Your vocabulary level: " + (String)(userInfo.skill)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        chartView.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        week = [String]()
        let dt = Date()
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMd", options: 0, locale: Locale(identifier: "ja_JP"))

        for index in 0...6 {
            let modifiedDate = Calendar.current.date(byAdding: .day, value: index - 6, to: dt)!
            week.append(dateFormatter.string(from: modifiedDate))
        }
        
        Task {
            do {
                try await database.getStatsData()
                weekStats = .init()
                var statsType = StatsType.newWords
                
                if statsWordsModeControll.selectedSegmentIndex == 0 {
                    statsData = database.statsNewData
                    statsType = .newWords
                } else {
                    statsData = database.statsData
                    statsType = .totalWords
                }
                
                for day in week {
                    if let wordCount = statsData[day] {
                        weekStats.append(Double(wordCount))
                    } else {
                        weekStats.append(0.0)
                    }
                }
                
                let xValue = week.map { String($0[$0.index($0.startIndex, offsetBy: 5)..<$0.index($0.endIndex, offsetBy: 0)]) }
                            
                drawLineChart(xValArr: xValue, yValArr: weekStats, statsType: statsType)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func tapStatsWordsControll(_ sender: Any) {
        viewWillAppear(true)
    }
    
    func drawLineChart(xValArr: [String], yValArr: [Double], statsType: StatsType) {
        print(xValArr)
        //self.lineChartView.xAxis.labelCount = 7
        chartView.leftAxis.axisMaximum = (yValArr.max() ?? 0)*1.25
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xValArr)
        
        var yValues = [ChartDataEntry]()
        
        for i in 0 ..< xValArr.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: yValArr[i])
            yValues.append(dataEntry)
        }

        let data = LineChartData()
        
        let ds = LineChartDataSet(entries: yValues) //ds means DataSet
        
        if statsType == .newWords {
            ds.label = "New words read"
            ds.fillColor = .systemMint //グラフ塗りつぶし色
            ds.setColor(.systemMint)

        } else {
            ds.label = "Total words read"
            ds.fillColor = .systemPink
            ds.setColor(.systemPink)
        }
        
        /// グラフのUI設定
        ///その他UI設定
        ds.lineWidth = 3.0 //線の太さ
        //ds.circleRadius = 0 //プロットの大きさ
        ds.drawCirclesEnabled = false //プロットの表示(今回は表示しない)
        ds.mode = .linear //曲線にする
        ds.drawCirclesEnabled = false
        ds.fillAlpha = 0.5 //グラフの透過率(曲線は投下しない)
        ds.drawFilledEnabled = true //グラフ下の部分塗りつぶし
        ds.drawValuesEnabled = true //各プロットのラベル表示(今回は表示しない)
        ds.valueFont = .systemFont(ofSize: 9)
        
        /// グラフのUI設定
        data.append(ds)

        chartView.data = data
    }
    
    enum StatsType {
        case newWords
        case totalWords
    }
}

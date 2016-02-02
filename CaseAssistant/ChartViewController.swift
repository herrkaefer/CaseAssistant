//
//  ChartViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/5/13.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit
import PNChart

class ChartViewController: UIViewController, PNChartDelegate, UIScrollViewDelegate
{
    var patient: Patient? {
        didSet {
            loadDataForCharts()
        }
    }
    
    var firstRecordDate: NSDate?
//    var operationDate: NSDate?
    var dayIntervalLabels = [String]()
    var dateLabels = [String]()
    var rShiliData = [CGFloat]()
    var lShiliData = [CGFloat]()
    var rJiaozhengshiliData = [CGFloat]()
    var lJiaozhengshiliData = [CGFloat]()
    var rYanyaData = [CGFloat]()
    var lYanyaData = [CGFloat]()
    
    struct ChartConstants {
        static let GreenColor = UIColor(red: 94/255.0, green: 189/255.0, blue: 86/255.0, alpha:1.0)
        static let YellowColor = UIColor(red: 251/255.0, green: 183/255.0, blue: 47/255.0, alpha:1.0)
        static let OrangeColor = UIColor(red: 245/255.0, green: 130/255.0, blue: 51/255.0, alpha:1.0)
        static let RedColor = UIColor(red: 222/255.0, green: 78/255.0, blue: 81/255.0, alpha:1.0)
        static let BlueColor = UIColor(red: 68/255.0, green: 163/255.0, blue: 205/255.0, alpha:1.0)
        static let ChartHeight: CGFloat = 200.0
        static let ChartMargin: CGFloat = 25.0
        static let LegendLeftMargin: CGFloat = 20.0
        static let TitleHeight: CGFloat = 15.0
    }
    
    var screenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.size.width
    }
    

    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    var containerView: UIView!
    
    
    // MARK: - Helper Functions
    
    func getShiliData(s: String) -> CGFloat {
        if s.isEmpty {
            return 1e-6
        }
        
        if s.beginsWith("无光感") {
            return -2.4
        } else if s.beginsWith("光感") {
            return -2.1
        } else if s.beginsWith("手动10cm") {
            return -1.8
        } else if s.beginsWith("手动30cm") {
            return -1.5
        } else if s.beginsWith("手动50cm") {
            return -1.2
        } else if s.beginsWith("指数10cm") {
            return -0.9
        } else if s.beginsWith("指数30cm") {
            return -0.6
        } else if s.beginsWith("指数50cm") {
            return -0.3
        } else {
            return CGFloat((s as NSString).floatValue)
        }
        
    }
    
    func getYanyaData(s: String) -> CGFloat {
        if s.isEmpty {
            return 1e-6
        }
        if s.beginsWith("测不出") {
            return -10.0
        } else {
            return CGFloat((s as NSString).floatValue)
        }
        
    }
    
    func loadDataForCharts() {
        dayIntervalLabels.removeAll()
        dateLabels.removeAll()
        rShiliData.removeAll()
        lShiliData.removeAll()
        rJiaozhengshiliData.removeAll()
        lJiaozhengshiliData.removeAll()
        rYanyaData.removeAll()
        lYanyaData.removeAll()
        
        firstRecordDate = patient!.firstTreatmentDate

        for r in patient!.recordsSortedAscending {
            let days = numberOfDaysBetweenTwoDates(firstRecordDate!, r.date)
            dayIntervalLabels.append("\(days)d")
            dateLabels.append(NSDateFormatter.localizedStringFromDate(r.date, dateStyle: .ShortStyle, timeStyle: .NoStyle))
            rShiliData.append(getShiliData(r.g("rShili")))
            lShiliData.append(getShiliData(r.g("lShili")))
            rJiaozhengshiliData.append(getShiliData(r.g("rJiaozhengshili")))
            lJiaozhengshiliData.append(getShiliData(r.g("lJiaozhengshili")))
            rYanyaData.append(getYanyaData(r.g("rYanya")))
            lYanyaData.append(getYanyaData(r.g("lYanya")))
        }
    }
    
    
    func createRShiliChart(originY: CGFloat) -> (chart: PNLineChart, titleLabel: UILabel, legend: UIView) {
        
        var titleLabel = UILabel(frame: CGRectMake(0, originY + ChartConstants.ChartMargin, containerView.frame.width, ChartConstants.TitleHeight))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = "右眼视力"
        
        var chart = PNLineChart(frame: CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.height, containerView.frame.width, ChartConstants.ChartHeight))
        chart.yLabelFormat = "%1.1f";
        chart.backgroundColor = UIColor.clearColor()
        chart.showCoordinateAxis = true;
        chart.setXLabels(dayIntervalLabels, withWidth: chart.chartCavanWidth/CGFloat(dayIntervalLabels.count))
        chart.yFixedValueMax = 2.5
        chart.yFixedValueMin = min(minElement(rShiliData), minElement(rJiaozhengshiliData)) - 0.1
        
        var data1 = PNLineChartData()
        data1.dataTitle = "右眼裸眼视力"
        data1.color = ChartConstants.YellowColor
        data1.alpha = 1.0
        data1.itemCount = UInt(rShiliData.count)
        data1.inflexionPointStyle = PNLineChartPointStyle.Circle
        data1.getData = ({(index: UInt) -> PNLineChartDataItem in
            var yValue:CGFloat = self.rShiliData[Int(index)]
            println("y: \(yValue)")
            var item = PNLineChartDataItem(y: yValue)
            return item
        })

        var data2 = PNLineChartData()
        data2.dataTitle = "右眼矫正视力"
        data2.color = ChartConstants.GreenColor
        data2.alpha = 1.0
        data2.itemCount = UInt(rJiaozhengshiliData.count)
        data2.inflexionPointStyle = PNLineChartPointStyle.Circle
        data2.getData = ({(index: UInt) -> PNLineChartDataItem in
            var yValue:CGFloat = self.rJiaozhengshiliData[Int(index)]
            var item = PNLineChartDataItem(y: yValue)
            return item
        })

        var zeroData = PNLineChartData()
        zeroData.dataTitle = "零值参照"
        zeroData.color = UIColor.lightGrayColor()
        zeroData.alpha = 1.0
        zeroData.itemCount = UInt(lJiaozhengshiliData.count)
        zeroData.inflexionPointStyle = PNLineChartPointStyle.None
        zeroData.getData = ({(index: UInt) -> PNLineChartDataItem in
            var yValue:CGFloat = 1e-6
            var item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        chart.chartData = [zeroData, data1, data2]
        chart.strokeChart()
        chart.delegate = self
        
        chart.legendStyle = PNLegendItemStyle.Stacked
        chart.legendFont = UIFont.boldSystemFontOfSize(12.0)
        chart.legendFontColor = UIColor.blackColor()

        var legend = chart.getLegendWithMaxWidth(chart.bounds.width)
        legend.frame = CGRectMake(ChartConstants.LegendLeftMargin, chart.frame.origin.y + chart.frame.height, legend.frame.size.width, legend.frame.size.width)
        
        return (chart, titleLabel, legend)
    }

    func createLShiliChart(originY: CGFloat) -> (chart: PNLineChart, titleLabel: UILabel, legend: UIView) {
        
        var titleLabel = UILabel(frame: CGRectMake(0, originY + ChartConstants.ChartMargin, containerView.frame.width, ChartConstants.TitleHeight))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = "左眼视力"
        
        var chart = PNLineChart(frame: CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.height, containerView.frame.width, ChartConstants.ChartHeight))
        chart.yLabelFormat = "%1.1f";
        chart.backgroundColor = UIColor.clearColor()
        chart.showCoordinateAxis = true;
        chart.setXLabels(dayIntervalLabels, withWidth: chart.chartCavanWidth/CGFloat(dayIntervalLabels.count))
        chart.yFixedValueMax = 2.5
        chart.yFixedValueMin = min(minElement(lShiliData), minElement(lJiaozhengshiliData)) - 0.1
        
        var data1 = PNLineChartData()
        data1.dataTitle = "左眼裸眼视力"
        data1.color = ChartConstants.YellowColor
        data1.alpha = 1.0
        data1.itemCount = UInt(lShiliData.count)
        data1.inflexionPointStyle = PNLineChartPointStyle.Circle
        data1.getData = ({(index: UInt) -> PNLineChartDataItem in
            var yValue:CGFloat = self.lShiliData[Int(index)]
            println("y: \(yValue)")
            var item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        var data2 = PNLineChartData()
        data2.dataTitle = "左眼矫正视力"
        data2.color = ChartConstants.BlueColor
        data2.alpha = 1.0
        data2.itemCount = UInt(lJiaozhengshiliData.count)
        data2.inflexionPointStyle = PNLineChartPointStyle.Circle
        data2.getData = ({(index: UInt) -> PNLineChartDataItem in
            var yValue:CGFloat = self.lJiaozhengshiliData[Int(index)]
            var item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        var zeroData = PNLineChartData()
        zeroData.dataTitle = "零值参照"
        zeroData.color = UIColor.lightGrayColor()
        zeroData.alpha = 1.0
        zeroData.itemCount = UInt(lJiaozhengshiliData.count)
        zeroData.inflexionPointStyle = PNLineChartPointStyle.None
        zeroData.getData = ({(index: UInt) -> PNLineChartDataItem in
            var yValue:CGFloat = 1e-6
            var item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        chart.chartData = [zeroData, data1, data2]
        chart.strokeChart()
        chart.delegate = self
        
        chart.legendStyle = PNLegendItemStyle.Stacked
        chart.legendFont = UIFont.boldSystemFontOfSize(12.0)
        chart.legendFontColor = UIColor.blackColor()
        
        var legend = chart.getLegendWithMaxWidth(chart.bounds.width)
        legend.frame = CGRectMake(ChartConstants.LegendLeftMargin, chart.frame.origin.y + chart.frame.height, legend.frame.size.width, legend.frame.size.width)
        
        return (chart, titleLabel, legend)
    }
    
    func createYanyaChart(originY: CGFloat) -> (chart: PNLineChart, titleLabel: UILabel, legend: UIView) {
        
        var titleLabel = UILabel(frame: CGRectMake(0, originY + ChartConstants.ChartMargin, containerView.frame.width, ChartConstants.TitleHeight))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = "眼压"
        
        var chart = PNLineChart(frame: CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.height, containerView.frame.width, ChartConstants.ChartHeight))
        chart.yLabelFormat = "%1.1f";
        chart.backgroundColor = UIColor.clearColor()
        chart.showCoordinateAxis = true;
        chart.setXLabels(dayIntervalLabels, withWidth: chart.chartCavanWidth/CGFloat(dayIntervalLabels.count))
        chart.yFixedValueMax = max(maxElement(rYanyaData), maxElement(lYanyaData)) + 10
        chart.yFixedValueMin = min(minElement(rYanyaData), minElement(lYanyaData)) - 10
        
        var data1 = PNLineChartData()
        data1.dataTitle = "右眼眼压"
        data1.color = ChartConstants.GreenColor
        data1.alpha = 1.0
        data1.itemCount = UInt(rYanyaData.count)
        data1.inflexionPointStyle = PNLineChartPointStyle.Circle
        data1.getData = ({(index: UInt) -> PNLineChartDataItem in
            var yValue:CGFloat = self.rYanyaData[Int(index)]
            var item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        var data2 = PNLineChartData()
        data2.dataTitle = "左眼眼压"
        data2.color = ChartConstants.BlueColor
        data2.alpha = 1.0
        data2.itemCount = UInt(lYanyaData.count)
        data2.inflexionPointStyle = PNLineChartPointStyle.Circle
        data2.getData = ({(index: UInt) -> PNLineChartDataItem in
            var yValue:CGFloat = self.lYanyaData[Int(index)]
            var item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        chart.chartData = [data1, data2]
        chart.strokeChart()
        chart.delegate = self
        
        chart.legendStyle = PNLegendItemStyle.Stacked
        chart.legendFont = UIFont.boldSystemFontOfSize(12.0)
        chart.legendFontColor = UIColor.blackColor()
        
        var legend = chart.getLegendWithMaxWidth(chart.bounds.width)
        legend.frame = CGRectMake(ChartConstants.LegendLeftMargin, chart.frame.origin.y + chart.frame.height, legend.frame.size.width, legend.frame.size.width)
        
        return (chart, titleLabel, legend)
    }
    
    func userClickedOnLinePoint(point: CGPoint, lineIndex: Int) {
        println("clicked on line \(lineIndex)")
    }
    
    func userClickedOnLineKeyPoint(point: CGPoint, lineIndex: Int, pointIndex: Int) {
        println("clicked on line \(lineIndex) point \(pointIndex)")
        if lineIndex == 0 {
            println("value: \(rShiliData[pointIndex])")
        }
        if lineIndex == 1 {
            println("value: \(rJiaozhengshiliData[pointIndex])")
        }
    }
    
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = containerView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        containerView.frame = contentsFrame
    }
    
    // horizontally left, vertically top
    func topScrollViewContents() {
        var contentsFrame = containerView.frame
        contentsFrame.origin.x = 0.0
        contentsFrame.origin.y = 0.0
        containerView.frame = contentsFrame
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return containerView
    }

    func scrollViewDidZoom(scrollView: UIScrollView) {
//        centerScrollViewContents()
    }
    
    // IBActions
    
    @IBAction func saveImageButtonPressed(sender: UIBarButtonItem) {
        UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, true, UIScreen.mainScreen().scale)
        if containerView.respondsToSelector("drawViewHierarchyInRect") {
            containerView.drawViewHierarchyInRect(containerView.bounds, afterScreenUpdates: true)
        } else {
            containerView.layer.renderInContext(UIGraphicsGetCurrentContext())
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        // 弹出保存成功提示
        popupPrompt("图片已保存到手机相册", self.view)
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if patient!.records.count <= 1 {
            // 不画图
            popupPrompt("数据量太少，至少需要两条记录", self.view)
        }
    }
    
    // 在viewDidLoad()中得到的scrollView的width是600，在这里才足够晚来得到真实值。
    // ref: http://stackoverflow.com/a/26533891
    // 放在这里画图的另一个好处是，当设备旋转后也会调用，正好重绘
    override func viewDidLayoutSubviews() {
        
        // Set up the container view to hold your custom view hierarchy
//        println("screenWidth: \(screenWidth)")
        let containerSize = CGSize(width: screenWidth, height: 800.0)
        containerView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size:containerSize))
        containerView.backgroundColor = UIColor.whiteColor()
        scrollView.addSubview(containerView)
        
        if patient!.records.count > 1 {
            // create and add charts
            let (chart1, title1, legend1) = createRShiliChart(0.0)
            containerView.addSubview(title1)
            containerView.addSubview(chart1)
            containerView.addSubview(legend1)
            let (chart2, title2, legend2) = createLShiliChart(legend1.frame.origin.y + ChartConstants.ChartMargin)
            containerView.addSubview(title2)
            containerView.addSubview(chart2)
            containerView.addSubview(legend2)
            let (chart3, title3, legend3) = createYanyaChart(legend2.frame.origin.y + ChartConstants.ChartMargin)
            containerView.addSubview(title3)
            containerView.addSubview(chart3)
            containerView.addSubview(legend3)
    //        println("bottom: \(legend2.frame.origin.y)")
            
            // Tell the scroll view the size of the contents
            scrollView.contentSize = containerSize
            
            // Set up the minimum & maximum zoom scales
            let scrollViewFrame = scrollView.frame
    //        println("scroll frame: \(scrollView.frame)")
            let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
            let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
            let minScale = min(scaleWidth, scaleHeight)
            
    //        println("minScale: \(minScale)")
            scrollView.minimumZoomScale = 1.0 //minScale
            scrollView.maximumZoomScale = 2.0
            scrollView.zoomScale = 1.0
            
            topScrollViewContents()
            
        }
    }
    
}

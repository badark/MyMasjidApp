//
//  ViewController.swift
//  prayerTimings
//
//  Created by Badar Khan on 5/8/15.
//  Copyright (c) 2015 Badar Khan. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate {
    
    
    @IBOutlet weak var prayerNames: UITableView!
    @IBOutlet weak var jammatTimings: UITableView!
    
    var items: [String] = ["4:30 AM", "1:30 PM", "5:00 PM", "7:15 PM", "9:00 PM"]
    var salahNames: [String] = ["Fajr", "Zuhr", "Asr", "Maghrib", "Isha"]
    
    //xml data
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    
    
    //create a multi-dem array
    //baically we will have timing[year][month][day]
    //where year is either 0 (this year) and 1 (next year)
    //      month 1 -12 
    //      day   1-[29-31]
    //      salah Time
    var prayersFromXML: [[[[(Int,Int,Int,String)]]]]
    var yearIndex: Int
    var monthIndex: Int
    var dayIndex: Int
    
    
    var fajr = NSMutableString()
    var zuhr = NSMutableString()
    var asr = NSMutableString()
    var maghrib = NSMutableString()
    var isha = NSMutableString()
    
    var date = NSMutableString()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.jammatTimings.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.prayerNames.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        var tYear = 2
        var tMonths = 12
        var tDays = 31
       // var string
        //for column in 0..<columns {
         //   array2D.append(Array(count:rows, repeatedValue:Int()))
        //}
    
//        var url = NSURL(string: "http://masjidumar.com/files/timings/jamaat_timings.xml")
//        var xmlParser = NSXMLParser(contentsOfURL: url)!
//        xmlParser.delegate = self
//        xmlParser.parse()
        
    }

    
    //BKK:  added for table view method overloaders
    
    //number of cells in the table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5;
    }
    
    
    //Mehtod to add contents to each cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        if(tableView == jammatTimings)
        {
            
            //get today's date
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let components = NSCalendar.currentCalendar().components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: date)
            let day = components.day
            
            //read in the downloaded XML file in the correct formating.
            //var value = NSString(data: self.currXMLFile!, encoding: NSUTF8StringEncoding)
            
            var cell:UITableViewCell = self.jammatTimings.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
            
            cell.textLabel?.text = self.items[indexPath.row]
            
            
            return cell
        }
        else
        {
            var prayercell:UITableViewCell = self.prayerNames.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
            
            prayercell.textLabel?.text = self.salahNames[indexPath.row]
            
            return prayercell
            
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        println("You selected cell #\(indexPath.row)!")
    }
    

    func load(URL: NSURL){
        var downloadedFile: NSData? = nil
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as NSHTTPURLResponse).statusCode
                println("Success: \(statusCode)")
                
                // This is your file-variable:
                // data
                self.beginParsing(data)
                
                
            }
            else {
                // Failure
                println("Faulure: %@", error.localizedDescription);
            }
        })
        task.resume()
        
    }
    
    func beginParsing(file: NSData)
    {
        posts = []
        parser = NSXMLParser(data: file)
        parser.delegate = self
        parser.parse()
        //Trigger a update the table data for jamat timings
        //jammatTimings!.reloadData()
    }

    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!)
    {
        element = elementName
        if (elementName as NSString).isEqualToString("year")
        {
            //get today's date
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let components = NSCalendar.currentCalendar().components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: date)
            let year = components.year
            
            //we found the current year set the index to 0
            if((attributeDict["value"] as Int) == year)
            {
                yearIndex = 0
            }
            //we found the next year set the index to 1
            else if((attributeDict["value"] as Int) == (year + 1))
            {
                yearIndex = 1
            }
            else
            {
                yearIndex = 2
            }
            
        }
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!)
    {
        if element.isEqualToString("fajr") {
            fajr.appendString(string)
            zuhr.appendString(string)
            asr.appendString(string)
            maghrib.appendString(string)
            isha.appendString(string)
        } else if element.isEqualToString("pubDate") {
            date.appendString(string)
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)
    {
        if (elementName as NSString).isEqualToString("year") {
            if !title1.isEqual(nil) {
                elements.setObject(title1, forKey: "title")
            }
            if !date.isEqual(nil) {
                elements.setObject(date, forKey: "date")
            }
            
            posts.addObject(elements)
        }
    }
    
    
}


/* old stuff

class Downloader {
    
    var currXMLFile: NSData? = nil
    
    func saveXMLFile(xmlFile: NSData){
        currXMLFile = xmlFile
    }
    
    func getXMLFile() -> NSData?{
        return currXMLFile
    }

    
    func load(URL: NSURL){
        var downloadedFile: NSData? = nil
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as NSHTTPURLResponse).statusCode
                println("Success: \(statusCode)")
                
                // This is your file-variable:
                // data
                downloadedFile = data
                
            }
            else {
                // Failure
                println("Faulure: %@", error.localizedDescription);
            }
        })
        task.resume()
        
        currXMLFile = downloadedFile
    }
}


class jamatTimes {
    class func getPrayers() -> ([String]) {
        
        var items: [String] = ["0:30 AM", "1:30 PM", "2:00 PM", "3:15 PM", "4:00 PM"]
        let getFile = Downloader()
        
        if var URL = NSURL(string: "http://www.masjidumar.com/files/timings/j5.xml") {
            getFile.load(URL)
            
        }
        
        var fileName = getFile.getXMLFile()
        
        //var value = NSString(data: fileName!, encoding: NSUTF8StringEncoding)
        
        //xml tags
        //date
        // -fajr
        // -dhuhr
        // -asr
        // -maghrib
        // -isha
        
        
            return(items)
        }
}



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate {
    

    @IBOutlet weak var prayerNames: UITableView!
    @IBOutlet weak var jammatTimings: UITableView!
    
    //Store the xml file
    var currXMLFile: NSData? = nil
    
    //xml data
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    var date = NSMutableString()
    
    //xml sala time
    struct jammatTimingsStruct {
        var fajr = NSMutableString()
        var dhuhr = NSMutableString()
        var asr = NSMutableString()
        var maghrib = NSMutableString()
        var isha = NSMutableString()
    }
    
    var _jammatTimingsStruct[31] = jammatTimingsStruct()
    
    var fajr = NSMutableString()
    var dhuhr = NSMutableString()
    var asr = NSMutableString()
    var maghrib = NSMutableString()
    var isha = NSMutableString()
    
    var items: [String] = ["4:30 AM", "1:30 PM", "5:00 PM", "7:15 PM", "9:00 PM"]
    var salahNames: [String] = ["Fajr", "Zuhr", "Asr", "Maghrib", "Isha"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        self.jammatTimings.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.prayerNames.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        //items = jamatTimes.getPrayers()
        
        if var URL = NSURL(string: "http://masjidumar.com/files/timings/jamaat_timings.xml") {
            load(URL)
            
        }
        
    }
    
   // override func didReceiveMemoryWarning() {
    //    super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
   // }
    
    //BKK:  added for table view method overloaders
    
    //number of cells in the table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5;
    }
    
    
    //Mehtod to add contents to each cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        if(tableView == jammatTimings)
        {
            
            //get today's date
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let components = NSCalendar.currentCalendar().components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: date)
            let day = components.day

            //read in the downloaded XML file in the correct formating.
            //var value = NSString(data: self.currXMLFile!, encoding: NSUTF8StringEncoding)
            
            var cell:UITableViewCell = self.jammatTimings.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
            cell.textLabel?.text = self.items[indexPath.row]
        
        
            return cell
        }
        else
        {
            var prayercell:UITableViewCell = self.prayerNames.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
            
            prayercell.textLabel?.text = self.salahNames[indexPath.row]
            
            return prayercell
            
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        println("You selected cell #\(indexPath.row)!")
    }
    
    
    func load(URL: NSURL){
        var downloadedFile: NSData? = nil
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as NSHTTPURLResponse).statusCode
                println("Success: \(statusCode)")
                
                // This is your file-variable:
                // data
                self.currXMLFile = data
                
                self.beginParsing(data)
               
                
            }
            else {
                // Failure
                println("Faulure: %@", error.localizedDescription);
            }
        })
        task.resume()
        
    }
    
    func beginParsing(file: NSData)
    {
        posts = []
        parser = NSXMLParser(data: file)
        parser.delegate = self
        parser.parse()
        //Trigger a update the table data for jamat timings
        //jammatTimings!.reloadData()
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!)
    {
        element = elementName
        if (elementName as NSString).isEqualToString("date day")
        {
            elements = NSMutableDictionary.alloc()
            elements = [:]
            title1 = NSMutableString.alloc()
            title1 = ""
            date = NSMutableString.alloc()
            date = ""
        }
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!)
    {

    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)
    {
//        if (elementName as NSString).isEqualToString("date day") {
//            if !title1.isEqual(nil) {
//                elements.setObject(fajr, forKey: "fajr")
//            }
//            if !date.isEqual(nil) {
//                elements.setObject(dhuhr, forKey: "dhuhr")
//            }
//            if !date.isEqual(nil) {
//                elements.setObject(asr, forKey: "asr")
//            }
//            if !date.isEqual(nil) {
//                elements.setObject(maghrib, forKey: "maghrib")
//            }
//            if !date.isEqual(nil) {
//                elements.setObject(isha, forKey: "isha")
//            }
//            
//            posts.addObject(elements)
//        }
        
        if (elementName as NSString).isEqualToString("date day") {
            _jammatTimingsStruct[i]
            
            
        }
    }
    

}
*/

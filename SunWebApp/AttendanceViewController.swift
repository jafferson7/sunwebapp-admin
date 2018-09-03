//
//  AttendanceViewController.swift
//  SunWebApp
//
//  Created by Usmaan Jaffer on 8/30/18.
//  Copyright © 2018 Usmaan Jaffer. All rights reserved.
//

import UIKit

class AttendanceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if studentResult[indexPath.row].newAttd == "NR" {
            studentResult[indexPath.row].newAttd = studentResult[indexPath.row].attd
        }
        
        let text = studentResult[indexPath.row].name + " (" +
            studentResult[indexPath.row].attd + ")" + " - " +
            studentResult[indexPath.row].newAttd
        
        cell.textLabel?.text = text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var attdIndex = 0
        if studentResult[indexPath.row].newAttd != "NR" {
            attdIndex = (attdResult.name.index(of: studentResult[indexPath.row].newAttd)! + 1) % attdResult.name.count
        }
        
        self.studentResult[indexPath.row].newAttd = attdResult.name[attdIndex]
        print("Click!!")
        tableView.deselectRow(at: indexPath, animated: true)
        self.stdTable.beginUpdates()
        DispatchQueue.main.async {
            self.stdTable.reloadRows(at: [indexPath], with: .automatic)
        }
        self.stdTable.endUpdates()
    }
    
    let getWeeksURL = "https://www.sunwebapp.com/app/GetWeeksAndroid.php?Scode=sdf786ic&SchoolCode=demo"
    
    var weeksResult : weeksArray!
    
    var weekFinished : Bool = false
    
    var courseFinished : Bool = false
    
    struct weeksArray: Codable {
        var id: [String?]
        var name: [String?]
        
        private enum CodingKeys : String, CodingKey {
            case id
            case name
        }
    }
    
    let getCoursesURL = "https://www.sunwebapp.com/app/GetCoursesAndroid.php?Scode=sdf786ic&SchoolCode=demo"
    
    var courseResult : coursesArray!
    var attdResult : Attd!
    
    struct coursesArray: Codable {
        var code: [String?]
        var name: [String?]
        
        private enum CodingKeys : String, CodingKey {
            case code
            case name
        }
    }
    
    @IBOutlet weak var stdTable: UITableView!
    
    @IBAction func saveAttd(_ sender: Any) {
        print("Attempting to save the Attendance...")
        var saveURL = "https://www.sunwebapp.com/app/SaveAttd.php?SchoolCode=" + "demo" //Demo&Ccode=A1G&W=1&count=1&s0=165&a0=A" // get the school code
        saveURL += "&Ccode=" + "A1G" // get the coursecode
        saveURL += "&W=" + "1" // get the week number
        saveURL += "&count=" + String(describing: studentResult.count) // get the number of students
        var counter : Int = 0
        for student in studentResult {
            saveURL += "&s" + String(describing: counter) + "=" + student.id
            saveURL += "&a" + String(describing: counter) + "=" + student.newAttd
            counter += 1
        }
        print(saveURL)
        let url = URL(string: saveURL)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.getAllTasks { (openTasks: [URLSessionTask]) in
            NSLog("open tasks: \(openTasks)")
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (responseData: Data?, response: URLResponse?, error: Error?) in
            NSLog("\(response)")
        })
        task.resume()
        
        getStudents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        stdTable.dataSource = self
        stdTable.delegate = self
        
        getWeeks()
        getCourses()
        getAttdArray()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func something(weeksFinished: Bool, courseFinished: Bool) -> Void {
        if weeksFinished && courseFinished {
            print(weeksResult.name[0] ?? "NA")
            print(courseResult.name[0] ?? "nA")
            getStudents()
//            self.stdTable.reloadData()
        }
    }
    
    func getWeeks() {
        
        // create url
        guard let url = URL(string: getWeeksURL) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                
                let decoder = JSONDecoder()
                self.weeksResult = try decoder.decode(weeksArray.self, from: data)
                // print(result.name.count)
                
                self.weekFinished = true
                
                self.something(weeksFinished: self.weekFinished, courseFinished: self.courseFinished)
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
    
    func getCourses() {
        
        // create url
        guard let url = URL(string: getCoursesURL) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                
                let decoder = JSONDecoder()
                self.courseResult = try decoder.decode(coursesArray.self, from: data)
                // print(result.name.count)
                
                self.courseFinished = true
                
                self.something(weeksFinished: self.weekFinished, courseFinished: self.courseFinished)
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
    
//    let getStudentsURL = "https://www.sunwebapp.com/app/GetStdsAndroid.php?Scode=sdf786ic&SchoolCode=demo&CourseCode=A1G&W=1"
    let getStudentsURL = "https://www.sunwebapp.com/app/GetStdsiPhone.php?Scode=sdf786ic&SchoolCode=demo&CourseCode=A1G&W=1"

    var studentResult : [Student] = []
    
    struct Student : Codable {
        var id : String
        var name : String
        var attd : String
        var newAttd : String = "NR"
        
        private enum CodingKeys : String, CodingKey {
            case id
            case name
            case attd
        }
    }
    
    func getStudents() {
        // create url
        guard let url = URL(string: getStudentsURL) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                
                let decoder = JSONDecoder()
                self.studentResult = try decoder.decode([Student].self, from: data)
                
                print(self.studentResult[2].name)
                print(self.studentResult.count)
                
                DispatchQueue.main.async {
                    self.stdTable.reloadData()
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
    
    let getAttdURL = "https://www.sunwebapp.com/app/GetAttdAndroid.php?SchoolCode=demo"
    
    struct Attd : Codable {
        var name : [String]
        
        private enum CodingKeys : String, CodingKey {
            case name
        }
    }
    
    func getAttdArray() {
        // create the URL
        guard let url = URL(string: getAttdURL) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                
                let decoder = JSONDecoder()
                self.attdResult = try decoder.decode(Attd.self, from: data)
                
                dump(self.attdResult.name)
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
}


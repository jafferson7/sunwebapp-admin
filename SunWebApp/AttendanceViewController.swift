//
//  AttendanceViewController.swift
//  SunWebApp
//
//  Created by Usmaan Jaffer on 8/30/18.
//  Copyright © 2018 Usmaan Jaffer. All rights reserved.
//

import UIKit

class AttendanceViewController: UIViewController,
    UITableViewDelegate, UITableViewDataSource,
UIPickerViewDelegate, UIPickerViewDataSource {
    
    var schoolCode : String = ""
    
    var courseCode : String = ""
    
    var weekIdx : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        stdTable.dataSource = self
        stdTable.delegate = self
        
        coursePicker.dataSource = self
        coursePicker.delegate = self
        
        weekPicker.dataSource = self
        weekPicker.delegate = self
        
        schoolCode = UserDefaults.standard.string(forKey: "schoolCode")!
        print(schoolCode)
        
        getWeeks()
        getCourses()
        getAttdArray()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == coursePicker {
            return courseResult.count
        } else if pickerView == weekPicker {
            return weeksResult.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == coursePicker {
            return courseResult[row].code
        } else if pickerView == weekPicker {
            return weeksResult[row].name
        }
        return "hello world"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == coursePicker {
            courseCode = courseResult[row].code
        } else if pickerView == weekPicker {
            weekIdx = String(describing: weeksResult[row].id)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if studentResult[indexPath.row].newAttd == "NR" {
            if studentResult[indexPath.row].attd == "NR" {
                studentResult[indexPath.row].newAttd = attdResult.name[0]
            } else {
                studentResult[indexPath.row].newAttd = studentResult[indexPath.row].attd
            }
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
    
    var weekFinished : Bool = false
    
    var courseFinished : Bool = false
    
    @IBOutlet weak var stdTable: UITableView!
    
    @IBOutlet weak var coursePicker: UIPickerView!
    
    @IBOutlet weak var weekPicker: UIPickerView!
    
    @IBAction func selectCourseAndWeek() {
        print(self.courseResult[self.coursePicker.selectedRow(inComponent: 0)].code)
        print(self.weeksResult[self.weekPicker.selectedRow(inComponent: 0)].id)
        getStudents()
    }
    
    func something(weeksFinished: Bool, courseFinished: Bool) -> Void {
        if weeksFinished && courseFinished {
            
            DispatchQueue.main.async {
                self.coursePicker.reloadAllComponents()
                self.weekPicker.reloadAllComponents()
            }
            courseCode = courseResult[0].code
            weekIdx = weeksResult[0].id
            getStudents()
        }
    }
    
    var getWeeksURL = "https://www.sunwebapp.com/app/GetWeeksiPhone.php?Scode=sdf786ic&SchoolCode=" //demo"
    
    var weeksResult : [Week] = []
    
    struct Week : Codable {
        var id : String
        var name : String
        
        private enum CodingKeys : String, CodingKey {
            case id
            case name
        }
    }
    
    func getWeeks() {
        
        // create url
        getWeeksURL += schoolCode
        guard let url = URL(string: getWeeksURL) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                
                let decoder = JSONDecoder()
                self.weeksResult = try decoder.decode([Week].self, from: data)
                // print(result.name.count)
                
                self.weekFinished = true
                
                self.something(weeksFinished: self.weekFinished, courseFinished: self.courseFinished)
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
    
    var getCoursesURL = "https://www.sunwebapp.com/app/GetCoursesiPhone.php?Scode=sdf786ic&SchoolCode=" //demo"
    
    var courseResult : [Course] = []
    
    struct Course : Codable {
        var code: String
        var name: String
        
        private enum CodingKeys : String, CodingKey {
            case code
            case name
        }
    }
    
    func getCourses() {
        
        // create url
        getCoursesURL += schoolCode
        guard let url = URL(string: getCoursesURL) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                
                let decoder = JSONDecoder()
                self.courseResult = try decoder.decode([Course].self, from: data)
                // print(result.name.count)
                
                self.courseFinished = true
                
                self.something(weeksFinished: self.weekFinished, courseFinished: self.courseFinished)
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
    
    var getStudentsURL = "https://www.sunwebapp.com/app/GetStdsiPhone.php?Scode=sdf786ic&SchoolCode=" // demo&CourseCode=A1G&W=1"
    
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
        print("starting to get the students")
            self.getStudentsURL += self.schoolCode
                + "&CourseCode=" + courseCode //self.courseResult[self.coursePicker.selectedRow(inComponent: 0)].code
                + "&W=" + weekIdx //self.weeksResult[self.weekPicker.selectedRow(inComponent: 0)].id
        let escapedString = getStudentsURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//        print(escapedString)
        guard let url = URL(string: escapedString) else {return}
//        print(url)
        getStudentsURL = "https://www.sunwebapp.com/app/GetStdsiPhone.php?Scode=sdf786ic&SchoolCode=" // reset url
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                
                let decoder = JSONDecoder()
                self.studentResult = try decoder.decode([Student].self, from: data)
                
                DispatchQueue.main.async {
                    self.stdTable.reloadData()
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
    
    let getAttdURL = "https://www.sunwebapp.com/app/GetAttdAndroid.php?SchoolCode=demo"
    
    var attdResult : Attd!
    
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
    
    struct savedAttd : Codable {
        var Sid : String
        var flag : Bool
        
        private enum CodingKeys : String, CodingKey {
            case Sid
            case flag
        }
    }
    
    @IBAction func saveAttd() {
        print("Attempting to save the Attendance...")
        var saveURL = "https://www.sunwebapp.com/app/SaveAttdiPhone.php?SchoolCode=" + schoolCode // get the school code
        saveURL += "&Ccode=" + self.courseResult[self.coursePicker.selectedRow(inComponent: 0)].code
            + "&W=" + self.weeksResult[self.weekPicker.selectedRow(inComponent: 0)].id
        saveURL += "&count=" + String(describing: studentResult.count) // get the number of students
        var counter : Int = 0
        for student in studentResult {
            saveURL += "&s" + String(describing: counter) + "=" + student.id
            saveURL += "&a" + String(describing: counter) + "=" + student.newAttd
            counter += 1
        }
        saveURL = saveURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(saveURL)
        
        guard let url = URL(string: saveURL) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                
                let decoder = JSONDecoder()
                let result = try decoder.decode([savedAttd].self, from: data)
                
                dump(result)
                
                var success : Bool = true;
                
                for i in result {
                    if !i.flag {
                        success = i.flag
                    }
                }
                
                if success {
                    self.getStudents()
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
}


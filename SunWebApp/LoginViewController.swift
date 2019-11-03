//
//  LoginViewController.swift
//  SunWebApp
//
//  Created by Usmaan Jaffer on 8/30/18.
//  Copyright © 2018 Usmaan Jaffer. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var schoolCodeTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginBtn:UIButton!
    
    // https://www.sunwebapp.com/app/GetTeacherA.php?Scode=sdf786ic&SchoolCode=demo&A=testa@sunwebapp.com&P=mateen
    
    // https://gist.github.com/kobeumut/b06015646aa0d5f072bfe14e499690ef
    
    var getTeacherURL = "https://www.sunwebapp.com/app/GetTeacherAndroid.php?Scode=sdf786ic&SchoolCode="//demo&A=testa@sunwebapp.com&P=mateen"
    
    struct loginResult: Codable {
        var id: String?
        var name: String?
        
        private enum CodingKeys : String, CodingKey {
            case id
            case name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //         getJsonFromUrl()
        schoolCodeTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //self.view.endEditing(<#Bool#>)
        schoolCodeTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
     //   NSLog(schoolCodeTextField.text ?? <#default value#>)
        
        if (schoolCodeTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "") {
            getJsonFromUrl()
        }
       // if (textField == self.passwordTextField) {
            
            //self.loginBtn.becomeFirstResponder()}
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getJsonFromUrl() {
        
        schoolCodeTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        // create url
        getTeacherURL += (schoolCodeTextField.text ?? "demo")
        getTeacherURL += "&A=" + (emailTextField.text ?? "testa@sunwebapp.com")
        getTeacherURL += "&P=" + (passwordTextField.text ?? "mateen")
        print(getTeacherURL)
        guard let url = URL(string: getTeacherURL) else {return}
       getTeacherURL = "https://www.sunwebapp.com/app/GetTeacherAndroid.php?Scode=sdf786ic&SchoolCode="
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else
            { print ("No error")}
 
            guard let data = data else { return }
      
            //Implement JSON decoding and parsing
            do {
                
                let decoder = JSONDecoder()
                let loginData = try decoder.decode(loginResult.self, from: data)
                print(loginData.name ?? "NO NAME")
                
                if(loginData.id != "0") {
                    UserDefaults.standard.set(loginData.name, forKey: "name")
                    UserDefaults.standard.set(loginData.id, forKey: "id")
//                    UserDefaults.standard.set("demo", forKey: "schoolCode")
                    
                    UserDefaults.standard.set(self.schoolCodeTextField.text, forKey: "schoolCode")
//                    DispatchQueue.main.async {
//                        UserDefaults.standard.set(self.schoolCodeTextField.text, forKey: "schoolCode")
//                    }
                    print("logging in \(loginData.name!)")
                    OperationQueue.main.addOperation {
                        self.performSegue(withIdentifier: "GoToAttd", sender: nil)
                    }
                }
                else
                {
                    
                    //self.view.endEditing(true)
                     let alert = UIAlertController(title: "Login Error", message: "Username and/or password not found", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
                    self.present(alert, animated: true)
                }
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
}

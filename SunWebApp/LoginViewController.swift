//
//  LoginViewController.swift
//  SunWebApp
//
//  Created by Usmaan Jaffer on 8/30/18.
//  Copyright © 2018 Usmaan Jaffer. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // https://www.sunwebapp.com/app/GetTeacherA.php?Scode=sdf786ic&SchoolCode=demo&A=testa@sunwebapp.com&P=mateen
    
    // https://gist.github.com/kobeumut/b06015646aa0d5f072bfe14e499690ef
    
    let getTeacherURL = "https://www.sunwebapp.com/app/GetTeacherAndroid.php?Scode=sdf786ic&SchoolCode=demo&A=testa@sunwebapp.com&P=mateen"
    
    
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getJsonFromUrl() {
        
        // create url
        guard let url = URL(string: getTeacherURL) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                
                let decoder = JSONDecoder()
                let loginData = try decoder.decode(loginResult.self, from: data)
                print(loginData.name ?? "NO NAME")
                
                if(loginData.id != "0") {
                    print("logging in \(loginData.name!)")
                    UserDefaults.standard.set(loginData.name, forKey: "name")
                    self.performSegue(withIdentifier: "GoToAttd", sender: nil)
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
}

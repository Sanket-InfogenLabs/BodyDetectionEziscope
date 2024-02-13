//
//  LoginViewController.swift
//  PoseEstimation
//
//  Created by Bhushan-Gajare on 02/02/24.
//  Copyright © 2024 tensorflow. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorText: UILabel!
    
    @IBAction func LoginAction(_ sender: Any) {
        
        let vc = HomeScreenViewController.loadViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        username.delegate = self
        password.delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController: UITextFieldDelegate {
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)

            // Check if the resulting text exceeds the character limit
            if textField == username {
                let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_@.-+")
                if updatedText.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil {
                    let characterLimit = 256
                    if updatedText.count <= characterLimit {
                        if updatedText.count < 6 {
    #if DEBUG
                            print("less than 6")
    #endif
                            return true
                        }
                        else {
                            return true
                        }
                    }
                    else {
                        return false
                    }
                }

                return false
            }
            else {
                return true
            }
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            textField.text = textField.text?.lowercased()
            print("A")
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            print("B")
            return true
        }
        func textFieldDidBeginEditing(_ textField: UITextField) {
            print("C")
        }
        func textFieldDidEndEditing(_ textField: UITextField) {
           
            print("D")
               
            }
           
    }

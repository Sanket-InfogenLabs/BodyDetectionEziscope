//
//  LoginViewController.swift
//  PoseEstimation
//
//  Created by Bhushan-Gajare on 02/02/24.
//  Copyright © 2024 tensorflow. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBAction func LoginAction(_ sender: Any) {
        
        let vc = HomeScreenViewController.loadViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

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

//
//  HomeScreen.swift
//  PoseEstimation
//
//  Created by Sanket Lothe on 05/02/24.
//  Copyright © 2024 tensorflow. All rights reserved.
//

import UIKit

class HomeScreen: UIViewController {

    
    @IBOutlet weak var showMePopUp: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func showMeActionPop(_ sender: Any) {
        
        let alertController = UIAlertController(
                                    title: "Choose Camera",
                                    message: "Use Front Camera if you using the app alone",
                                    preferredStyle: .alert)

            // Handling OK action
            let okAction = UIAlertAction(title: "Front", style: .default) { (action:UIAlertAction!) in
                
                let childVC =  TexturedFace.loadViewController(withStoryBoard: "Main")
                self.navigationController?.pushViewController(childVC, animated: true)
                          
            }

            // Handling Cancel action
            let cancelAction = UIAlertAction(title: "Back", style: .default) { (action:UIAlertAction!) in
                let childVC =  ARCameraBack.loadViewController(withStoryBoard: "Main")
                self.navigationController?.pushViewController(childVC, animated: true)
                          
            }

            // Adding action buttons to the alert controller
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)

            // Presenting alert controller
            self.present(alertController, animated: true, completion:nil)
    }
    

}

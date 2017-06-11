//
//  NoteContentViewController.swift
//  NotesForTheVisuallyChallenged
//
//  Created by Salim Fang on 2017/5/19.
//  Copyright © 2017年 Salim Fang. All rights reserved.
//

import UIKit

class NoteContentViewController: UIViewController {
    
    override func viewDidLoad(){
        // Show the navigation bar on other view controllers
        UINavigationBar.appearance().barTintColor = UIColor(colorLiteralRed: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.navigationController?.isNavigationBarHidden = false

    }
    
    let vc = VoiceCore()
    
    @IBAction func speechBtnTapped(_ sender: Any) {
        vc.speak("je ne parle francais pas")
        vc.speak("記錄於三月十七日。")
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

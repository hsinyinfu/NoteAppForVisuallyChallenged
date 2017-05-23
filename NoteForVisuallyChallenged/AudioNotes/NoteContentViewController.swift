//
//  NoteContentViewController.swift
//  NotesForTheVisuallyChallenged
//
//  Created by Salim Fang on 2017/5/19.
//  Copyright © 2017年 Salim Fang. All rights reserved.
//

import UIKit

class NoteContentViewController: UIViewController {

    
    let vc = VoiceCore()
    
    @IBAction func speechBtnTapped(_ sender: Any) {
        vc.speak("不要問我從哪裡來，我的故鄉在遠方，為什麼流浪？流浪遠方，流浪。")
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

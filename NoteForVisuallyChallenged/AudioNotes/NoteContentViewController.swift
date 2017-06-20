//
//  NoteContentViewController.swift
//  NotesForTheVisuallyChallenged
//
//  Created by Salim Fang on 2017/5/19.
//  Copyright © 2017年 Salim Fang. All rights reserved.
//

import UIKit
protocol NoteViewControllerDelegate: AnyObject {
    func noteViewController(_ noteViewController: NoteContentViewController, didCloseNote note: TextNote)
}
class NoteContentViewController: UIViewController {
    
    weak var delegate: NoteViewControllerDelegate?
    
    
    @IBOutlet weak var thirdTag: UITextField!
    @IBOutlet weak var secondTag: UITextField!
    @IBOutlet weak var firstTag: UITextField!
    @IBOutlet weak var contentTextView: UITextView!

    var note: TextNote? {
        didSet {
            guard self.isViewLoaded else { return }
            self.updateUIElements()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUIElements()
    }
    
    func updateUIElements() {
        //print(self.note?.tags[0] ?? "no-title")
        self.firstTag.text = self.note?.tags[0]
        if (self.note?.tags.count)! >= 2{
            self.secondTag.text = self.note?.tags[1]
            print("123")
        }
        if (self.note?.tags.count)! >= 3{
            self.thirdTag.text = self.note?.tags[2]
        }
        //print(self.note?.content ?? "try")
        self.contentTextView.text = self.note?.content

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.note?.content = self.contentTextView.text ?? ""
        try? self.note?.save()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

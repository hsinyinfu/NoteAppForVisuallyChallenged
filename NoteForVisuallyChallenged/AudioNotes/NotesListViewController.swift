//
//  ViewController.swift
//  NotesForTheVisuallyChallenged
//
//  Created by Salim Fang on 2017/5/19.
//  Copyright © 2017年 Salim Fang. All rights reserved.
//


import UIKit
import Speech

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

class NotesListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    let reuseIdentifier = "cell" // cell identifier
    
    
    @IBOutlet weak var voiceBtn: UIButton!
    @IBOutlet weak var collections: UICollectionView!
    let vc = VoiceCore()
    
    // fake contents' array for testing only.
    // replace the codes to get the actual data later
    let firstTags = ["食譜", "學校", "French", "工讀", "明天的oral presentation", "橄欖樹"]
    let secondTags = ["蛋包飯", "期中考範圍", "Grammatical rules of nouns", "班表", "內容", "齊豫"]
    let thirdTags = ["", "泰文", "", "四月", "", "歌詞"]
    let dateOrTime = ["上午 1:18", "昨天", "週二", "3月24日", "3月19日", "3月17日"]
    let queue = DispatchQueue(label: "audioQueue")
    var count = 1
    // get the number of the items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.firstTags.count
    }
    
    // make a cell of each indexpath
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! NoteCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.firstTagShown.text = self.firstTags[indexPath.item]
        cell.secondTagShown.text = self.secondTags[indexPath.item]
        cell.thirdTagShown.text = self.thirdTags[indexPath.item]
        cell.dateShown.text = self.dateOrTime[indexPath.item]
        
        // design the cell
        cell.layer.borderColor = UIColor.cyan.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        
        /*
         
         // change border color when user touches cell
         func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
         let cell = collectionView.cellForItem(at: indexPath)
         cell?.layer.borderColor = UIColor.black.cgColor
         }
         
         // change border color back when user releases touch
         func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
         let cell = collectionView.cellForItem(at: indexPath)
         cell?.layer.borderColor = UIColor.cyan.cgColor
         }
         
         */
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // show a single note (tho the codes shoudln't be here. gonna fix it later.)
        print("You selected cell #\(indexPath.item)!")
        performSegue(withIdentifier: "OpenNote", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        
        
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("shake")
            vc.recogTapped()
            print(vc.recogResult ?? " NO result")
        }
        if vc.recogResult == "二"{
            for i in 0...self.firstTags.count-1{
                print (i)
                let rate = Float(0.57)
                vc.speak("第"+String(i+1)+"則",rate: rate)
                vc.speak(""+self.dateOrTime[i]+"的筆記，關於", rate:rate)
                vc.speak(self.firstTags[i], rate:rate)
                vc.speak(self.secondTags[i], rate:rate)
                vc.speak(self.thirdTags[i], rate:rate)
            }
        }
    }
    
    @IBAction func speechBtnTapped(_ sender: Any) {
        vc.mainMenu()

        
    }
}

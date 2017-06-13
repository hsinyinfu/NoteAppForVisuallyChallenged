//
//  ViewController.swift
//  NotesForTheVisuallyChallenged
//
//  Created by Salim Fang on 2017/5/19.
//  Copyright © 2017年 Salim Fang. All rights reserved.
//


import UIKit
import Speech
class NotesListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,SFSpeechRecognizerDelegate{
    
    let reuseIdentifier = "cell" // cell identifier
    
    
    @IBOutlet weak var voiceBtn: VoiceButton!
    @IBOutlet weak var collections: UICollectionView!
    

    // fake contents' array for testing only.
    // replace the codes to get the actual data later
    let firstTags = ["食譜", "學校", "French", "工讀", "明天的oral presentation", "橄欖樹"]
    let secondTags = ["蛋包飯", "期中考範圍", "Grammatical rules of nouns", "班表", "內容", "齊豫"]
    let thirdTags = ["", "泰文", "", "四月", "", "歌詞"]
    let dateOrTime = ["上午 1:18", "昨天", "週二", "3月24日", "3月19日", "3月17日"]
    
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
        
        //for speech api
        voiceBtn.isEnabled = false  //2
        voiceBtn.speechRecognizer?.delegate = self  //3
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.voiceBtn.isEnabled = isButtonEnabled
            }
        }

        
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            voiceBtn.recogTapped()
            print("shake")
//            print(voiceBtn.recogResult ?? " NO result")
        }
    }
    @IBAction func speechBtnTapped(_ sender: Any) {
        voiceBtn.mainMenu()
//            for i in 0...self.firstTags.count-1{
//                print (i)
//                let rate = Float(0.57)
//                voiceBtn.speak("第"+String(i+1)+"則",rate: rate)
//                voiceBtn.speak(""+self.dateOrTime[i]+"的筆記，關於", rate:rate)
//                voiceBtn.speak(self.firstTags[i], rate:rate)
//                voiceBtn.speak(self.secondTags[i], rate:rate)
//                voiceBtn.speak(self.thirdTags[i], rate:rate)
//            }
        
    }
}

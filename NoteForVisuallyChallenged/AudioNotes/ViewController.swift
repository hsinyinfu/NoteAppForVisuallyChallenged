//
//  ViewController.swift
//  NotesForTheVisuallyChallenged
//
//  Created by Salim Fang on 2017/5/19.
//  Copyright © 2017年 Salim Fang. All rights reserved.
//


import UIKit
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let reuseIdentifier = "cell" // cell identifier
    

    // fake contents' array for testing only.
    // replace the codes to get the actual data later
    let firstTags = ["食譜", "學校", "學校", "工讀", "孔雀東南飛", "橄欖樹"]
    let secondTags = ["乳酪蛋糕", "期中考範圍", "法文", "班表", "全文", "齊豫"]
    let thirdTags = ["", "泰文", "文法", "四月", "", "歌詞"]
    let dateOrTime = ["上午 1:18", "昨天", "週二", "3/24", "3/19", "3/17"]
    
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
        performSegue(withIdentifier: "segueToShowANote", sender: nil)
    }
}

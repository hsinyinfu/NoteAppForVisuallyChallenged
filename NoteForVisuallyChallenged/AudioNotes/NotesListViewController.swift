//
//  ViewController.swift
//  NotesForTheVisuallyChallenged
//
//  Created by Salim Fang on 2017/5/19.
//  Copyright © 2017年 Salim Fang. All rights reserved.
//


import UIKit
class NotesListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let reuseIdentifier = "cell" // cell identifier
    
    @IBOutlet weak var collectionView: UICollectionView!
    var refreshControl: UIRefreshControl!
    // fake contents' array for testing only.
    // replace the codes to get the actual data later
    //let firstTags = ["食譜", "學校", "學校", "工讀", "孔雀東南飛", "橄欖樹"]
    //let secondTags = ["乳酪蛋糕", "期中考範圍", "法文", "班表", "全文", "齊豫"]
    //let thirdTags = ["", "泰文", "文法", "四月", "", "歌詞"]
    //let dateOrTime = ["上午 1:18", "昨天", "週二", "3/24", "3/19", "3/17"]
    var noteTags = [[String]]() {
        didSet {
            if self.isViewLoaded {
                self.collectionView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateNoteTags()
        print("view did load")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NotesListViewController.textNoteDidUpdate(_:)),
                                               name: .TextNoteDidUpdate,
                                               object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func textNoteDidUpdate(_ notification: Notification) {
        print("here")
        self.updateNoteTags()
    }
    
    @IBAction func updateTableViewContent(_ sender: UIRefreshControl) {
        print("updateTableViewContent is called")
        self.updateNoteTags()
        sender.endRefreshing()
    }
    
    func updateNoteTags() {
        print("updateNoteTags is called")
        self.noteTags = TextNote.getTagsOfSavedNotes()
    }
    
    // get the number of the items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.noteTags.count
    }
    
    // make a cell of each indexpath
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! NoteCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let strArray = self.noteTags[indexPath.item]
        cell.firstTagShown.text = strArray[0]
        if strArray.count>=2{
            cell.secondTagShown.text = strArray[1]
        }
        if strArray.count>=3{
            cell.thirdTagShown.text = strArray[2]
        }
        cell.dateShown.text = "test"

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
        performSegue(withIdentifier: "OpenNote", sender:collectionView.cellForItem(at: indexPath)!)
    }
    func removeNote(at indexPath: IndexPath) {
        //let noteTag = self.noteTags[indexPath.row]
        self.collectionView?.reloadData()
        self.collectionView?.performBatchUpdates({
        self.collectionView?.deleteItems(at: [indexPath])
        }, completion: { (finished) -> Void in
            if finished {
                self.collectionView?.reloadData()
            }
        })
    }
    
//    func removeNote(at indexPath: IndexPath) {
//        let noteTags = self.noteTags[indexPath.row]
//        
//        self.collectionView.beginUpdates()
//        defer { self.collectionView.endUpdates() }
//        do {
//            try PureTextNote.remove(title: noteTitle)
//            self.updateNoteTitles()
//            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//        } catch {
//            fatalError("Cannot delete note: \(noteTitle)")
//        }
//    }
    
    // MARK: - Storyboard Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateNote" {
            print("create")
            self.prepareCreatingNote(for: segue)
        } else if segue.identifier == "OpenNote"{
            print(sender ?? "no")
            guard let cell = sender as? UICollectionViewCell else {
                fatalError("Mis-configured storyboard! The sender should be a cell.")
            }
            print("open")
            self.prepareOpeningNote(for: segue, sender: cell)
        }else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func prepareOpeningNote(for segue: UIStoryboardSegue, sender: UICollectionViewCell) {
        let noteViewController = segue.destination as! NoteContentViewController
        let senderIndexPath = self.collectionView.indexPath(for: sender)!
        let selectedTitle = self.noteTags[senderIndexPath.row]
        noteViewController.note = try! TextNote.open(tags: selectedTitle)
        noteViewController.delegate = self as? NoteViewControllerDelegate
    }
    
    func prepareCreatingNote(for segue: UIStoryboardSegue) {
        let noteContentViewController = segue.destination as! NoteContentViewController
        noteContentViewController.note = TextNote()
        
    }
    
    // MARK: - NoteViewController Delegate
    
    func noteViewController(_ noteViewController: NoteContentViewController, didCloseNote note: TextNote) {
        var noteTemp : TextNote = note
        try? noteTemp.save()
    }
}

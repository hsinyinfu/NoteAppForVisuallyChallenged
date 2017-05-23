//
//  NoteCollectionViewCell.swift
//  NotesForTheVisuallyChallenged
//
//  Created by Salim Fang on 2017/5/19.
//  Copyright © 2017年 Salim Fang. All rights reserved.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {

    // show the data
    @IBOutlet weak var firstTagShown: UILabel!
    @IBOutlet weak var secondTagShown: UILabel!
    @IBOutlet weak var thirdTagShown: UILabel!
    @IBOutlet weak var dateShown: UILabel!
    
    
    // make a gradient-colored background
    let definedGray = UIColor(red: 30, green: 30, blue: 30, alpha: 1)
    
    override open class var layerClass: AnyClass {
            get{
                return CAGradientLayer.classForCoder()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            let gradientLayer = self.layer as! CAGradientLayer
            gradientLayer.colors = [definedGray, UIColor.black.cgColor]
    }
    
}

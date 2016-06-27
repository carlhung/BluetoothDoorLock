//
//  CheckBox.swift
//  BTscan
//
//  Created by Carl Hung on 23/6/2016.
//  Copyright © 2016 carlhung. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    var checkedImage = UIImage(named: "checkbox_checked")!
    var unCheckedImage = UIImage(named: "checkbox_unchecked")!
    
    // bool propetry
    var isChecked = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, forState: .Normal)
            } else {
                self.setImage(unCheckedImage, forState: .Normal)
            }
        }
    }
    
    convenience init(checkedImage: UIImage, unCheckedImage: UIImage){
        self.init()
        self.checkedImage = checkedImage
        self.unCheckedImage = unCheckedImage
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked(_:)), forControlEvents: .TouchUpInside)
        self.isChecked = false
    }
    
    @objc private func buttonClicked(sender: UIButton) {
        if(sender === self) {
            if isChecked == true {
                isChecked = false
            } else {
                isChecked = true
            }
        }
    }
}

//
//  DieView.swift
//  Button Up
//
//  Created by Ricky Buchanan on 21/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import UIKit

@IBDesignable class DieView: UIView {

    var view:UIView!

    @IBOutlet weak var dieValue: DieButton!
    @IBOutlet weak var dieLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass:self.dynamicType)
        let nib = UINib(nibName: "DieView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.layer.cornerRadius = 5
        addSubview(view)
    }
    
    var outline: Bool = false {
        didSet {
            if outline {
                view.layer.borderWidth = 2
                view.layer.borderColor = UIColor.blackColor().CGColor
            } else {
                view.layer.borderWidth = 0
            }
        }
    }

}
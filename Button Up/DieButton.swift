//
//  DieButton
//  Button Up
//
//  Created by Ricky Buchanan on 17/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

// MARK: - DieButton: Button

class DieButton: UIButton {
    
    // MARK: Properties
    
    /* Constants for styling and configuration */
    let darkerBlue = UIColor(red: 0.0, green: 0.298, blue: 0.686, alpha:1.0)
    let lighterBlue = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    let titleLabelFontSize : CGFloat = 25.0
    let dieButtonHeight : CGFloat = 60.0
    let dieButtonCornerRadius : CGFloat = 30.0
    
    let dieButtonExtraPadding : CGFloat = 14.0
    
    var backingColor : UIColor? = nil
    var highlightedBackingColor : UIColor? = nil
    
    // MARK: Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.themeDieButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.themeDieButton()
    }
    
    func themeDieButton() -> Void {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = dieButtonCornerRadius
        self.highlightedBackingColor = darkerBlue
        self.backingColor = lighterBlue
        self.backgroundColor = lighterBlue
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.titleLabel?.font = UIFont.boldSystemFontOfSize(titleLabelFontSize)
    }
    
    // MARK: Setters
    
    private func setBackingColor(backingColor : UIColor) -> Void {
        if (self.backingColor != nil) {
            self.backingColor = backingColor;
            self.backgroundColor = backingColor;
        }
    }
    
    private func setHighlightedBackingColor(highlightedBackingColor: UIColor) -> Void {
        self.highlightedBackingColor = highlightedBackingColor
        self.backingColor = highlightedBackingColor
    }
    
    // MARK: Tracking
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent: UIEvent?) -> Bool {
        self.backgroundColor = self.highlightedBackingColor
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        self.backgroundColor = self.backingColor
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        self.backgroundColor = self.backingColor
    }
    
    // MARK: Layout
    
    override func intrinsicContentSize() -> CGSize {
//        let extraButtonPadding : CGFloat = dieButtonExtraPadding
        var intrinsicContentSize = CGSizeZero
        intrinsicContentSize.width = dieButtonHeight
        intrinsicContentSize.height = dieButtonHeight
        return intrinsicContentSize
        
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
//        let extraButtonPadding : CGFloat = dieButtonExtraPadding
        var sizeThatFits = CGSizeZero
        //sizeThatFits.width = super.sizeThatFits(size).width + extraButtonPadding
        sizeThatFits.width = dieButtonHeight
        sizeThatFits.height = dieButtonHeight
        return sizeThatFits
        
    }
}
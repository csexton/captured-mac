//
//  AccountTableCellView.swift
//  Captured
//
//  Created by Christopher Sexton on 11/21/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class AccountTableCellView: NSTableCellView {

  
  @IBOutlet weak var nameField: NSTextField!
  @IBOutlet weak var typeField: NSTextField!
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}

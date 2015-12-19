//
//  Command.swift
//  Captured
//
//  Created by Christopher Sexton on 12/18/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Foundation


class Command {

  var shortcut : Shortcut

  init(shortcut:Shortcut) {
    self.shortcut = shortcut
  }

  func run(){
    print(shortcut.accountIdentifier)


  }

}


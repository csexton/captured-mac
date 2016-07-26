//
//  CLI.swift
//  Captured
//
//  Created by Christopher Sexton on 7/22/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Foundation

class CLI {
  let defaults = NSUserDefaults.standardUserDefaults()
  var statusCode = EXIT_SUCCESS

  // Checks the command line arguments and attempts to run if appliciable.
  //
  // If there were valid command line arguments run, this method will terminate the entire app.
  class func run_and_terminate(args: [String]) {
    let cli = CLI()

    if cli.run(args) {
      exit(cli.statusCode)
//      NSApplication.sharedApplication().terminate(self)
    }
  }

  func run(args: [String]) -> Bool {
    if args.contains("help") || args.contains("--help") || args.contains("-h") {
      printUsage()
      return true
    } else if args.contains("list") {
      printAccountList()
      return true
    } else if args.contains("capture") {
      runCapture()
      return true
    } else {
      // No run command, so assume we should use the gui
      return false
    }
  }

  func printUsage() {
    print("Usage: Captured [command] <parameters>")
    print("")
    print("  Commands")
    print("")
    print("    list     List the accounts configured for Captured")
    print("    capture  Run the capture command and upload to the specified account")
    print("             Parameters:")
    print("               -account [ID] required the UUID of the account")
    print("               -scale [YES/NO] optional scaling down by 50%")
    print("")


  }

  func printAccountList() {
    let accountManager = AccountManager.sharedInstance
    accountManager.load()
    for account in accountManager.accounts {
      print("Name: \(account["Name"]!)")
      print("Type: \(account["Type"]!)")
      print("ID: \(account["Identifier"]!)")
      print("Summary: \(account["Summary"]!)")
      print("")
    }
  }

  func runCapture() {
    let accountManager = AccountManager.sharedInstance
    accountManager.load()

    if let accountID = defaults.stringForKey("account"),
      account = accountManager.accountWithIdentifier(accountID) {
      print(account)

      let shortcut = Shortcut()
      shortcut.name = "CLI"
      shortcut.accountIdentifier = accountID
      shortcut.action = defaultDefaultsString("action", defaultValue: "SelectArea")
      shortcut.annotateImage = false
      shortcut.scaleImage = defaults.boolForKey("scale")

      Command().run(shortcut)

    } else {
      print("missing account identifier")
      statusCode = EXIT_FAILURE
    }

  }

  func defaultDefaultsString(key: String, defaultValue: String) -> String {
    let fromDefaults = defaults.stringForKey(key)
    if let value = fromDefaults {
      return value
    } else {
      return defaultValue
    }
  }
}

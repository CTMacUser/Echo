//
//  ViewController.swift
//  Echo
//
//  Created by Daryle Walker on 9/4/17.
//  Copyright © 2017 Daryle Walker. All rights reserved.
//

import Cocoa


// MARK: - Primary Definition

/// Control Echo Transactions.
class ViewController: NSViewController {

    // MARK: Properties

    /// Whether or not a connection is active.
    dynamic var connected: Bool = false

    // Outlets
    @IBOutlet weak var serverAddressField: NSTextField!
    @IBOutlet weak var portField: NSTextField!
    @IBOutlet weak var submissionField: NSTextField!

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

// MARK: Actions

extension ViewController {

    @IBAction func connect(_ sender: NSButton) {
        let hostString = serverAddressField.stringValue
        guard !hostString.isEmpty && !connected else { return }

        connected = true
    }

    @IBAction func disconnect(_ sender: NSButton) {
        connected = false
    }

    @IBAction func echo(_ sender: NSButton) {
        let dataString = submissionField.stringValue
        guard !dataString.isEmpty && connected else { return }

        print("If this was a completed app, the 'echo' would be starting now, using \"\(dataString)\".")
    }

}

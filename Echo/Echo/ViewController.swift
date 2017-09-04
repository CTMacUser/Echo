//
//  ViewController.swift
//  Echo
//
//  Created by Daryle Walker on 9/4/17.
//  Copyright © 2017 Daryle Walker. All rights reserved.
//

import Cocoa
import Foundation


// MARK: - Primary Definition

/// Control Echo Transactions.
class ViewController: NSViewController {

    // MARK: Types

    /// Internally-generated errors.
    @objc enum ProtocolError: Int, Error {
        case unknown

        var localizedDescription: String {
            switch self {
            case .unknown: return NSLocalizedString("The error was uncategorized or arbitrary.", comment: "")
            }
        }

        var asNSError: NSError {
            return NSError(domain: String(describing: ProtocolError.self), code: self.rawValue, userInfo: [NSLocalizedFailureReasonErrorKey: self.localizedDescription])
        }
    }

    // MARK: Properties

    /// The session managing any connections.
    var session: URLSession!
    
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
        session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
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
    #if FORCE_SESSION_INVALIDATION
        session.invalidateAndCancel()
    #endif
    }

    @IBAction func echo(_ sender: NSButton) {
        let dataString = submissionField.stringValue
        guard !dataString.isEmpty && connected else { return }

        print("If this was a completed app, the 'echo' would be starting now, using \"\(dataString)\".")
    }

}

// MARK: Session Delegate

extension ViewController: URLSessionDelegate {

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard session === self.session else { return }

        DispatchQueue.main.async {
            let alert = NSAlert(error: error ?? ProtocolError.unknown.asNSError)
            if error != nil {
                alert.alertStyle = .critical
            }
            alert.addButton(withTitle: NSLocalizedString("Quit", comment: "Quit the app"))
            alert.beginSheetModal(for: self.view.window!) {
                assert($0 == NSAlertFirstButtonReturn)
                self.view.window?.close()
            }
        }
    }

}

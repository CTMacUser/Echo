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

    /// Implementation constants.
    enum Constants {
        /// The default port for the Echo protocol.
        static let defaultEchoPort = 7
    }
    
    /// Status during echo transaction.
    @objc enum Status: Int, CustomStringConvertible {
        case disconnected, idle, sending, errorWhileSending, receiving, errorWhileReceiving

        var description: String {
            switch self {
            case .disconnected: return NSLocalizedString("Disconnected.", comment: "When there is no connection")
            case .idle: return NSLocalizedString("Idle.", comment: "The connection is unused")
            case .sending: return NSLocalizedString("Sending…", comment: "Data is being sent")
            case .errorWhileSending: return NSLocalizedString("Error while sending!", comment: "An error occured whle sending")
            case .receiving: return NSLocalizedString("Receiving…", comment: "Data is being received")
            case .errorWhileReceiving: return NSLocalizedString("Error while receiving!", comment: "An error occured whlie receiving")
            }
        }
    }

    /// Internally-generated errors.
    @objc enum ProtocolError: Int, Error {
        case unknown

        var localizedDescription: String {
            switch self {
            case .unknown: return NSLocalizedString("The error was uncategorized or arbitrary.", comment: "")
            }
        }
    }

    // MARK: Properties

    /// The session managing any connections.
    var session: URLSession!
    /// The current connection.
    dynamic var task: URLSessionTask?
    /// The current connection status.
    dynamic var status: Status = .disconnected
    
    /// Whether or not a connection is active.
    dynamic var connected: Bool { return task != nil }
    /// User-readable status.
    dynamic var statusText: String { return status.description }

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

    // MARK: KVO Conformance

    class func keyPathsForValuesAffectingConnected() -> Set<String> {
        return [#keyPath(task)]
    }

    class func keyPathsForValuesAffectingStatusText() -> Set<String> {
        return [#keyPath(status)]
    }

}

// MARK: Actions

extension ViewController {

    /// Connect to the server with the given hostname at the given port.
    @IBAction func connect(_ sender: NSButton) {
        guard !connected, let echoURL = echoTarget.url, let host = echoURL.host, !host.isEmpty, let port = echoURL.port, (1..<(1 << 16)).contains(port) else { return }

        task = session.streamTask(withHostName: host, port: port)
        status = .idle
        task?.taskDescription = echoURL.absoluteString
        task?.resume()
    }

    /// Disconnect from the server.
    @IBAction func disconnect(_ sender: NSButton) {
        task?.cancel()
        status = .disconnected
        task = nil
    #if FORCE_SESSION_INVALIDATION
        session.invalidateAndCancel()
    #endif
    }

    /// Send the given data for an echo transaction.
    @IBAction func echo(_ sender: NSButton) {
        let dataString = submissionField.stringValue
        guard !dataString.isEmpty && connected else { return }

        print("If this was a completed app, the 'echo' would be starting now, using \"\(dataString)\".")
    }

}

// MARK: Session & Task Delegate

extension ViewController: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard session === self.session, task === self.task else { return }

        DispatchQueue.main.async {
            self.status = .disconnected
            self.task = nil
            if let error = error {
                let alert = NSAlert(error: error)
                let nserr = error as NSError
                switch (nserr.domain, nserr.code) {
                case (NSURLErrorDomain, NSURLErrorCancelled):
                    break
                default:
                    alert.beginSheetModal(for: self.view.window!)
                }
            }
        }
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard session === self.session else { return }

        DispatchQueue.main.async {
            let alert = NSAlert(error: error ?? ProtocolError.unknown)
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

// MARK: Helpers

extension ViewController {

    /// A URL storing the current hostname and port.
    var echoTarget: URLComponents {
        var result = URLComponents()
        result.scheme = "echo"
        result.host = serverAddressField.stringValue
        result.port = { $0 == 0 ? Constants.defaultEchoPort : $0 }(portField.integerValue)
        return result
    }

}

//
//  CallsViewController.swift
//  CallkitExample
//
//  Created by Mobdev125 on 12/20/17.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit

private let presentIncomingCallViewControllerSegue = "PresentIncomingCallViewController"
private let presentOutgoingCallViewControllerSegue = "PresentOutgoingCallViewController"
private let callCellIdentifier = "CallCell"

class CallsViewController: UITableViewController {
    
    var callManager: CallManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callManager = AppDelegate.shared.callManager
        
        callManager.callsChangedHandler = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()
        }
    }
    
    @IBAction private func unwindForNewCall(_ segue: UIStoryboardSegue) {
        let newCallController = segue.source as! NewCallViewController
        guard let handle = newCallController.handle else { return }
        let incoming = newCallController.incoming
        let videoEnabled = newCallController.videoEnabled
        
        if incoming {
            let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 1.5) {
                AppDelegate.shared.displayIncomingCall(uuid: UUID(), handle: handle, hasVideo: videoEnabled) { _ in
                    UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
                }
            }
        } else {
            callManager.startCall(handle: handle, videoEnabled: videoEnabled)
        }
    }
    
}

// MARK: - UITableViewDataSource

extension CallsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callManager.calls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let call = callManager.calls[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: callCellIdentifier) as! CallTableViewCell
        cell.callerHandle = call.handle
        cell.callState = call.state
        cell.incoming = !call.outgoing
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let call = callManager.calls[indexPath.row]
        callManager.end(call: call)
    }
}

// MARK - UITableViewDelegate

extension CallsViewController {
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "End"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let call = callManager.calls[indexPath.row]
        call.state = call.state == .held ? .active : .held
        callManager.setHeld(call: call, onHold: call.state == .held)
        
        tableView.reloadData()
    }
}


//
//  CallDirectoryHandler.swift
//  CallDirectoryHandler
//
//  Created by Mobdev125 on 12/20/17.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        
        do {
            try addBlockingPhoneNumbers(to: context)
        } catch {
            NSLog("Unable to add blocking phone numbers")
            let error = NSError(domain: "CallDirectoryHandler", code: 1, userInfo: nil)
            context.cancelRequest(withError: error)
            return
        }
        
        do {
            try addIdentificationPhoneNumbers(to: context)
        } catch {
            NSLog("Unable to add identification phone numbers")
            let error = NSError(domain: "CallDirectoryHandler", code: 2, userInfo: nil)
            context.cancelRequest(withError: error)
            return
        }
        
        context.completeRequest()
    }
    
    // 1.
    private func addBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) throws {
        let phoneNumbers: [CXCallDirectoryPhoneNumber] = [ 1234 ]
        
        for phoneNumber in phoneNumbers {
            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
        }
    }
    
    // 2.
    private func addIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) throws {
        let phoneNumbers: [CXCallDirectoryPhoneNumber] = [ 1111 ]
        let labels = [ "RW Tutorial Team" ]
        
        for (phoneNumber, label) in zip(phoneNumbers, labels) {
            context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumber, label: label)
        }
    }
    
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        print("An error occured when completing the request: \(error.localizedDescription)")
    }
    
}


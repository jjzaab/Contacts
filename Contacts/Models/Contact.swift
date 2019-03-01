//
//  Contact.swift
//  Contacts
//
//  Created by XMS_JZhan on 3/1/19.
//  Copyright © 2019 XMS_JZhan. All rights reserved.
//

import Foundation
import CloudKit

// MARK: - Struct of Resuable Keys for CKRecord fetching
struct Keys {
    static let ContactRecordType = "Contact"
    static let NameKey = "name"
    static let PhoneNumberKey = "phoneNumber"
    static let EmailKey = "email"
}

class Contact {
    
    // MARK: - Properties
    var name: String
    var phoneNumber: String?
    var email: String?
    var recordID: CKRecord.ID
    
    // MARK: - Initializers
    // Designated
    init(name: String, phoneNumber: String?, email: String?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.recordID = recordID
    }
    
    // Failable
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[Keys.NameKey] as? String,
            let phoneNumber = ckRecord[Keys.PhoneNumberKey] as? String,
            let email = ckRecord[Keys.EmailKey] as? String else { return nil }
        
        self.init(name: name, phoneNumber: phoneNumber, email: email, recordID: ckRecord.recordID)
    }
}

// MARK: - Extension of CKRecord to initialize with Contact
extension CKRecord {
    convenience init(contact: Contact) {
        self.init(recordType: Keys.ContactRecordType, recordID: contact.recordID)
        
        self.setValue(contact.name, forKey: Keys.NameKey)
        self.setValue(contact.phoneNumber, forKey: Keys.PhoneNumberKey)
        self.setValue(contact.email, forKey: Keys.EmailKey)
    }
}

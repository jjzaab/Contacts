
//
//  ContactController.swift
//  Contacts
//
//  Created by XMS_JZhan on 3/1/19.
//  Copyright © 2019 XMS_JZhan. All rights reserved.
//

import Foundation
import CloudKit

class ContactController {
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - Properties
    static let shared = ContactController()
    
    // Source of truth
    var contacts: [Contact] = []
    
    // MARK: - CRUD
    // Add New Contact
    func addContactWith(name: String, phoneNumber: String?, email: String?, completion: @escaping (Contact?) -> Void) {
        
        let contact = Contact(name: name, phoneNumber: phoneNumber, email: email)
        let record = CKRecord(contact: contact)
        
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("Error saving contact to iCloud at \(#function) with error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let record = record else {
                completion(nil)
                return
            }
            
            guard let returnedContact = Contact(ckRecord: record) else {
                completion(nil)
                return
            }
            
            self.contacts.append(returnedContact)
            completion(returnedContact)
        }
    }
    
    // Fetch All Contacts
    func fetchContacts(completion: @escaping ([Contact]?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Keys.ContactRecordType, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error fetching contacts from iCloud at \(#function) with error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let records = records else {
                completion([])
                return
            }
            
            let fetchedContactsArray = records.compactMap({ Contact(ckRecord: $0 )})
            self.contacts = fetchedContactsArray
            
            completion(fetchedContactsArray)
        }
    }
    
    // Update Contact
    func updateContact(name: String, phoneNumber: String?, email: String?, contact: Contact, completion: @escaping (Bool) -> Void) {
        
        contact.name = name
        contact.phoneNumber = phoneNumber
        contact.email = email
        
        publicDB.fetch(withRecordID: contact.recordID) { (record, error) in
            if let error = error {
                print("Error fetching contact to update from iCloud at \(#function) with error: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let record = record else {
                completion(false)
                return
            }

            record[Keys.NameKey] = name
            record[Keys.PhoneNumberKey] = phoneNumber
            record[Keys.EmailKey] = email
        
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
                completion(true)
            }
            
            self.publicDB.add(operation)
            completion(true)
        }
    }
}

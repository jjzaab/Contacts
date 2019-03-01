//
//  ContactDetailViewController.swift
//  Contacts
//
//  Created by XMS_JZhan on 3/1/19.
//  Copyright © 2019 XMS_JZhan. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // Landing Pad
    var contact: Contact? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let contact = contact {
            self.navigationItem.title = "\(contact.name)'s Information"
        } else {
            self.navigationItem.title = "New Contact"
        }
    }
    
    // MARK: - Update Views Pattern
    func updateViews() {
        guard let contact = contact else { return }
        DispatchQueue.main.async {
            self.nameTextField.text = contact.name
            self.phoneNumberTextField.text = contact.phoneNumber
            self.emailTextField.text = contact.email
        }
    }
    
    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let name = nameTextField.text,
            name != "",
            let phoneNumber = phoneNumberTextField.text,
            let email = emailTextField.text else { return }
        
        // Check if adding new contact or editing
        if let contact = contact {
            ContactController.shared.updateContact(name: name, phoneNumber: phoneNumber, email: email, contact: contact) { (success) in
                if success {
                    print("Successfully updated Contact")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("Error updating contact")
                }
            }
        } else {
            ContactController.shared.addContactWith(name: name, phoneNumber: phoneNumber, email: email) { (_) in
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

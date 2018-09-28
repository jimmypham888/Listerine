//
//  ViewController.swift
//  Listerine
//
//  Created by Jimmy Pham on 9/17/18.
//  Copyright © 2018 tuvans. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UIViewController {
    
    private var contacts: [CNMutableContact] = []
    let store = CNContactStore()
    var saveRequests: [CNSaveRequest] = []
    let numberArray: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    let headNumberViettel: [String] = ["0162", "0163", "0164", "0165", "0166", "0167", "0168", "0169"]
    let headNumberMobifone: [String] = ["0120", "0121", "0122", "0126", "0128"]
    let headNumberVinaphone: [String] = ["0123", "0124", "0125", "0127", "0129"]
    let headNumberVietnamMobile: [String] = ["0188", "0186"]
    let headNumberGtel: [String] = ["0199"]
    
    let masterHeadNumber: [String] = ["0162", "0163", "0164", "0165", "0166", "0167", "0168", "0169",
                                      "84162", "84163", "84164", "84165", "84166", "84167", "84168", "84169",
                                      "0120", "0121", "0122", "0126", "0128",
                                      "84120", "84121", "84122", "84126", "84128",
                                      "0123", "0124", "0125", "0127", "0129",
                                      "84123", "84124", "84125", "84127", "84129",
                                      "0188", "0186",
                                      "84188", "84186",
                                      "0199",
                                      "84199"]
    
    let replaceMasterHeadNumber: [String] = ["+8432", "+8433", "+8434", "+8435", "+8436", "+8437", "+8438", "+8439",
                                             "+8432", "+8433", "+8434", "+8435", "+8436", "+8437", "+8438", "+8439",
                                             "+8470", "+8479", "+8477", "+8476", "+8478",
                                             "+8470", "+8479", "+8477", "+8476", "+8478",
                                             "+8483", "+8484", "+8485", "+8481", "+8482",
                                             "+8483", "+8484", "+8485", "+8481", "+8482",
                                             "+8458", "+8456",
                                             "+8458", "+8456",
                                             "+8459",
                                             "+8459"
    ]

    @IBAction func didTapUpdateContact(_ sender: UIButton) {
        _updateContact()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.requestAccess(for: .contacts) { (isGranted, error) in
            if isGranted {
                self.fetchContact()
            }
        }
        
    }
    
    private func fetchContact() {
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .phoneticFullName), CNContactPhoneNumbersKey]
            .compactMap { $0 as? CNKeyDescriptor}
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        fetchRequest.mutableObjects = true
        fetchRequest.unifyResults = false
        fetchRequest.sortOrder = .userDefault
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                if let mutableContact = contact.mutableCopy() as? CNMutableContact {
                    self.contacts.append(mutableContact)
                }
            })
        } catch let e as NSError  {
            print(e.localizedDescription)
        }
    }
    
    private func _updateContact() {
        guard contacts.count > 0 else { return }
        
        contacts.forEach { (contactToUpdate) in
            
            // Loop to change any phone number in phoneNumbers array
            let newPhoneNumber = contactToUpdate.phoneNumbers.compactMap({ (phoneNumber) -> CNLabeledValue<CNPhoneNumber>? in
                
                let _phoneNumber = phoneNumber.value.stringValue.filter { numberArray.contains($0) }
                guard _phoneNumber.count >= 8 else { return nil }
                
                var _newPhoneNumber: CNLabeledValue<CNPhoneNumber>? = nil
                
                for (k, headNumber) in masterHeadNumber.enumerated() {
                    let rangeOfHeadNumber = _phoneNumber.range(of: headNumber)
                    if let _rangeOfHeadNumber = rangeOfHeadNumber {
                        let startPosition = _phoneNumber.distance(from: _phoneNumber.startIndex, to: _rangeOfHeadNumber.lowerBound)
                        
                        if startPosition == 0 {
                            // This is number should update
                            let newPhoneNumber = _phoneNumber.replacingCharacters(in: _rangeOfHeadNumber, with: replaceMasterHeadNumber[k])
                            _newPhoneNumber = CNLabeledValue(label: phoneNumber.label, value: CNPhoneNumber(stringValue: newPhoneNumber))
                            break
                        }
                    }
                }
                
                if let _newPhoneNumber = _newPhoneNumber {
                    return _newPhoneNumber
                } else {
                    return phoneNumber
                }
            })
            
            contactToUpdate.phoneNumbers = newPhoneNumber
            
            let saveRequest = CNSaveRequest()
            saveRequest.update(contactToUpdate)
            
            saveRequests.append(saveRequest)
            
            do {
                try saveRequests.forEach { try store.execute($0) }
            } catch let e as NSError {
                print(e.localizedDescription)
            }
        }
    }

}


extension String {
    
    func removeCharacters(from forbiddenChars: CharacterSet) -> String {
        let passed = self.unicodeScalars.filter { !forbiddenChars.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }
    
    func removeCharacters(from: String) -> String {
        return removeCharacters(from: CharacterSet(charactersIn: from))
    }
}

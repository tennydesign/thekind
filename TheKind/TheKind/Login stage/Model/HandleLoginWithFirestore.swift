//
//  HandleLoginWithFirestore.swift
//  TheKind
//
//  Created by Tenny on 3/3/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class HandleLoginWithFirestore {
    //LOGIN WITH FIREBASR
    
    func loginWithEmailAndPassword(_ email: String, _ password: String, completion: @escaping (Error?)->()) {
        // Will try to sign in  user.
        Auth.auth().signIn(withEmail: email, password: password, completion: { (res, err) in
            if let err = err {
                completion(err)
                return
            }
            
            KindUserSettingsManager.loggedUserName = String(email.split(separator: "@").first ?? "")
            KindUserSettingsManager.userFields[UserFieldTitle.name.rawValue] = KindUserSettingsManager.loggedUserName!
            KindUserSettingsManager.userFields[UserFieldTitle.email.rawValue] = email
            KindUserSettingsManager.updateUserSettings()
            completion(nil)
            
        })
    }
    
    func createNewUser(_ email: String, _ password: String, completion:  @escaping (Error?)->()) {
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print(err)
                completion(err)
                return
            }
            
            KindUserSettingsManager.loggedUserName = String(email.split(separator: "@").first ?? "")
            KindUserSettingsManager.userFields[UserFieldTitle.name.rawValue] = KindUserSettingsManager.loggedUserName!
            KindUserSettingsManager.userFields[UserFieldTitle.email.rawValue] = email
            KindUserSettingsManager.updateUserSettings()
            completion(nil)
            
        }
    }
}

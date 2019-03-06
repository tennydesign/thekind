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
import GoogleSignIn
    //HERE: IT is loading the first TALK twice!!

class HandleLoginWithFirestore {
    //LOGIN WITH FIREBASR
    
    func loginWithEmailAndPassword(_ email: String, _ password: String, completion: @escaping (Error?)->()) {
        // Will try to sign in  user.
        Auth.auth().signIn(withEmail: email, password: password, completion: { (res, err) in
            if let err = err {
                completion(err)
                return
            }
            
            KindUserSettingsManager.sharedInstance.initializeUserFields(email: email)
//
//            KindUserSettingsManager.sharedInstance.loggedUserName = String(email.split(separator: "@").first ?? "")
//           KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.name.rawValue] = KindUserSettingsManager.sharedInstance.loggedUserName!
//            KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.email.rawValue] = email
//            //This update creates the user if its an old keychain entry without a real user in the system (like the test dummys)
//            KindUserSettingsManager.sharedInstance.updateUserSettings(completion: nil)
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
            
            KindUserSettingsManager.sharedInstance.initializeUserFields(email: email)
//            KindUserSettingsManager.sharedInstance.loggedUserName = String(email.split(separator: "@").first ?? "")
//
//            KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.name.rawValue] = KindUserSettingsManager.sharedInstance.loggedUserName!
//            KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.email.rawValue] = email
//            KindUserSettingsManager.sharedInstance.updateUserSettings(completion: nil)
            completion(nil)
            
        }
    }

    func signInWithGoogle() {
        GIDSignIn.sharedInstance().signIn()
        
    }

    func signOutWithGoogle() {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("trying to sign out")
            GIDSignIn.sharedInstance().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }

}

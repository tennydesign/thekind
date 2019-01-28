//
//  LandingViewControllerViewModel.swift
//  TheKind
//
//  Created by Tenny on 09/12/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LandingViewControllerViewModel {
    
 //   var bindableToLoginView = Bindable<LoginView>()
    // a bind is like an estilingue. Client will fire, this will fire back to client .bind closure
    // after somework.
    var bindableIsFormValid = Bindable<Bool>()
    
    var password: String? {
        didSet {
            checkFormValidity()
        }
    }
    
    var email: String? {
        didSet {
            checkFormValidity()
        }
    }
    
    func checkFormValidity() {

        let isFormValid = password?.isEmpty == false
            && email?.isEmpty == false && email?.isEmail() == true
        bindableIsFormValid.value = isFormValid
    }
    
    
    func loginWithEmailAndPassword(_ email: String, _ password: String, completion: @escaping (Error?)->()) {
        // Will try to sign in  user.
        Auth.auth().signIn(withEmail: email, password: password, completion: { (res, err) in
            if let err = err {
                completion(err)
                return
            }
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
            completion(nil)
                
            // ADD CODE TO SETUP NEW USER IN THE DATABASE HERE.
        
            
        }
    }
    
}

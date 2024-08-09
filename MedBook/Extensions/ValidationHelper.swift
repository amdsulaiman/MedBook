//
//  ValidationHelper.swift
//  MedBook
//
//  Created by Mohammed Sulaiman on 08/08/24.
//

import Foundation
import UIKit

struct ValidationHelper {

    static func validatePassword(_ password: String) -> String? {
        if password.count < 8 {
            return Constants.StringConstants.conditionText1
        }
        if !password.contains(where: { $0.isUppercase }) {
            return Constants.StringConstants.conditionText2
        }
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()_+=[]|{};:'\",.<>?/\\`~-")
        if password.rangeOfCharacter(from: specialCharacterSet) == nil {
            return Constants.StringConstants.conditionText3
        }
        return nil
    }
    
    static func moveToDashboard() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                let story = UIStoryboard(name: "Main", bundle: nil)
                let vc = story.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
                UserDefaults.standard.set(true, forKey: "ISLOGGEDIN")
                window.rootViewController = vc
                window.makeKeyAndVisible()
            }
        }
        
    }

    static func getCurrentUserID() -> String {
        return UserDefaults.standard.string(forKey: "UserID") ?? ""
    }
    
}

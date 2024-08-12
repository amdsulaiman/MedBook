//
//  Theme.swift
//  MedBook
//
//  Created by Mohammed Sulaiman on 12/08/24.
//

import Foundation
import UIKit

/** Use this to modify themed colors.
 */
enum Theme: Int {
    case light, dark
    
    private enum Keys {
        static let currentTheme = "CurrentTheme"
    }
    
    static var current: Theme {
        let storedTheme = UserDefaults.standard.integer(forKey: Keys.currentTheme)
        return Theme(rawValue: storedTheme) ?? .light
    }
    
    func apply(){
        UserDefaults.standard.set(rawValue, forKey: Keys.currentTheme)
        UINavigationBar.appearance().tintColor = standardTintColor
        UINavigationBar.appearance().barTintColor = viewControllerBackgroundColor
    }
    
    
    var titleTextColor: UIColor {
        switch self {
        case .light:
            return UIColor.black
        case .dark:
            return UIColor.white
        }
    }
    
    var standardBackgroundColor: UIColor {
        switch self {
        case .light:
            return UIColor.white
        case .dark:
            return UIColor.systemGray4
        }
    }
    var standardTintColor:UIColor {
        switch self {
        case .light:
            return UIColor.black
        case .dark:
            return UIColor.white
        }
    }
    

    
    var viewControllerBackgroundColor: UIColor {
        switch self{
        case .light:
            return UIColor(red: 235.0 / 255.0, green: 235.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0)
        case .dark:
            return UIColor.black
        }
    }
    
    var buttonBackgroundColor: UIColor {
        switch self{
        case .light:
            return UIColor.white
        case .dark:
            return UIColor.systemGray4
        }
    }
    
    var buttonTextBackgroundColor: UIColor {
        switch self{
        case .light:
            return UIColor.black
        case .dark:
            return UIColor.white
        }
    }
    
}


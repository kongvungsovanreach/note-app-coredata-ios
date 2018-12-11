//
//  LanguageManagement.swift
//  CoreDataHomeworkNote
//
//  Created by Kong Vungsovanreach on 12/11/18.
//  Copyright © 2018 Kong Vungsovanreach. All rights reserved.
//

import Foundation
class LanguageManagement {
    static var shared = LanguageManagement()
    var language : String {
        get {
            if let userlang = UserDefaults.standard.string(forKey: "languageCode"){
                return userlang
            }else {
                return "en"
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "languageCode")
        }
    }
}
extension String {
    var localized : String {
        get {
            let path = Bundle.main.path(forResource: LanguageManagement.shared.language, ofType: "lproj")
            let bundle = Bundle(path: path!)
            let lang = bundle?.localizedString(forKey: self, value: nil, table: nil)
            return lang!
        }
    }
}

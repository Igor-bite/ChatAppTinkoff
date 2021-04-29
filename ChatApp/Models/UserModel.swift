//
//  UserModel.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 25.03.2021.
//

import Foundation
import UIKit

class User: Codable {
    private var name: String?
    private var description: String?
    private var prefersGeneratedAvatar: Bool
    var isOnline: Bool
    private var theme: String = Theme.classic.rawValue

    init(name: String, description: String?, isOnline: Bool?) {
        self.name = name
        self.description = description
        self.prefersGeneratedAvatar = false
        if let isOnline = isOnline {
            self.isOnline = isOnline
        } else {
            self.isOnline = false
        }
    }

    init(name: String, description: String?, isOnline: Bool?, prefersGeneratedAvatar: Bool) {
        self.name = name
        self.description = description
        self.prefersGeneratedAvatar = prefersGeneratedAvatar
        if let isOnline = isOnline {
            self.isOnline = isOnline
        } else {
            self.isOnline = false
        }
    }

    init(name: String, description: String?, isOnline: Bool?, prefersGeneratedAvatar: Bool, theme: String) {
        self.name = name
        self.description = description
        self.prefersGeneratedAvatar = prefersGeneratedAvatar
        self.theme = theme
        if let isOnline = isOnline {
            self.isOnline = isOnline
        } else {
            self.isOnline = false
        }
    }

    func getName() -> String? {
        return name
    }

    func getDescription() -> String? {
        return description
    }

    func getPrefersGeneratedAvatar() -> Bool {
        return self.prefersGeneratedAvatar
    }

    func getThemeRawValue() -> String {
        return self.theme
    }

    func changeUserTheme(theme: String) {
        assert(Theme(rawValue: theme) != nil, "Something wrong with themeRawValue")
        self.theme = theme
    }

    func userWentOnline() {
        isOnline = true
    }

    func userWentOffline() {
        isOnline = false
    }
    
    static func getUnknownUserName() -> String {
        return "Unknown User"
    }
    
    func isEqual(to user: User) -> Bool {
        if user.getPrefersGeneratedAvatar() == self.prefersGeneratedAvatar &&
            user.getName() == self.name &&
            user.getDescription() == self.description {
            return true
        }
        return false
    }
}

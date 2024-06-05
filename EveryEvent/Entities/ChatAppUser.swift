//
//  ChatAppUser.swift
//  EveryEvent
//
//  Created by S3lfcode on 03.05.2024.
//

import Foundation

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let password: String
}

extension ChatAppUser {
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profileImageFilename: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
    var profileImagePath: String {
        return "images/" + profileImageFilename
    }
}

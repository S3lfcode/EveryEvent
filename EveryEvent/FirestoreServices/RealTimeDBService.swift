//
//  RealTimeDBService.swift
//  EveryEvent
//
//  Created by S3lfcode on 02.05.2024.
//

import Foundation
import FirebaseDatabase

final class DatabasRealTimeDBService {
    static let shared = DatabasRealTimeDBService()
    
    private let db = Database.database().reference()
    
    public func test() {
        db.child("foo").setValue(["something": true])
    }
}

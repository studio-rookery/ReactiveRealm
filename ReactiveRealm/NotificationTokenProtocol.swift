//
//  NotificationTokenProtocol.swift
//  ReactiveRealm
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import RealmSwift

/// `NotificationTokenProtocol` is a protocol that abstracts `NotificationToken` for testing.
public protocol NotificationTokenProtocol {
    
    func invalidate() -> Bool
}

extension NotificationToken: NotificationTokenProtocol {
    
}

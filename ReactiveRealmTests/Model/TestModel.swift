//
//  TestModel.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
@testable import ReactiveRealm

enum TestError: Error {
    case test
}

final class MockToken: NotificationTokenProtocol {
    
    private(set) var isInvalidated = false
    
    func invalidate() {
        isInvalidated = true
    }
}

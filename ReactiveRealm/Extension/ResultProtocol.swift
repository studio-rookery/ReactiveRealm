//
//  ResultProtocol.swift
//  ReactiveRealm
//
//  Created by masaki on 2020/06/28.
//  Copyright © 2020 ReactiveRealm. All rights reserved.
//

import Foundation

protocol ResultProtocol {
    associatedtype Success
    associatedtype Failure
    
    var value: Success? { get }
}

extension Result {
    
    var value: Value? {
        switch self {
        case .success(let value):
            return value
        default:
            return nil
        }
    }
    
    var error: Failure? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}

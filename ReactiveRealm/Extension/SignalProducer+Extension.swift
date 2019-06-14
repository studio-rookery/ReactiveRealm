//
//  SignalProducer+Extension.swift
//  ReactiveRealm
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import ReactiveSwift

extension SignalProducer {
    
    func ignoreError() -> SignalProducer<Value, Never> {
        return flatMapError { _ in .empty }
    }
    
    func mapError(to value: Value) -> SignalProducer<Value, Never> {
        return flatMapError { _ in SignalProducer<Value, Never>(value: value) }
    }
}

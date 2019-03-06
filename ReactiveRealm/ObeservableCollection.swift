//
//  CollectionChangeObservable.swift
//  ReactiveRealm
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift
import RealmSwift

public protocol ObeservableCollection: ReactiveExtensionsProvider {
    
    associatedtype NotificationTokenType: NotificationTokenProtocol
    
    func observe(_ block: @escaping (RealmCollectionChange<Self>) -> ()) -> NotificationTokenType
}

extension Results: ObeservableCollection {
    
}

extension List: ObeservableCollection {
    
}

extension LinkingObjects: ObeservableCollection {
    
}

extension AnyRealmCollection: ObeservableCollection {
    
}

// MARK: -

public extension Reactive where Base: ObeservableCollection {
    
    var producer: SignalProducer<Base, AnyError> {
        return SignalProducer<Base, AnyError> { observer, lifetime in
            
            observer.send(value: self.base)
            
            let token = self.base.observe { change in
                switch change {
                case .initial:
                    break
                case .update(let collection, _, _, _):
                    observer.send(value: collection)
                case .error(let error):
                    observer.send(error: AnyError(error))
                }
            }
            
            lifetime.observeEnded {
                token.invalidate()
            }
        }
    }
    
    var property: ReactiveSwift.Property<Base> {
        return Property(initial: base, then: producer.ignoreError())
    }
}

public extension Reactive where Base: ObeservableCollection & Collection, Base.Element: Object {
    
    func first(or default: @autoclosure @escaping () -> Base.Element = Base.Element()) -> ReactiveSwift.Property<Base.Element> {
        return property.map { $0.first ?? `default`() }
    }
}

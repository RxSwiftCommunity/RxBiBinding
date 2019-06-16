//
//  AnyObservableType.swift
//  RxBiBinding
//
//  Created by Александр Макушкин on 21.08.2018.
//  Copyright (c) RxSwiftCommunity

import Foundation
import RxSwift

class AnyObservableType<Element>: ObservableType {
    typealias E = Element
    
    private let _subscribe: (AnyObserver<E>) -> Disposable
    
    init<O>(_ observer: O) where O : ObservableType, O.Element == Element {
        self._subscribe = observer.subscribe(_:)
    }
    
    func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, O.Element == Element {
        return self._subscribe(observer.asObserver())
    }
}

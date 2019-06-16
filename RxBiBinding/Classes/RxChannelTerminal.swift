//
//  RxChannelTerminal.swift
//  RxBiBinding
//
//  Created by Александр Макушкин on 22.08.2018.
//  Copyright (c) RxSwiftCommunity

import Foundation
import RxSwift
import RxCocoa

class RxChannelTerminal<E>: NSObject {
    typealias Element = E
    
    fileprivate private(set) var values: AnyObservableType<E>?
    fileprivate private(set) var otherTerminal: AnyObserver<E>?
    
    convenience init(withValues values: AnyObservableType<E>, otherTerminal: AnyObserver<E>) {
        self.init()
        
        self.values = values
        self.otherTerminal = otherTerminal
    }
}

extension RxChannelTerminal: ObserverType {
    func on(_ event: Event<E>) {
        self.otherTerminal?.on(event)
    }
}

extension RxChannelTerminal: ObservableType {
    func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, RxChannelTerminal.Element == O.Element {
        return self.values?.subscribe(observer) ?? Disposables.create()
    }
}

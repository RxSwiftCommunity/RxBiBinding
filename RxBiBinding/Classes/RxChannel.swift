//
//  RxChannel.swift
//  RxBiBinding
//
//  Created by Александр Макушкин on 22.08.2018.
//  Copyright (c) RxSwiftCommunity

import Foundation

import RxSwift
import RxCocoa

infix operator <->

public func <-><E>(left: ControlProperty<E>, right: ControlProperty<E>) -> Disposable {
    let leftChannel = RxChannel<E>(withProperty: left)
    let rightChannel = RxChannel<E>.init(withProperty: right)
    
    return CompositeDisposable.init(leftChannel, rightChannel, leftChannel & rightChannel)
}

public func <-><E>(left: BehaviorRelay<E>, right: BehaviorRelay<E>) -> Disposable {
    let leftChannel = RxChannel<E>(withBehaviorRelay: left)
    let rightChannel = RxChannel<E>.init(withBehaviorRelay: right)
    
    return CompositeDisposable.init(leftChannel, rightChannel, leftChannel & rightChannel)
}

public func <-><E>(left: ControlProperty<E>, right: BehaviorRelay<E>) -> Disposable {
    let leftChannel = RxChannel<E>(withProperty: left)
    let rightChannel = RxChannel<E>.init(withBehaviorRelay: right)
    
    return CompositeDisposable.init(leftChannel, rightChannel, leftChannel & rightChannel)
}

//MARK: - Core RxChannel
class RxChannel<E>: NSObject {
    var leadingTerminal: RxChannelTerminal<E>?
    var followingTerminal: RxChannelTerminal<E>?
    
    private var isSkippingNextUpdate = false
    private var keyPath: String?
    private var target: E?
    
    private let disposeBag = DisposeBag()
    
    override init() {
        let leadingSubject = ReplaySubject<E>.create(bufferSize: 0)
        let followingSubject = ReplaySubject<E>.create(bufferSize: 1)
        
        leadingSubject
            .ignoreElements()
            .subscribe(onCompleted: {
                followingSubject.onCompleted()
            }) { error in
                followingSubject.onError(error)
            }
            .disposed(by: self.disposeBag)
        
        followingSubject
            .ignoreElements()
            .subscribe(onCompleted: {
                leadingSubject.onCompleted()
            }) { error in
                leadingSubject.onError(error)
            }
            .disposed(by: self.disposeBag)
        
        self.leadingTerminal = RxChannelTerminal<E>.init(withValues: AnyObservableType<E>(leadingSubject),
                                                         otherTerminal: AnyObserver<E>(followingSubject))
        self.followingTerminal = RxChannelTerminal<E>.init(withValues: AnyObservableType<E>(followingSubject),
                                                           otherTerminal: AnyObserver<E>(leadingSubject))
    }
}

//MARK: - Init with ControlProperty RxChannel
extension RxChannel {
    convenience init(withProperty property: ControlProperty<E>) {
        self.init()
        
        _ = property.do { [weak self] in
            self?.leadingTerminal?.onCompleted()
        }
        
        guard let gLeaTer = self.leadingTerminal else {
            return
        }
        
        property
            .subscribe(onNext: { [weak self] value in
                if self?.isSkippingNextUpdate == true {
                    self?.isSkippingNextUpdate = false
                    
                    return;
                }
                
                gLeaTer.onNext(value)
            })
            .disposed(by: self.disposeBag)
        
        gLeaTer
            .subscribe(onNext: { value in
                property.onNext(value)
            })
            .disposed(by: self.disposeBag)
    }
}

//MARK: - Init with BehaviorRelay RxChannel
extension RxChannel {
    convenience init(withBehaviorRelay relay: BehaviorRelay<E>) {
        self.init()
        
        _ = relay
            .asObservable()
            .do { [weak self] in
                self?.leadingTerminal?.onCompleted()
        }
        
        guard let gLeaTer = self.leadingTerminal else {
            return
        }
        
        relay
            .asObservable()
            .subscribe(onNext: { [weak self] value in
                if self?.isSkippingNextUpdate == true {
                    self?.isSkippingNextUpdate = false
                    
                    return;
                }
                
                gLeaTer.onNext(value)
            })
            .disposed(by: self.disposeBag)
        
        gLeaTer
            .subscribe(onNext: { [weak self] value in
                self?.isSkippingNextUpdate = true
                
                relay.accept(value)
            })
            .disposed(by: self.disposeBag)
    }
}


//MARK: - Operator Overload RxChannel
extension RxChannel {
    fileprivate static func &(left: RxChannel<E>, right: RxChannel<E>) -> Disposable {
        guard let leftFolTer = left.followingTerminal, let rightFolTer = right.followingTerminal else {
            return Disposables.create()
        }
        
        let r = rightFolTer.bind(to: leftFolTer)
        let l = leftFolTer.skip(1).bind(to: rightFolTer)
        
        return CompositeDisposable.init(r, l)
    }
}

//MARK: - Disposable RxChannel
extension RxChannel: Disposable {
    func dispose() {}
}

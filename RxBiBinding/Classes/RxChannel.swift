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

public func <->(left: (obj: NSObject, keyPath: String), right: (obj: NSObject, keyPath: String)) -> Disposable {
    let leftChannel = RxChannel<NSObject>.init(withTarget: left.obj, keyPath: left.keyPath)
    let rightChannel = RxChannel<NSObject>.init(withTarget: right.obj, keyPath: right.keyPath)
    
    return CompositeDisposable.init(leftChannel, rightChannel, leftChannel & rightChannel)
}

//MARK: - Core RxChannel

class RxChannel<E>: NSObject {
    var leadingTerminal: RxChannelTerminal<E>?
    var followingTerminal: RxChannelTerminal<E>?
    
    private var keyPath: String?
    private var target: E?
    private let kRxChannelDataDictionaryKey = "RxChannelDataDictionaryKey"
    
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
                guard let wSelf = self else {
                    return
                }
                
                if wSelf.currentThreadData()?.ignoreNextUpdate == true
                    && wSelf.currentThreadData()?.owner == Unmanaged.passUnretained(wSelf).toOpaque() {
                    wSelf.destroyCurrentThreadData()
                    
                    return;
                }
                
                gLeaTer.onNext(value)
            })
            .disposed(by: self.disposeBag)
        
        gLeaTer
            .subscribe(onNext: { [weak self] value in
                self?.createCurrentThreadData()
                self?.currentThreadData()?.ignoreNextUpdate = true
                
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
                guard let wSelf = self else {
                    return
                }
                
                if wSelf.currentThreadData()?.ignoreNextUpdate == true
                    && wSelf.currentThreadData()?.owner == Unmanaged.passUnretained(wSelf).toOpaque() {
                    wSelf.destroyCurrentThreadData()
                    
                    return;
                }
                
                gLeaTer.onNext(value)
            })
            .disposed(by: self.disposeBag)
        
        gLeaTer
            .subscribe(onNext: { [weak self] value in
                self?.createCurrentThreadData()
                self?.currentThreadData()?.ignoreNextUpdate = true
                
                relay.accept(value)
            })
            .disposed(by: self.disposeBag)
    }
}

//MARK: - Init with NSObject RxChannel

extension RxChannel {
    convenience init(withTarget target: E, keyPath: String) {
        self.init()
        
        self.target = target
        self.keyPath = keyPath
        
        guard let gLeadingTerminal = self.leadingTerminal else {
            return
        }
        
        guard let oTarget = self.target as? NSObject, let gKeyPath = self.keyPath else {
            return
        }
        
        let observer = oTarget.rx.observe(E.self, gKeyPath, options: [.new, .initial], retainSelf: true)
        
        let observerDisposable = observer
            .subscribe(onNext: { [weak self] value in
                guard let wSelf = self else {
                    return
                }
                if wSelf.currentThreadData()?.ignoreNextUpdate == true
                    && wSelf.currentThreadData()?.owner == Unmanaged.passUnretained(wSelf).toOpaque() {
                    wSelf.destroyCurrentThreadData()
                    
                    return
                }
                
                guard let v = value else {
                    return
                }
                gLeadingTerminal.onNext(v)
            })
        observerDisposable.disposed(by: self.disposeBag)
        
        let keyPathByDeletingLastKeyPathComponent = gKeyPath.keyPathByDeletingLastKeyPathComponent() ?? ""
        let keyPathComponents = gKeyPath.keyPathComponents()
        let keyPathComponentsCount = keyPathComponents?.count ?? 0
        let lastKeyPathComponent = keyPathComponents?.last ?? ""
        
        _ = gLeadingTerminal
            .do(onError: { _ in
                observerDisposable.dispose()
            }, onCompleted: {
                observerDisposable.dispose()
            })
        
        gLeadingTerminal
            .subscribe(onNext: { [weak self] value in
                let object = (keyPathComponentsCount > 1 ? oTarget.value(forKeyPath: keyPathByDeletingLastKeyPathComponent) : self?.target) as? NSObject
                if object == nil {
                    return
                }
                
                self?.createCurrentThreadData()
                self?.currentThreadData()?.ignoreNextUpdate = true
                
                object?.setValue(value, forKey: lastKeyPathComponent)
            })
            .disposed(by: self.disposeBag)
        
        oTarget.rx
            .deallocating
            .subscribe(onNext: { [weak self] in
                self?.leadingTerminal?.onCompleted()
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

//MARK: - Thread Data RxChannel

extension RxChannel {
    private func currentThreadData() -> RxChannelData<E>? {
        let dataArray: Array<RxChannelData<E>>? = Thread.current.threadDictionary.value(forKey: self.kRxChannelDataDictionaryKey) as? Array<RxChannelData<E>>
        guard let array = dataArray else {
            return nil
        }
        
        for data in array {
            let pSelf = Unmanaged.passUnretained(self).toOpaque()
            if data.owner! == pSelf {
                return data
            }
        }
        
        return nil
    }
    
    private func createCurrentThreadData() {
        var dataArray: Array<RxChannelData<E>>? = Thread.current.threadDictionary.value(forKey: self.kRxChannelDataDictionaryKey) as? Array<RxChannelData<E>>
        
        if dataArray == nil {
            dataArray = Array<RxChannelData<E>>()
            dataArray?.append(RxChannelData<E>.dataForChannel(channel: self))
            
            Thread.current.threadDictionary[self.kRxChannelDataDictionaryKey] = dataArray
            
            return
        }
        
        for data in dataArray! {
            let pSelf = Unmanaged.passUnretained(self).toOpaque()
            if data.owner! == pSelf {
                return
            }
        }
        
        dataArray?.append(RxChannelData.dataForChannel(channel: self))
        Thread.current.threadDictionary[self.kRxChannelDataDictionaryKey] = dataArray
    }
    
    private func destroyCurrentThreadData() {
        var dataArray: Array<RxChannelData<E>>? = Thread.current.threadDictionary.value(forKey: self.kRxChannelDataDictionaryKey) as? Array<RxChannelData<E>>
        let index = dataArray?.index(where: { data -> Bool in
            let pSelf = Unmanaged.passUnretained(self).toOpaque()
            return data.owner! == pSelf
        })
        
        if index != nil {
            dataArray?.remove(at: index!)
        }
        
        Thread.current.threadDictionary[self.kRxChannelDataDictionaryKey] = dataArray
    }
}

//MARK: - Disposable RxChannel

extension RxChannel: Disposable {
    func dispose() {
        print("RxChannel -> dispose")
    }
}

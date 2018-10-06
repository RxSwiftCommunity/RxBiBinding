//
//  RxChannelData.swift
//  RxBiBinding
//
//  Created by Александр Макушкин on 22.08.2018.
//  Copyright (c) RxSwiftCommunity

import Foundation

class RxChannelData<E> : NSObject {
    var ignoreNextUpdate = false
    var owner: UnsafeMutableRawPointer?
    
    static func dataForChannel(channel: RxChannel<E>) -> RxChannelData {
        let data: RxChannelData = RxChannelData<E>.init()
        data.owner = Unmanaged.passUnretained(channel).toOpaque()
        
        return data
    }
}


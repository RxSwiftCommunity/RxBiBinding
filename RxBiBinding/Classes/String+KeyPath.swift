//
//  String+KeyPath.swift
//  RxBiBinding
//
//  Created by Александр Макушкин on 22.08.2018.
//  Copyright (c) RxSwiftCommunity

import Foundation

extension String {
    func keyPathByDeletingLastKeyPathComponent() -> String? {
        let lastDotIndex = self.range(of: ".", options: .backwards, range: self.range(of: self), locale: nil)
        
        guard let range = lastDotIndex else {
            return nil
        }
        
        if range.isEmpty {
            return nil
        } else {
            return String(self[..<range.upperBound].first!)
        }
    }
    
    func keyPathComponents() -> [String]? {
        if self.count == 0 {
            return nil
        } else {
            return self.components(separatedBy: ".")
        }
    }
}


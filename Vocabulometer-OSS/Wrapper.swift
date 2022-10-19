//
//  Wrapper.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/10/12.
//

import Foundation

class Wrapper<Wrapped> {
    var value: Wrapped
    init(_ value: Wrapped) { self.value = value }
}

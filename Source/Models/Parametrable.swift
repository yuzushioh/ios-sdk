//
//  Parametrable.swift
//  OmiseGO
//
//  Created by yuzushioh on 2018/05/07.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

protocol Parametrable: Encodable {}

extension Parametrable {
    func encodedPayload() throws -> Data {
        return try serialize(self)
    }
}

//
//  MQTTDecoder.swift
//  mqtt-nio-demo
//
//  Created by User on 27/06/2022.
//

import Foundation

class MQTTDecoder {
    static var `default` = MQTTDecoder()
    
    func canDecode(message: Any) -> Bool {
        return true
    }
    
    func decode(message: MQTTManagerMessage) -> Any {
        return ""
    }
}

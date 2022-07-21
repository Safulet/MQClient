//
//  MQTTError.swift
//  mqtt-nio-demo
//
//  Created by User on 27/06/2022.
//

import Foundation

enum ConnectionError: Error {
    case connectFailed
    case reconnectFailed
    case disconnectFailed
    case unauthorized
}

enum TopicError: Error {
    case subscribeError
}

struct MessageError: Error {
    
}

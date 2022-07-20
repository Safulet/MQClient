//
//  MQTTManagerV2.swift
//  mqtt-nio-demo
//
//  Created by User on 27/06/2022.
//

import Foundation
import NIOSSL
#if canImport(Combine)
import Combine
#endif


// TODO: Topic 管理 - Alex
// TODO: 消息订阅机制 topic, 多 subscriptions  -  simon alex
// TODO: 重连 手动触发 / 切换域名
// TODO: Logger DI
// TODO: 依赖管理
// TODO: mqtt solution review

// TODO:
//Crypto
//SwiftUI
//MVVM-C
//试水

// TSS: Jerry Simon backup recover


protocol Loggable {
    
}

struct LoggerBuilder {
    
}


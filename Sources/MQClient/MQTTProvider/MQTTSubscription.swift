//
//  MQTTSubscription.swift
//  mqtt-nio-demo
//
//  Created by User on 29/06/2022.
//

import Foundation
import NIO
#if canImport(Combine)
import Combine
#endif

public class MQTTSubscription: NSObject {
    
    var topic: String = ""
    var decoder: MQTTDecoder = .default
    weak var client: MQTTMDClient?
    
    var receiveMessageCallback: ((MQTTManagerMessage) -> Void)?
    
    
    // - MARK: combine
    #if canImport(Combine)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public var messagePublisher: AnyPublisher<MQTTManagerMessage, Never> {
        client?.messagePublisher ?? Empty(completeImmediately: false).eraseToAnyPublisher()
    }
    #endif
    
    // - MARK: publish
    func publish(
        _ payload: String,
        to topic: String,
        qos: MQTTManagerQoS,
        retain: Bool
    ) {
        client?.publish(payload, to: topic, qos: qos, retain: retain, callback: { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                print(error)
            }
        })
    }
    
    func publish(
        _ payload: MQTTManagerPayload,
        to topic: String,
        qos: MQTTManagerQoS,
        retain: Bool
    ) {
        client?.publish(payload, to: topic, qos: qos, retain: retain, callback: { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                print(error)
            }
        })
    }
    
    // - MARK: subscribe
    func subscribe(
        callback: @escaping (Result<MQTTManagerSingleSubscribeResponse, Error>) -> Void) {
            client?.subscribe(to: self, callback: callback)
        }
    
    func unsubscribe(callback: @escaping (Result<MQTTManagerSingleUnsubscribeResponse, Error>) -> Void) {
        client?.unsubscribe(from: self, callback: callback)
    }
    
    func didReceiveMessage(_ message: MQTTManagerMessage) {
        receiveMessageCallback?(message)
    }
}


/*
 MQTT 底层框架可替换
 MQTT 支持多订阅
 MQTT 解析
 MQTT 支持多架构
 */



// 部分场景交互体验较差，断网重连， 前后台切换， 第一次启动
// Ack包 没有在处理message之后发， 而是第一时间就发出去了 - 方案： 处理失败之后缓存message   ？
// 如果是多个页面订阅一个topic， Message Publisher 需要集中解析然后再分发
// trace ID
// Logger upload / share

//
//  MQTTClient+Extensions.swift
//  mqtt-nio-demo
//
//  Created by 仇弘扬 on 2022/5/24.
//

import Foundation
import MQTTNIO
import NIO
import Crypto


public typealias MQSuback = MQTTSuback
public typealias MQPublishInfo = MQTTPublishInfo

extension MQTTClient: MQTTClientProtocol {

    func connect(callback: @escaping (Result<Bool, Error>) -> Void) {
        connect(cleanSession: false).whenComplete(callback)
    }
    
    func disconnect(callback: @escaping (Result<Void, Error>) -> Void) {
        disconnect().whenComplete(callback)
    }
    func flushConnect(callback: @escaping (Result<Bool, Error>) -> Void) {
        disconnect().whenComplete { [weak self] result in
            switch result {
            case .success:
                self?.connect(cleanSession: false).whenComplete(callback)
            case .failure:
                break
            }
        }
    }
    
    func publish(
        topic: String,
        typeId: String,
        isQos2: Bool,
        isRetained: Bool,
        data: String,
        callback: @escaping (Result<Void, Error>) -> Void
    ) {
        publish(to: topic, payload: ByteBuffer(string: data), qos: isQos2 ? .exactlyOnce : .atLeastOnce).whenComplete(callback)
    }

    func subscribe(topic: String, callback: @escaping (Result<MQSuback, Error>) -> Void) {
        subscribe(to: [MQTTSubscribeInfo(topicFilter: topic, qos: .atLeastOnce)]).whenComplete(callback)
    }
    
    func unsubscribe(topicId: String, callback: @escaping (Result<Void, Error>) -> Void) {
        unsubscribe(from: [topicId]).whenComplete(callback)
    }
    
    func createCsr(privateKeyPem: String, dnsName: String) throws -> String {
        return ""
    }
    
    func verifyCert(rootCA: String, privateKeyPem: String, dnsName: String) throws {

    }
    
}




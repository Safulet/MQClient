//
//  MQTTClient+Extensions.swift
//  mqtt-nio-demo
//
//  Created by 仇弘扬 on 2022/5/24.
//

import Foundation
import MQTTNIO
import NIO

extension MQTTClient: MQTTClientProtocol {
    
    
    func connect() {
        self.connect().whenComplete{_ in }
    }
    
    func reconnect() {
        _ = reconnect(sendWillMessage: false)
    }
    
    func disconnect() {
        _ = disconnect(sendWillMessage: false)
    }
    
    func setupConnectionCallbacks(
        onConnected: @escaping (MQTTManagerConnectResponse) -> (),
        onReconnecting: @escaping () -> (),
        onDisconnected: @escaping (MQTTDisconnectReason) -> Void,
        onConnectionFailure: @escaping (Error) -> (Void))
    {
        whenConnected(onConnected)
        whenReconnecting(onReconnecting)
        whenDisconnected(onDisconnected)
        whenConnectionFailure(onConnectionFailure)
    }

    func publish(
        _ payload: String,
        to topic: String,
        qos: MQTTManagerQoS,
        retain: Bool,
        callback: @escaping (Result<Void, Error>) -> Void
    ) {
        publish(payload, to: topic, qos: qos, retain: retain).whenComplete(callback)
    }
    
    func publish(
        _ payload: MQTTManagerPayload,
        to topic: String,
        qos: MQTTManagerQoS,
        retain: Bool,
        callback: @escaping (Result<Void, Error>) -> Void
    ) {
        publish(payload, to: topic, qos: qos, retain: retain).whenComplete(callback)
    }
    
    func subscribe(
        to topic: String,
        callback: @escaping (Result<MQTTManagerSingleSubscribeResponse, Error>) -> Void
        ) {
        subscribe(to: topic, qos: .exactlyOnce).whenComplete(callback)
    }
    
    func unsubscribe(from topic: String, callback: @escaping (Result<MQTTManagerSingleUnsubscribeResponse, Error>) -> Void) {
        unsubscribe(from: topic).whenComplete(callback)
    }
    
    func whenReceiveMessage(_ callback: @escaping (MQTTManagerMessage) -> Void) {
        whenMessage(callback)
    }
}




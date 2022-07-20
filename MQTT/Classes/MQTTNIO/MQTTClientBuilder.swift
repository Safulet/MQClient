//
//  ClientProtocol.swift
//  mqtt-nio-demo
//
//  Created by User on 27/06/2022.
//

import Foundation
import MQTTNIO
import NIO

// TODO: need to convert to native structure
public typealias MQTTManagerDisconnectReason = MQTTDisconnectReason
public typealias MQTTManagerMessage = MQTTMessage
public typealias MQTTManagerPublishError = MQTTPublishError
public typealias MQTTManagerSingleUnsubscribeResponse = MQTTSingleUnsubscribeResponse
public typealias MQTTManagerSingleSubscribeResponse = MQTTSingleSubscribeResponse
public typealias MQTTManagerPayload = MQTTPayload
public typealias MQTTManagerConnectResponse = MQTTConnectResponse
public typealias MQTTManagerQoS = MQTTQoS
public typealias MQTTManagerCancellable = MQTTCancellable

class MQTTClientBuilder {
    static func buildClient(endPoint: MQTTEndpoint, clientID: String) throws -> MQTTClientProtocol {
        var configuration = MQTTConfiguration(
            target: .host(endPoint.host, port: endPoint.portInt),
            tls: try TLSConfigurationBuilder.buildDemoTLSConfiguration(endPoint),
            protocolVersion: endPoint.protocolVersion.mqttProtocolVersion,
            clientId: clientID
        )
        if let credentials = endPoint.credential {
            configuration.credentials = .init(credentials: credentials)
        }
        return MQTTClient(configuration: configuration)
    }
}

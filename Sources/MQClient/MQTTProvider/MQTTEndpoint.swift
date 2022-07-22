//
//  MQTTClientModel.swift
//  mqtt-nio-demo
//
//  Created by 仇弘扬 on 2022/5/22.
//

import Foundation

public struct MQTTEndpoint {

    enum ProtocolVersion {
        case version3_1_1
        case version5
    }

    public var host: String
    public var port: UInt32
    public var credential: MQTTCredentials?
    public var protocolVersion: ProtocolVersion
    public var secretKeys: SecretKeys?
}

extension MQTTEndpoint {
    public var portInt: Int {
        return Int(port)
    }
}

public extension MQTTEndpoint {
    public static let safuletQA: MQTTEndpoint = .init(
        host: "mqtt.ff6160c527b.com",
        port: 443,
        credential: .init(
            username: "vernemq",
            password: "vernemq"
        ),
        protocolVersion: .version3_1_1,
        secretKeys: .safuletQA
    )

    public static let safuletQA2: MQTTEndpoint = .init(
        host: "mqtt.ff6160c527b.com",
        port: 443,
        credential: .init(
            username: "vernemq_server",
            password: "vernemq_server"
        ),
        protocolVersion: .version3_1_1,
        secretKeys: .safuletQA
    )

    public static let tssSafulet: MQTTEndpoint = .init(
        host: "safulet-vmq.gywt73aq.xyz",
        port: 443,
        credential: .init(
            username: "USERNAME11",
            password: "PASSWORD"
        ),
        protocolVersion: .version3_1_1,
        secretKeys: SecretKeys(
            host: "safulet-vmq.gywt73aq.xyz",
            myCertText: Secrets.myCertText,
            caCertText: Secrets.caCertText,
            privateKeyText: Secrets.privateKeyText
        )
    )
}

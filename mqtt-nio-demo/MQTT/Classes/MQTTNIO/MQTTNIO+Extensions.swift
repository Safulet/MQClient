//
//  MQTTNIO+Extensions.swift
//  mqtt-nio-demo
//
//  Created by 仇弘扬 on 2022/5/22.
//

import Foundation
import MQTTNIO

extension MQTTCredentials {
    var nioCredentials: MQTTConfiguration.Credentials {
        return .init(username: username, password: password)
    }
}

extension MQTTConfiguration.Credentials {
    init(credentials: MQTTCredentials) {
        self.init(username: credentials.username, password: credentials.password)
    }
}

extension MQTTEndpoint.ProtocolVersion {
    var mqttProtocolVersion: MQTTProtocolVersion {
        switch self {
        case .version3_1_1:
            return .version3_1_1
        case .version5:
            return .version5
        }
    }
}

extension MQTTProtocolVersion {
    init?(_ version: MQTTEndpoint.ProtocolVersion) {
        switch version {
        case .version3_1_1:
            self.init(rawValue: MQTTProtocolVersion.version3_1_1.rawValue)
        case .version5:
            self.init(rawValue: MQTTProtocolVersion.version5.rawValue)
        }
    }
}

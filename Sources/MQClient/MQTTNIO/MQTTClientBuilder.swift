//
//  ClientProtocol.swift
//  mqtt-nio-demo
//
//  Created by User on 27/06/2022.
//

import Foundation
import MQTTNIO
import NIO
import NIOSSL

// TODO: need to convert to native structure
//public typealias MQDisconnectReason = MQTTDisconnectReason
//public typealias MQMessage = MQTTMessage
//public typealias MQPublishError = MQTTPublishError
//public typealias MQSingleUnsubscribeResponse = MQTTSingleUnsubscribeResponse
//public typealias MQSingleSubscribeResponse = MQTTSingleSubscribeResponse
//public typealias MQPayload = MQTTPayload
//public typealias MQConnectResponse = MQTTConnectResponse
//public typealias MQQoS = MQTTQoS
//public typealias MQCancellable = MQTTCancellable

class MQTTClientBuilder {
    static func buildClient(
        endPoint: String,
        port: Int?,
        clientId: String,
        userName: String? = nil,
        password: String? = nil,
        privateKeyPath: String,
        centificatePath: String,
        caCertificatePath: String
    ) throws -> MQTTClientProtocol {
        let rootCertificate = try NIOSSLCertificate.fromPEMFile(caCertificatePath)
        let myCertificate = try NIOSSLCertificate.fromPEMFile(centificatePath)
        let myPrivateKey = try NIOSSLPrivateKey(file: privateKeyPath, format: .pem)
    
        var tlsConfiguration: TLSConfiguration = TLSConfiguration.makeServerConfiguration(
            certificateChain: myCertificate.map { .certificate($0) },
            privateKey: .privateKey(myPrivateKey)
        )
        tlsConfiguration.trustRoots = .certificates(rootCertificate)
        let configurationType: MQTTClient.TLSConfigurationType? = .niossl(tlsConfiguration)
        
        let clientConfiguration: MQTTClient.Configuration = .init(
            timeout: .seconds(30),
            userName: userName,
            password: password,
            useSSL: true,
            tlsConfiguration: configurationType
        )
        let client = MQTTClient(
            host: endPoint,
            port: port,
            identifier: "SSLClient",
            eventLoopGroupProvider: .createNew,
            configuration: clientConfiguration
        )
        return client
    }
    
    static func buildClient(
        endPoint: String,
        port: Int?,
        clientId: String,
        userName: String? = nil,
        password: String? = nil,
        privateKey: String,
        certificate: String,
        caCertificate: String
    ) throws -> MQTTClientProtocol {
        let rootCertificate = try NIOSSLCertificate.fromPEMBytes([UInt8](caCertificate.utf8))
        let myCertificate = try NIOSSLCertificate.fromPEMBytes([UInt8](certificate.utf8))
        let myPrivateKey = try NIOSSLPrivateKey(bytes: [UInt8](privateKey.utf8), format: .pem)
        var tlsConfiguration: TLSConfiguration = TLSConfiguration.makeServerConfiguration(
            certificateChain: myCertificate.map { .certificate($0) },
            privateKey: .privateKey(myPrivateKey)
        )
        tlsConfiguration.trustRoots = .certificates(rootCertificate)
        let clientConfiguration: MQTTClient.Configuration = .init(
            timeout: .seconds(30),
            userName: userName,
            password: password,
            useSSL: true,
            tlsConfiguration: .niossl(tlsConfiguration)
        )
        let client = MQTTClient(
            host: endPoint,
            port: port,
            identifier: "SSLClient",
            eventLoopGroupProvider: .createNew,
            configuration: clientConfiguration
        )
        return client
    }
    
    static func buildClient(
        endPoint: String,
        port: Int?,
        clientId: String,
        password: String,
        caCertificate: String
    ) throws -> MQTTClientProtocol {
        let rootCertificate = try NIOSSLCertificate.fromPEMBytes([UInt8](caCertificate.utf8))
        var tlsConfiguration = TLSConfiguration.makeClientConfiguration()
        tlsConfiguration.trustRoots = .certificates(rootCertificate)
        
        let clientConfiguration: MQTTClient.Configuration = .init(
            timeout: .seconds(30),
            userName: clientId,
            password: password,
            useSSL: true,
            tlsConfiguration: .niossl(tlsConfiguration)
        )
        let client = MQTTClient(
            host: endPoint,
            port: port,
            identifier: "MySSLClient",
            eventLoopGroupProvider: .createNew,
            configuration: clientConfiguration
        )
        return client
    }
    

}

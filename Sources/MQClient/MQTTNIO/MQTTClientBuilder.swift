//
//  ClientProtocol.swift
//  mqtt-nio-demo
//
//  Created by User on 27/06/2022.
//

import Foundation
import MQTTNIO
import NIO
#if canImport(NIOSSL)
import NIOSSL
#endif
#if canImport(Network)
import Network
#endif
import SwCrypt

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
        #if canImport(Network)
        let certificates = try NIOSSLCertificate.fromPEMFile(caCertificatePath)
        let rootCertificate = try certificates.map { certificate -> SecCertificate in
            guard let certificate = SecCertificateCreateWithData(nil, Data(try certificate.toDERBytes()) as CFData) else { throw TSTLSConfiguration.Error.invalidData }
            return certificate
        }
        
        let content = try String(contentsOfFile: privateKeyPath)
        let data = try SwKeyConvert.PrivateKey.pemToPKCS1DER(content)
        let options: [String: String] = [:]
        var rawItems: CFArray?
        guard SecPKCS12Import(data as CFData, options as CFDictionary, &rawItems) == errSecSuccess else {
            throw TSTLSConfiguration.Error.invalidData
        }
        let items = rawItems! as! [[String: Any]]
        guard let firstItem = items.first,
              let secIdentity = firstItem[kSecImportItemIdentity as String] as! SecIdentity?
        else {
            throw TSTLSConfiguration.Error.invalidData
        }
        var tlsConfiguration = TSTLSConfiguration(minimumTLSVersion: .tlsV10, maximumTLSVersion: .tlsV13, trustRoots: rootCertificate, clientIdentity: secIdentity, applicationProtocols: [], certificateVerification: .none)
        let configurationType: MQTTClient.TLSConfigurationType? = .ts(tlsConfiguration)
        #elseif canImport(NIOSSL)
        let rootCertificate = try NIOSSLCertificate.fromPEMFile(caCertificatePath)
        let myCertificate = try NIOSSLCertificate.fromPEMFile(centificatePath)
        let myPrivateKey = try NIOSSLPrivateKey(file: privateKeyPath, format: .pem)
        var tlsConfiguration: TLSConfiguration = TLSConfiguration.makeServerConfiguration(
            certificateChain: myCertificate.map { .certificate($0) },
            privateKey: .privateKey(myPrivateKey)
        )
        tlsConfiguration.trustRoots = .certificates(rootCertificate)
        let configurationType: MQTTClient.TLSConfigurationType? = .niossl(tlsConfiguration)
        #endif
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
        
        #if canImport(Network)
        let rootCertificates = try rootCertificate.map { certificate -> SecCertificate in
            guard let certificate = SecCertificateCreateWithData(nil, Data(try certificate.toDERBytes()) as CFData) else { throw TSTLSConfiguration.Error.invalidData }
            return certificate
        }
        let data = try SwKeyConvert.PrivateKey.pemToPKCS1DER(privateKey.data(using: .utf8) ?? Data())
        let options: [String: String] = [:]
        var rawItems: CFArray?
        guard SecPKCS12Import(data as CFData, options as CFDictionary, &rawItems) == errSecSuccess else { throw TSTLSConfiguration.Error.invalidData }
        let items = rawItems! as! [[String: Any]]
        guard let firstItem = items.first,
              let secIdentity = firstItem[kSecImportItemIdentity as String] as! SecIdentity?
        else {
            throw TSTLSConfiguration.Error.invalidData
        }
        var tlsConfiguration = TSTLSConfiguration(minimumTLSVersion: .tlsV10, maximumTLSVersion: .tlsV13, trustRoots: rootCertificates, clientIdentity: secIdentity, applicationProtocols: [], certificateVerification: .none)
        let configurationType: MQTTClient.TLSConfigurationType? = .ts(tlsConfiguration)
        #elseif canImport(NIOSSL)
        var tlsConfiguration: TLSConfiguration = TLSConfiguration.makeServerConfiguration(
            certificateChain: myCertificate.map { .certificate($0) },
            privateKey: .privateKey(myPrivateKey)
        )
        tlsConfiguration.trustRoots = .certificates(rootCertificate)
        let configurationType: MQTTClient.TLSConfigurationType? = .niossl(tlsConfiguration)
        #endif
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
        password: String,
        caCertificate: String
    ) throws -> MQTTClientProtocol {
        let rootCertificate = try NIOSSLCertificate.fromPEMBytes([UInt8](caCertificate.utf8))
        #if canImport(Network)
        let rootCertificates = try rootCertificate.map { certificate -> SecCertificate in
            guard let certificate = SecCertificateCreateWithData(nil, Data(try certificate.toDERBytes()) as CFData) else { throw TSTLSConfiguration.Error.invalidData }
            return certificate
        }
        var tlsConfiguration = TSTLSConfiguration(minimumTLSVersion: .tlsV10, maximumTLSVersion: .tlsV13, trustRoots: rootCertificates, clientIdentity: nil, applicationProtocols: [], certificateVerification: .none)
        let configurationType: MQTTClient.TLSConfigurationType? = .ts(tlsConfiguration)
        #elseif canImport(NIOSSL)
        var tlsConfiguration = TLSConfiguration.makeClientConfiguration()
        tlsConfiguration.trustRoots = .certificates(rootCertificate)
        let configurationType: MQTTClient.TLSConfigurationType? = .niossl(tlsConfiguration)
        #endif
        
        let clientConfiguration: MQTTClient.Configuration = .init(
            timeout: .seconds(30),
            userName: clientId,
            password: password,
            useSSL: true,
            tlsConfiguration: configurationType
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

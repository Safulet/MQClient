//
//  Config.swift
//  mqtt-nio-demo
//
//  Created by User on 27/06/2022.
//

import Foundation
import NIOSSL
import NIO

struct TLSConfigurationBuilder {

    static func buildDemoTLSConfiguration(_ endpoint: MQTTEndpoint) throws -> TLSConfiguration? {
        guard let secretKeys = endpoint.secretKeys else { return nil }
        return try buildTLSConfiguration(
            caCertificate: secretKeys.caCertText,
            certificate: secretKeys.myCertText,
            privateKey: secretKeys.privateKeyText,
            privateKeyFormat: .pem
        )
    }

    /// Only supports PEM format
    private static func buildTLSConfiguration(caCertificate: String, certificate: String, privateKey: String, privateKeyFormat: NIOSSLSerializationFormats) throws -> TLSConfiguration? {
        return try buildTLSConfiguration(
            caCertificate: [UInt8](caCertificate.utf8),
            certificate: [UInt8](certificate.utf8),
            privateKey: [UInt8](privateKey.utf8),
            privateKeyFormat: privateKeyFormat
        )
    }

    /// Only supports PEM format
    private static func buildTLSConfiguration(caCertificate: [UInt8], certificate: [UInt8], privateKey: [UInt8], privateKeyFormat: NIOSSLSerializationFormats) throws -> TLSConfiguration? {

        let rootCertificate = try NIOSSLCertificate.fromPEMBytes(caCertificate)
        let myCertificate = try NIOSSLCertificate.fromPEMBytes(certificate)
        let myPrivateKey = try NIOSSLPrivateKey(bytes: privateKey, format: privateKeyFormat)

        var tlsConfiguration = TLSConfiguration.makeClientConfiguration()
        tlsConfiguration.trustRoots = .certificates(rootCertificate)
        tlsConfiguration.certificateChain = myCertificate.map { .certificate($0) }
        tlsConfiguration.privateKey = .privateKey(myPrivateKey)

        return tlsConfiguration
    }
}

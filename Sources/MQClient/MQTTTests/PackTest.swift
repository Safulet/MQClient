//
//  PackTest.swift
//  SwCryptTests
//
//  Created by User on 02/08/2022.
//  Copyright © 2022 irl. All rights reserved.
//

import XCTest
import SwCrypt

extension SecureMessage {
    static func initFrom(json: String) -> SecureMessage {
        let data = json.data(using: .utf8)!
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        
        let clientId = json["client_id"] as! String
        let typeId = json["type_id"] as! String
        let sessionId = json["session_id"] as! String
        let toClientIds = json["to_client_ids"] as! [String]
        let encNonces = json["enc_nonces"] as! [String]
        let encKeys = json["enc_keys"] as! [String]
        let encPayloads = json["enc_payloads"] as! [String]
        let payloadsHashSenderSignature = json["payloads_hash_sender_signature"] as! String
        return SecureMessage(
            clientId: clientId,
            typeId: typeId,
            sessionId: sessionId,
            toClientIds: toClientIds,
            encNonces: encNonces.map { Data(base64Encoded: $0)! },
            encKeys: encKeys.map { Data(base64Encoded: $0)! },
            encPayloads: encPayloads.map { Data(base64Encoded: $0)! },
            payloadsHashSenderSignature: Data(base64Encoded: payloadsHashSenderSignature)!
        )
    }
}

class PackTest: XCTestCase {

    var ourKey: (Data, Data)!
    
    let json = """
        {"client_id":"test_client","type_id":"test","session_id":"session","to_client_ids":["client_1","client_2"],"enc_nonces":["mEDZcbEXRxLPLdOq","2AT+gskU6P12Dtpl"],"enc_keys":["zqZ91AHO/bnLIHodQTeyH3+fl0LtVWTYonymAvl6QjkZfxUyanguT1zl12twDrAlX4qN6RV1mPrG29HYVN/7sOdAo+lQDMwuNHLQ+cX3Bvcy8gdW/A0HZ8GGGOKSIp1Gm/eym3tP2lz1u4ik2v4y9l/wK1vKgTZ4qnoldYXiHPY=","LCroOjF6aQh5tjtuR5ZncChdgzS+TLvXH+Xd9mMyB7+Bn3WEzKVgLadLhs8pOPMm8+0DYi6uu4qNkHycBPAvDLouqbzk++Oi1JwPEX8roa1FeumCrItWexotT8+f5f85xEBzszILuDv+3xic/CWK7zRCRjw9cyH673TbVOKEOPI="],"enc_payloads":["hs0OR4LZR53tNbp5A3MvCtjHgKW7","YCHXq0JLWbxGpFnHbfxU83CW/e+D"],"payloads_hash_sender_signature":"QPmfSsv/J1ZrOSL6r3JJz3RhaQerhPIRvevEqrBjblldZUT9kMRuh9wy6qPB8ENN2zaMHrdWvw/nBN0/Yco0HsCT/1R4xL5+gjgFHPvQxk6PeQ4VyGCFMpxJy5RaeZF3PmP2Nd9rw0vq3fxrP0wfJtbcrV6C2U1W0VuADSeHSNI="}
        """
    
    override func setUp() {
        super.setUp()
        ourKey = try! CC.RSA.generateKeyPair()
        self.continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testPackMessage() {
        let ourClientId = "test_client"
        let typeId = "test"
        let sessionId = "session"
        let payload: Data = Data([42, 42, 42, 42, 42])
        let clientIds = ["client_1", "client_2"]
        
        let publicKeyPem = """
    -----BEGIN PUBLIC KEY-----
    MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDXR8alN7kr9vWaTXEV4I2wn2us
    F5RG14pZQ710Vj3nzA2c+9Cldd6SoBxVJYWIFWgYBY7Or7BlwBxCa8JRHQDbYYbG
    1lknHMo+JlYzZV65mQKVMJnL88aysxp+oOpka9iJK+WC+UiK3IPhnmkMW6jYWZCn
    0U35cmNxqC5p2UVMOwIDAQAB
    -----END PUBLIC KEY-----
    """
        let pubKey = try! SwKeyConvert.PublicKey.pemToPKCS1DER(publicKeyPem)
        let secMsg = try! Message.packSecureMessage(ourClientId: ourClientId, typeId: typeId, sessionId: sessionId, ourKey: ourKey.0, toClientIds: clientIds, toKeys: [pubKey, pubKey], payload: payload)
        print("secMessage is \(secMsg)")
        let privateKey = """
    -----BEGIN PRIVATE KEY-----
    MIICXQIBAAKBgQDXR8alN7kr9vWaTXEV4I2wn2usF5RG14pZQ710Vj3nzA2c+9Cl
    dd6SoBxVJYWIFWgYBY7Or7BlwBxCa8JRHQDbYYbG1lknHMo+JlYzZV65mQKVMJnL
    88aysxp+oOpka9iJK+WC+UiK3IPhnmkMW6jYWZCn0U35cmNxqC5p2UVMOwIDAQAB
    AoGAcgtGAnRYlh/H0CxCQhKpPO3XPl1nYXgBhHRMQvsE5GzGsWj9CQo+FHLZT4oH
    CSY99KvNEVUlH2H8Fnu7fvjcYGJKihUO34jyTJNLycd3itFNGoP/3qipxor0pt24
    gWQ8u60XqCXZxLZGgAmDJsvdsC3jVbX927HdvuEuM3Zss2ECQQD5AxEtKD2wB2hV
    FPfYbqqQTF9ciFfiQUwS1mOk5SLYVBpKD/rCCOHkoAi/6udYB9fxReuGWQXJKPNh
    DLx8+a5DAkEA3VJgd9qe1XgCrpS9OtgQB9edTX7QsWEv6GbHIMaSUA/TfXum/0w0
    ttweATqVoeyCBn2lf5Bge+26Q2/N2/KWqQJBAOubbFAWyC9bAuul2E/vffDkYkJS
    Ox03/TvBoCxwJYUcJne3IOMgtmO0zDKSl2wil76REqVea+wGlClafKmfMLMCQEbr
    49/kXauYRnu9TBo0LIbm0BCKR8PfmeOGM99L4oznVWVLn4sF14qVZMQOCu8Vg+Ei
    mEsVb+Wmm16K0FPgG+kCQQDJdXpWmeysvWl9gxmktl4z1pD4yOrvF1M0n9B7xc1v
    iYD5cP97ZjxbHmhgbDy6Od2RGG9GSv7JUGzMNtYAPVRK
    -----END PRIVATE KEY-----
    """
        let priKey = try! SwKeyConvert.PrivateKey.pemToPKCS1DER(privateKey)
        
        let unpackPayload = try! Message.unpackSecureMessage(ourClientId: clientIds[0], sessionId: sessionId, ourKey: priKey, senderKey: ourKey.1, secMsg: secMsg)
        XCTAssertEqual(payload, unpackPayload)
    }
    
    func testUnpackMessage() {
        
    }

    func testEncryptDecryptOAEPSHA256223() {
        
    //        var ourClientId = "test_client"
    //        var typeId = "test"
        var sessionId = "orders"
    //        let payload = [42, 42, 42, 42, 42]
    //        let clientIds = ["client_1", "client_2"]
    //        let (priv, pub) = keyPair!
        
        let publicKey = """
    -----BEGIN PUBLIC KEY-----
    MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDXR8alN7kr9vWaTXEV4I2wn2us
    F5RG14pZQ710Vj3nzA2c+9Cldd6SoBxVJYWIFWgYBY7Or7BlwBxCa8JRHQDbYYbG
    1lknHMo+JlYzZV65mQKVMJnL88aysxp+oOpka9iJK+WC+UiK3IPhnmkMW6jYWZCn
    0U35cmNxqC5p2UVMOwIDAQAB
    -----END PUBLIC KEY-----
    """

        let message = "send reinforcements, we're going to advance"
        let pubKey = try! SwKeyConvert.PublicKey.pemToPKCS1DER(publicKey)
        let testData = message.data(using: String.Encoding.utf8)!
        let e = try? CC.RSA.encrypt(testData, derKey: pubKey, tag: Data(), padding: .oaep, digest: .sha256)
        print("______ %x \(e?.hexadecimalString())")
        XCTAssert(e != nil)
        
        
        let privateKey = """
    -----BEGIN PRIVATE KEY-----
    MIICXQIBAAKBgQDXR8alN7kr9vWaTXEV4I2wn2usF5RG14pZQ710Vj3nzA2c+9Cl
    dd6SoBxVJYWIFWgYBY7Or7BlwBxCa8JRHQDbYYbG1lknHMo+JlYzZV65mQKVMJnL
    88aysxp+oOpka9iJK+WC+UiK3IPhnmkMW6jYWZCn0U35cmNxqC5p2UVMOwIDAQAB
    AoGAcgtGAnRYlh/H0CxCQhKpPO3XPl1nYXgBhHRMQvsE5GzGsWj9CQo+FHLZT4oH
    CSY99KvNEVUlH2H8Fnu7fvjcYGJKihUO34jyTJNLycd3itFNGoP/3qipxor0pt24
    gWQ8u60XqCXZxLZGgAmDJsvdsC3jVbX927HdvuEuM3Zss2ECQQD5AxEtKD2wB2hV
    FPfYbqqQTF9ciFfiQUwS1mOk5SLYVBpKD/rCCOHkoAi/6udYB9fxReuGWQXJKPNh
    DLx8+a5DAkEA3VJgd9qe1XgCrpS9OtgQB9edTX7QsWEv6GbHIMaSUA/TfXum/0w0
    ttweATqVoeyCBn2lf5Bge+26Q2/N2/KWqQJBAOubbFAWyC9bAuul2E/vffDkYkJS
    Ox03/TvBoCxwJYUcJne3IOMgtmO0zDKSl2wil76REqVea+wGlClafKmfMLMCQEbr
    49/kXauYRnu9TBo0LIbm0BCKR8PfmeOGM99L4oznVWVLn4sF14qVZMQOCu8Vg+Ei
    mEsVb+Wmm16K0FPgG+kCQQDJdXpWmeysvWl9gxmktl4z1pD4yOrvF1M0n9B7xc1v
    iYD5cP97ZjxbHmhgbDy6Od2RGG9GSv7JUGzMNtYAPVRK
    -----END PRIVATE KEY-----
    """
        let cipherText = "8b4d8d1d466fad0221b41d5d4449e64ed60f11ff4dafdc94157786298d8372278c5967ba17712a2603ca0528eac258e5e32e623505d235978430210ca048f3be4fe1fdb94d505e26a0713a747b811093bb0dfeb34789e9788fc9cc86bc45baa986ba44091c60498eb1e368e7c7bd11714706505eda199c751ddf5b3cc02a01b7"
        let priKey = try! SwKeyConvert.PrivateKey.pemToPKCS1DER(privateKey)
        
        let data = cipherText.dataFromHexadecimalString()!
        let origin = try? CC.RSA.decrypt(data, derKey: priKey, tag: Data(), padding: .oaep, digest: .sha256)
        
        XCTAssert(origin != nil)
    }

    func testDecrypt() {

        let sessionId = "session"
        let payload: Data = Data([42, 42, 42, 42, 42])
        let clientIds = ["client_1", "client_2"]
        let json = """
        {"client_id":"test_client","type_id":"test","session_id":"session","to_client_ids":["client_1","client_2"],"enc_nonces":["ruEZl647NVcFSuxe","0oUxSbrODfYwHVON"],"enc_keys":["1WJ63OgU3vDt+b2MCth7TZQLoULXVRFdx9Z9ki4aK8kEU8y6i9Su6LOTfItftVi7Paj0tb7CF/LGlgVRYMnjFWOSjUn1ODnI6LSVJs0XetGtBQHmdM11WNJ9yW7kFJLLe4FzA9VxMsUQXV9xMGx+UG9zpuisEo+nOv6YwtfJnFE=","WZaK9eL5LhEJwyWmo63lIwoLYcHjumr+mF+6qOeXHfFeDJy9bBdQjlxTGS+zCvghw+9P4ztBo1wm+oaImdtj3HgWlFuFyzxpAOibiBfTGx8bEUsORzoqsxUPSzSc4JVtnx/VJG34U+lxH4lTIPUsBf34z3HwnvjlmNAK9krwnuQ="],"enc_payloads":["r6f3CZydl8SEpnpxBqwWPcoWXWAi","Fo3NNTNJhD2apELwFl9HnNbU6pXn"],"payloads_hash_sender_signature":"V7It2SpbhIL4InizhGgSR2sIKBh7LKvyZPfhsOiqiVnSSzo+3tT+1GiBeO1HWuBJhAvcuyAyVjHlh1RdEuIsEc2n+dctpGAfIbj0ag7vhKJHQHk3ovpgZi2kNRdAP+/T2zmyDj7G2BozwQ7yFs9DuzEnZKc4ZkStXoIpNXTWcI8="}
        """
        let secMsg = SecureMessage.initFrom(json: json)
        let privateKey = """
-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQDXR8alN7kr9vWaTXEV4I2wn2usF5RG14pZQ710Vj3nzA2c+9Cl
dd6SoBxVJYWIFWgYBY7Or7BlwBxCa8JRHQDbYYbG1lknHMo+JlYzZV65mQKVMJnL
88aysxp+oOpka9iJK+WC+UiK3IPhnmkMW6jYWZCn0U35cmNxqC5p2UVMOwIDAQAB
AoGAcgtGAnRYlh/H0CxCQhKpPO3XPl1nYXgBhHRMQvsE5GzGsWj9CQo+FHLZT4oH
CSY99KvNEVUlH2H8Fnu7fvjcYGJKihUO34jyTJNLycd3itFNGoP/3qipxor0pt24
gWQ8u60XqCXZxLZGgAmDJsvdsC3jVbX927HdvuEuM3Zss2ECQQD5AxEtKD2wB2hV
FPfYbqqQTF9ciFfiQUwS1mOk5SLYVBpKD/rCCOHkoAi/6udYB9fxReuGWQXJKPNh
DLx8+a5DAkEA3VJgd9qe1XgCrpS9OtgQB9edTX7QsWEv6GbHIMaSUA/TfXum/0w0
ttweATqVoeyCBn2lf5Bge+26Q2/N2/KWqQJBAOubbFAWyC9bAuul2E/vffDkYkJS
Ox03/TvBoCxwJYUcJne3IOMgtmO0zDKSl2wil76REqVea+wGlClafKmfMLMCQEbr
49/kXauYRnu9TBo0LIbm0BCKR8PfmeOGM99L4oznVWVLn4sF14qVZMQOCu8Vg+Ei
mEsVb+Wmm16K0FPgG+kCQQDJdXpWmeysvWl9gxmktl4z1pD4yOrvF1M0n9B7xc1v
iYD5cP97ZjxbHmhgbDy6Od2RGG9GSv7JUGzMNtYAPVRK
-----END RSA PRIVATE KEY-----
"""
        let priKey = try! SwKeyConvert.PrivateKey.pemToPKCS1DER(privateKey)
        
        let ourKeyPubPem = """
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgW2NvEtrXyO01yyIHrX5mnsLY
ith/s7fRUohXXuTzNs6pnuyH8V3LNkyZprvdyf8tLzA9vaJDGViRg7I/22zfY9uy
9qRQtjLTIyUZpvs65wOf0B3+TnJ50y0jf/CvP6NSIb1qwTPnVXFgIlJ90ZzTL69z
adAviIkM1jdcLQBtjQIDAQAB
-----END PUBLIC KEY-----
"""
        let ourKeyPub = try! SwKeyConvert.PublicKey.pemToPKCS1DER(ourKeyPubPem)
//        let hkdfKey = try! HKDF(password: [UInt8](ourKeyPub), keyLength: 32).calculate()
        do {
            let unpackPayload = try Message.unpackSecureMessage(ourClientId: clientIds[0], sessionId: sessionId, ourKey: priKey, senderKey: ourKeyPub, secMsg: secMsg)
            XCTAssertEqual(payload, unpackPayload)
        } catch {
            print(error)
        }
        
        
    }
    
    
}


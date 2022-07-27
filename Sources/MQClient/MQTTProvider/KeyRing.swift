//
//  File.swift
//  
//
//  Created by User on 25/07/2022.
//

import Foundation
import _CryptoExtras

typealias RSAPrivateKey = _RSA.Signing.PrivateKey
typealias RSAPublicKey = _RSA.Signing.PublicKey

enum KeyRingError: Error {
    case publicKeyEmpty
    case publicKeynotFound
}

public struct KeyRing {
    var privateKey: RSAPrivateKey?
    var publicKeys: [String: String]
    
    public static var defaultKeyRing = KeyRing(publicKeys: [:])
    
    mutating func savePrivateKeyFromPem(privateKeyPem: String) throws {
        let privateKey = try RSAPrivateKey(pemRepresentation: privateKeyPem)
        self.privateKey = privateKey
        
    }

    mutating func savePublicKeyFromPem(clientId: String, publicKeyPem: String) {
        publicKeys[clientId] = publicKeyPem
    }
    
    func findPublicKey(clientId: String) throws -> RSAPublicKey {
        guard publicKeys.count > 0 else {
            throw KeyRingError.publicKeyEmpty
        }
        guard let publicKeyPem = publicKeys[clientId] else {
            throw KeyRingError.publicKeynotFound
        }
        return try RSAPublicKey(pemRepresentation: publicKeyPem)
    }
    
    func findPublicKeyPem(clientId: String) throws -> String {
        guard publicKeys.count > 0 else {
            throw KeyRingError.publicKeyEmpty
        }
        guard let publicKeyPem = publicKeys[clientId] else {
            throw KeyRingError.publicKeynotFound
        }
        return publicKeyPem
    }
    
    func findPublicKeys(clientIds: [String]) throws -> [RSAPublicKey] {
        let publicKeys = try clientIds.map {
            try findPublicKey(clientId: $0)
        }
        return publicKeys
    }
    
    func getPrivateKey() -> RSAPrivateKey? {
        privateKey
    }
    
    func hasPrivateKey() -> Bool {
        privateKey == nil
    }
    
    func serialize() -> String {
        "{sk: \(privateKey?.pemRepresentation ?? ""), pks: \(publicKeys) }"
    }
    
    func length() -> Int {
        publicKeys.count
    }
}

//type (
//    KeyRing struct {
//        OurPrivateKey *rsa.PrivateKey   `json:"sk"`
//        PublicKeys    map[string]string `json:"pks"` // for lookup speed we keep them in string/pem format.
//    }
//)
//
//var (
//    defaultKeyRing *KeyRing
//)
//
//func init() {
//    defaultKeyRing = NewKeyRing()
//}
//
//func DefaultKeyRing() *KeyRing {
//    return defaultKeyRing
//}
//
//func DefaultSaveOurPrivateKeyFromPem(privPemStr string) error {
//    return DefaultKeyRing().SaveOurPrivateKeyFromPem(privPemStr)
//}
//
//func DefaultSavePublicKeyFromPem(clientId, pubPemStr string) error {
//    return DefaultKeyRing().SaveClientPublicKeyFromPem(clientId, pubPemStr)
//}
//
//func DefaultSerialize() (string, error) {
//    return DefaultKeyRing().Serialize()
//}
//
//func DefaultLen() int {
//    return DefaultKeyRing().Len()
//}
//
//// ----- //
//
//func NewKeyRing() *KeyRing {
//    return &KeyRing{
//        PublicKeys: make(map[string]string),
//    }
//}
//
//func (kc *KeyRing) SaveOurPrivateKeyFromPem(privPemStr string) error {
//    privateKey, err := getPrivateKeyFromPem(privPemStr)
//    if err != nil {
//        return err
//    }
//    kc.OurPrivateKey = privateKey
//    return nil
//}
//
//func (kc *KeyRing) SaveClientPublicKeyFromPem(clientId, pubPemStr string) error {
//    kc.PublicKeys[clientId] = pubPemStr
//    return nil
//}
//
//func (kc *KeyRing) FindPublicKey(clientId string) (*rsa.PublicKey, error) {
//    if len(kc.PublicKeys) == 0 {
//        return nil, errors.New("this keyring does not have any keys stored")
//    }
//    pk, ok := kc.PublicKeys[clientId]
//    if !ok {
//        return nil, fmt.Errorf("a public key for client with clientId %s was not found", clientId)
//    }
//    return getPublicKeyFromPem(pk)
//}
//
//func (kc *KeyRing) FindPublicKeyPem(clientId string) (string, error) {
//    if len(kc.PublicKeys) == 0 {
//        return "", errors.New("this keyring does not have any keys stored")
//    }
//    pk, ok := kc.PublicKeys[clientId]
//    if !ok {
//        return "", fmt.Errorf("a public key for client with clientId %s was not found", clientId)
//    }
//    return pk, nil
//}
//
//func (kc *KeyRing) FindPublicKeys(clientIds []string) ([]*rsa.PublicKey, error) {
//    pks := make([]*rsa.PublicKey, len(clientIds))
//    var err error
//    for i, clientId := range clientIds {
//        if pks[i], err = kc.FindPublicKey(clientId); err != nil {
//            return nil, err
//        }
//    }
//    return pks, nil
//}
//
//func (kc *KeyRing) GetOurPrivateKey() *rsa.PrivateKey {
//    return kc.OurPrivateKey
//}
//
//func (kc *KeyRing) HasPrivateKey() bool {
//    return kc.OurPrivateKey != nil
//}
//
//func (kc *KeyRing) Serialize() (string, error) {
//    bz, err := json.Marshal(kc)
//    return string(bz), err
//}
//
//func (kc *KeyRing) Len() int {
//    return len(kc.PublicKeys)
//}
//
//// ----- //
//
//func getPrivateKeyFromPem(privPemStr string) (*rsa.PrivateKey, error) {
//    privPem, _ := pem.Decode([]byte(privPemStr))
//    var privPemBytes []byte
//    if privPem.Type != "RSA PRIVATE KEY" {
//        common.Logger.Warning("RSA private key is of the wrong type", privPem.Type)
//    }
//    // TODO: decryption of the PEM data could go here
//    // if password was provided ...
//    // privPemBytes = x509.DecryptPEMBlock(privPem, []byte(password))
//    privPemBytes = privPem.Bytes
//
//    var err error
//    var parsedKey interface{}
//    // Try PKCS#1 then PKCS#8
//    if parsedKey, err = x509.ParsePKCS1PrivateKey(privPemBytes); err != nil {
//        if parsedKey, err = x509.ParsePKCS8PrivateKey(privPemBytes); err != nil { // note this returns type `interface{}`
//            common.Logger.Error("Unable to parse RSA private key in PEM PKCS#1/PKCS#8 formats", err)
//            return nil, err
//        }
//    }
//
//    var privateKey *rsa.PrivateKey
//    var ok bool
//    if privateKey, ok = parsedKey.(*rsa.PrivateKey); !ok {
//        errMsg := "unable to cast RSA private key"
//        common.Logger.Error(errMsg)
//        return nil, errors.New(errMsg)
//    }
//    return privateKey, nil
//}
//
//func getPublicKeyFromPem(pubPemStr string) (*rsa.PublicKey, error) {
//    pubPem, _ := pem.Decode([]byte(pubPemStr))
//    var pubPemBytes []byte
//    if pubPem.Type != "RSA PUBLIC KEY" {
//        common.Logger.Warning("RSA public key is of the wrong type", pubPem.Type)
//    }
//    // TODO: decryption of the PEM data could go here
//    // if password was provided ...
//    // privPemBytes = x509.DecryptPEMBlock(pubPem, []byte(password))
//    pubPemBytes = pubPem.Bytes
//
//    var err error
//    var parsedKey interface{}
//    // Try PKCS#1 then PKIX
//    if parsedKey, err = x509.ParsePKCS1PublicKey(pubPemBytes); err != nil {
//        if parsedKey, err = x509.ParsePKIXPublicKey(pubPemBytes); err != nil { // note this returns type `interface{}`
//            common.Logger.Error("Unable to parse RSA private key, generating a temp one", err)
//            return nil, err
//        }
//    }
//
//    var publicKey *rsa.PublicKey
//    var ok bool
//    if publicKey, ok = parsedKey.(*rsa.PublicKey); !ok {
//        errMsg := "unable to cast RSA public key"
//        common.Logger.Error(errMsg)
//        return nil, errors.New(errMsg)
//    }
//    return publicKey, nil
//}

//
//  File.swift
//  
//
//  Created by User on 26/07/2022.
//

import XCTest
@testable import MQClient

let privateKeyPem = """
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAwm/3XMKcqIGNFk2V7wBmBdnRBtYbQ/RlKZfCoeZt6dhjOME2
N2bF+MJewuR+75EyWm2FgY7kZBUhp1IGWduXBvnyhq/mIkSlQ1CAC3A5fvb7pNe1
5By+lJat0vyZBdcV+FQGWdXalM+BK/OrKkOKdod60QMsr2HCjxTHFDnmEkXiqvu5
vGmCacM2TET3j7j6jZiK3RPjITmKLMYKCQUTaaqU8T0MG9hGTXJO+fpv1GmxSW3M
41tVY9tP1DuPqs4hbIQTgDBpX5/TB2lrmoKzYeMInTUwM4UnSddrK+uubBJzyA8U
P6LkwVj2O67vZy5e5pSsZYAhTcg541zdEtKQJwIDAQABAoIBAQCFNTYv27h+DTt+
kyrsMcazrXVyDI9jb/U6mJkkV/znX3Mit+QP8p4g/fDz7p00PbJUl4IGr8Gy+3Mx
8ZUeTL3cbrMEKVAuG/9o7aa7r2gEnurqFUqs/DBpFg4CZUHk6WVI2y/6rfNxTfQ+
C1MxwlIDQHAY7+bWRNCJO//j0ILZ8skFTGZJd0uv/jfwSr94LkaX4KpCln6ubSv3
pIhcRvavv9kn4M/NYzFqdUsM87BZigrrG0LNTBtlkBHu7RHtJhNWniks/rKFglZM
FD9KqnLnIjHw5TqIZ23gKDg4hrlV5/pZvDGwT5GL8Q9ZnwMiJ3iyP2zxNWQIImUs
YctGTceBAoGBAPw8Yt0AlI9qCoPeQ33i1MLrz/vbAwlFQkJqHYW5tkYfv0krbwbV
9a42dT5ayHGRJvAdvvn1C9617ubbWR80egMWyEU9WYUFXIpRGR+QwwaDW8/oy/0T
8qkJzj5Bh7al2mBukha+XluXm9vxAxnKvnEcquftkhM2fl/DRFUw9XHBAoGBAMVW
xehtu4ZHC126btXCC9KQISl7fvu16enPHoqt/m5f2bfd5nijx9B8tscAEvltKQO5
vr5bJQt3fhXWAGiAXRE+3fRL0ImRtPLATMbnejVY4VA8LbM+B+aThPZtD+LJ2tzq
zdOLGgZblcbJXz1HN2RMxCKfXGGcqmQopJDvnavnAoGBALdbyl5voo8SfexYcWWc
tB+yPnIORonBsCYJb8abNvaI84vkKASnGr521gnrApUT+GNKrF6WFPfj93QYdhPq
GNwP/qveqim5uQjPZVz95dfhO6fKyicCDj91Ylj9WAOdUz8QgeBIqN0aO/HJpQBl
0sT1GwQYPjz7OyiwEQeA3JvBAoGBAJl4WoHglS5goh5Kl1f2iWtAXAn+2Uq4tyn2
wjHoDy+Xq6KrGEpKVWN3Gk65aAhDNNqI4ib4i17Xl180By0+ZyK6WbNcItpaTvdb
RlqKOyix7siPhJsZatuPbqCXQPuHMIcOtPQIAj1fjKQEh+UINbPzX7XtadMgHAO4
+AMf1ueRAoGAFrUxmuN2txqKAqoD6g1iiwQ4trtIxMs4Ds3CKzyur8O+l1pcW0Lu
OJXk/ukNymbotCps/yX+ufq8a6fqZf8WcMar9LkfiD0d3hQulIZ8v9CMQb75vlwN
lEPjgYPahzag6PCAQBHlJB2IAPfzhTdwPJLYDL2rJY/nuTp+oKkMQkA=
-----END RSA PRIVATE KEY-----
"""

let publicKeyPem = """
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwm/3XMKcqIGNFk2V7wBm
BdnRBtYbQ/RlKZfCoeZt6dhjOME2N2bF+MJewuR+75EyWm2FgY7kZBUhp1IGWduX
Bvnyhq/mIkSlQ1CAC3A5fvb7pNe15By+lJat0vyZBdcV+FQGWdXalM+BK/OrKkOK
dod60QMsr2HCjxTHFDnmEkXiqvu5vGmCacM2TET3j7j6jZiK3RPjITmKLMYKCQUT
aaqU8T0MG9hGTXJO+fpv1GmxSW3M41tVY9tP1DuPqs4hbIQTgDBpX5/TB2lrmoKz
YeMInTUwM4UnSddrK+uubBJzyA8UP6LkwVj2O67vZy5e5pSsZYAhTcg541zdEtKQ
JwIDAQAB
-----END PUBLIC KEY-----
"""


final class KeyRingTests: XCTestCase {
    
    var kc: KeyRing = .defaultKeyRing
    
    override func setUp() {
        
    }
    
    override class func tearDown() {
        
    }
    
    func testSavePrivateKeyFromPem() {
        do {
            try kc.savePrivateKeyFromPem(privateKeyPem: privateKeyPem)
        } catch {
            XCTAssert(false, "save private key from pem failed \(error)")
        }
        XCTAssertNotNil(kc.getPrivateKey)
    }
    
    func testSavePublicKeyFromPem() {
        kc.savePublicKeyFromPem(clientId: "id_0", publicKeyPem: publicKeyPem)
        do {
            _ = try kc.findPublicKey(clientId: "id_0")
        } catch {
            XCTAssert(false, "save public key from pem failed \(error)")
        }
    }
}

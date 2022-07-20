# Method used to generate the p12 file

Combine `ca_cert` and `cert` into a single file

```
python -c "from sys import argv; print '\n'.join(open(f).read() for f in ['ca_cert.cacert', 'cert.cert'])," > cert-chain.txt
```

Generate p12 file

```
openssl pkcs12 -export -in cert-chain.txt -inkey key.key -name ‘swee’ -out keystore.p12
```

During generation, password used is `swee`

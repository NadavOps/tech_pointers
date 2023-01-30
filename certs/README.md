# Certs

### Table of Content
* [Links](#links)

##
```
openssl x509 -text -noout -in server.crt
```


```
pkcs12_path=<path>.pkcs12
cert_with_key_path=<path>.pem
keystore_pass=random_string
jks_dest_path=<path>.jks

openssl pkcs12 -export -out "$pkcs12_path" -in "$cert_with_key_path" -password pass:$keystore_pass

keytool -v -importkeystore -noprompt -srckeystore "$pkcs12_path" -srcstoretype PKCS12 -srcstorepass $keystore_pass -destkeystore "$jks_dest_path" -deststoretype JKS -deststorepass $keystore_pass
```

## Links

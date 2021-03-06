All about TLS/SSL

References:
* Connecting to SSL services: [https://confluence.atlassian.com/jira/connecting-to-ssl-services-117455.html](https://confluence.atlassian.com/jira/connecting-to-ssl-services-117455.html)
* Test truststore/certificate with SSL Poke: [https://confluence.atlassian.com/kb/unable-to-connect-to-ssl-services-due-to-pkix-path-building-failed-error-779355358.html](https://confluence.atlassian.com/kb/unable-to-connect-to-ssl-services-due-to-pkix-path-building-failed-error-779355358.html)
* Test truststore/certificate: [https://github.com/ChristopherSchultz/ssltest](https://github.com/ChristopherSchultz/ssltest)
* Test truststore/certificate: [https://dzone.com/articles/ssl-testing-tool](https://dzone.com/articles/ssl-testing-tool)
* Convert from OpenSSL to P12 then to JKS: [https://devopscube.com/configure-ssl-jenkins/](https://devopscube.com/configure-ssl-jenkins/)


Tools:
* Keystore Explorer [https://keystore-explorer.org/](https://keystore-explorer.org/)
* Portecle [http://portecle.sourceforge.net/](http://portecle.sourceforge.net/)

Commands:
* openssl to pkcs12 format:
```shel
openssl pkcs12 -export -out <FQDN>.p12 -inkey <FQDN>.key -in <FQDN>.crt -name "<FQDN>"
```

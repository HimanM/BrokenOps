### Scenario

A bootstrap service is supposed to download and install a tiny internal package from a local HTTPS endpoint. The download fails with certificate validation errors, so the package never gets installed.

The CA certificate file is already present on the machine, but the system trust store is stale. Fix the trust chain and get the bootstrap flow working again.

### Objective

1. Inspect the HTTPS server and the bootstrap service.
2. Identify why HTTPS requests fail even though the CA certificate file exists.
3. Refresh the system trust store so the certificate is trusted.
4. Re-run the bootstrap flow and confirm the package is installed.

### Useful Commands

- `systemctl status lab-bootstrap.service`
- `systemctl status lab-https.service`
- `curl -v https://localhost:8443/labtool_1.0_all.deb`
- `update-ca-certificates`

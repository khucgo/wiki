# aws-cli-mfa-profile.ps1

### Purpose
Create MFA profile for CLI, SDK and API usage. An MFA profile contains:
- A pair of AWS access/secret key for the temporary session.
- A token of the session.

Created MFA profile then is set to `AWS_PROFILE` environment variable for convenience. You can run `aws` command without having to provide `--profile` parameter.

### Run
```powershell
.\aws-cli-mfa-profile.ps1
```

##### Inputs
1. Access key ID: Your (main) AWS access key ID.
2. Secret access key: Your (main) AWS secret access key.
3. Region: AWS region for MFA profile.
4. Output: AWS output for MFA profile.
5. MFA profile name: Name for the MFA profile.
6. MFA ARN: Your MFA virtual/hardware device ARN.
7. MFA token: Token from your MFA virtual/hardware device.

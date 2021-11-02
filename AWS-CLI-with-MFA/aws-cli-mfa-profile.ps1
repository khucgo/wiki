# powershell

### INPUT
param (
    [string]$main_access_key_id = $(Read-Host "Access key ID"),
    [string]$main_secret_access_key = $(Read-Host "Secret access key"),
    [string]$region = $(Read-Host "Region"),
    [string]$output = $(Read-Host "Output"),
    [string]$profile_mfa = $(Read-Host "MFA profile name"),
    [string]$mfa_arn = $(Read-Host "MFA ARN"),
    [string]$mfa_token = $(Read-Host "MFA token")
)

### PROCESS
# Configure for `aws sts get-session-token` command
$profile_tmp="$profile_mfa-tmp"
aws configure set "profile.$profile_tmp.aws_access_key_id" $main_access_key_id
aws configure set "profile.$profile_tmp.aws_secret_access_key" $main_secret_access_key
aws configure set "profile.$profile_tmp.region" $region
aws configure set "profile.$profile_tmp.output" $output
[Environment]::SetEnvironmentVariable('AWS_PROFILE', $profile_tmp, 'User')
echo "Temporary profile ``$profile_tmp`` has been set."

# Get session token
echo "Start getting session token..."
$result = aws sts get-session-token --serial-number $mfa_arn --token-code $mfa_token --profile $profile_tmp --output json
$data = $result | ConvertFrom-Json
if (!$data.Credentials) {
    echo "Error! Exit."
    exit
}
echo "Success! Finish getting session token."

# Create/Update profile
echo "Start setting MFA profile..."

aws configure set "profile.$profile_mfa.aws_access_key_id" $data.Credentials.AccessKeyId
aws configure set "profile.$profile_mfa.aws_secret_access_key" $data.Credentials.SecretAccessKey
aws configure set "profile.$profile_mfa.aws_session_token" $data.Credentials.SessionToken
aws configure set "profile.$profile_mfa.region" $region
aws configure set "profile.$profile_mfa.output" $output

[Environment]::SetEnvironmentVariable('AWS_PROFILE', $profile_mfa, 'User')

# cleanup
aws configure set "profile.$profile_tmp.aws_access_key_id" "null"
aws configure set "profile.$profile_tmp.aws_secret_access_key" "null"

echo "Success! MFA profile ``$profile_mfa`` has been set."
echo "``AWS_PROFILE`` environment variable is now ``$profile_mfa``."

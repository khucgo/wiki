## Powershell 5,6,7 compatible

function Get-Params {
    param (
        [string]$main_access_key_id     = $(Read-Host "Access key ID"),
        [string]$main_secret_access_key = $(Read-Host "Secret access key"),
        [string]$region                 = $(Read-Host "Region"),
        [string]$output                 = $(Read-Host "Output"),
        [string]$profile_mfa            = $(Read-Host "MFA profile name"),
        [string]$profile_to_env         = $(Read-Host "Set env? (Y/Yes/N/No)"),
        [int]$ttl                       = $(Read-Host "Time-to-live (1-12 hours)"),
        [string]$mfa_arn                = $(Read-Host "MFA ARN")
    )

    $params = @{}
    $params.main_access_key_id = $main_access_key_id
    $params.main_secret_access_key = $main_secret_access_key
    $params.region = $region
    $params.output = $output
    $params.profile_mfa = $profile_mfa
    $params.profile_to_env = $profile_to_env
    $params.ttl = $ttl
    $params.mfa_arn = $mfa_arn

    return $params
}

## Declare information by setting values to the variables here if you don't want to provide at the prompt.
$main_access_key_id     = ""
$main_secret_access_key = ""
$region                 = ""
$output                 = "yaml"    # (json/yaml/text) https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-output-format.html
$profile_mfa            = ""        # A random name will be generated
$profile_to_env         = "Yes"     # Set env? (Y/Yes/N/No)
$ttl                    = 1         # Time-to-live (1-12 hours)
$mfa_arn                = ""

while (!"$main_access_key_id" -or !"$main_secret_access_key" -or !"$region" -or !"$mfa_arn") {
    echo "Not enough information. Please provide below."
    $tmp = Get-Params
    $main_access_key_id = $tmp.main_access_key_id
    $main_secret_access_key = $tmp.main_secret_access_key
    $region = $tmp.region
    $output = $tmp.output
    $profile_mfa = $tmp.profile_mfa
    $profile_to_env = $tmp.profile_to_env
    $ttl = $tmp.ttl
    $mfa_arn = $tmp.mfa_arn
}

## DEBUG
# echo $main_access_key_id
# echo $main_secret_access_key
# echo $region
# echo $output
# echo $profile_mfa
# echo $profile_to_env
# echo $ttl
# echo $mfa_arn

## Fixed prompt
while (!"$mfa_token") {
    $mfa_token = $(Read-Host "MFA token")
}

## PROCESS
## Generate name for MFA profile in case it is omitted
if (!"$profile_mfa") {
    $profile_mfa = "mfa-"
    $set = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
    $profile_mfa += $set | Get-Random
    $profile_mfa += $set | Get-Random
    $profile_mfa += $set | Get-Random
    $profile_mfa += $set | Get-Random
    $profile_mfa += $set | Get-Random
    $profile_mfa += $set | Get-Random
}

## Calculate TTL
$duration_seconds = $ttl * 3600

## Configure for `aws sts get-session-token` command
$profile_tmp="$profile_mfa-tmp"
aws configure set "profile.$profile_tmp.aws_access_key_id" $main_access_key_id
aws configure set "profile.$profile_tmp.aws_secret_access_key" $main_secret_access_key
aws configure set "profile.$profile_tmp.region" $region
aws configure set "profile.$profile_tmp.output" $output
echo "Temporary profile ``$profile_tmp`` has been set."

## Get session token
echo "Start getting session token..."
$result = aws --output json sts get-session-token --serial-number $mfa_arn --token-code $mfa_token --profile $profile_tmp --duration-seconds $duration_seconds
$data = $result | ConvertFrom-Json
if (!$data.Credentials) {
    echo "Error! Exit."
    exit
}
echo "Success! Finish getting session token."

## Create/Update profile
echo "Start setting MFA profile..."

aws configure set "profile.$profile_mfa.aws_access_key_id" $data.Credentials.AccessKeyId
aws configure set "profile.$profile_mfa.aws_secret_access_key" $data.Credentials.SecretAccessKey
aws configure set "profile.$profile_mfa.aws_session_token" $data.Credentials.SessionToken
aws configure set "profile.$profile_mfa.region" $region
aws configure set "profile.$profile_mfa.output" $output

## Clean things up
aws configure set "profile.$profile_tmp.aws_access_key_id" "null"
aws configure set "profile.$profile_tmp.aws_secret_access_key" "null"

if (($profile_to_env -eq "yes") -or ($profile_to_env -eq "Yes") -or ($profile_to_env -eq "y") -or ($profile_to_env -eq "Y")) {
    [Environment]::SetEnvironmentVariable('AWS_PROFILE', $profile_mfa, 'User')
    $Env:AWS_PROFILE = $profile_mfa
    echo "``AWS_PROFILE`` environment variable is now ``$profile_mfa``."
}

## Finish
echo "Success! MFA profile ``$profile_mfa`` has been set."

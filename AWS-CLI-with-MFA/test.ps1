$tmp = [Environment]::GetEnvironmentVariable('AWS_PROFILE', 'User')
echo $tmp

$tmp2 = Get-Item Env:AWS_PROFILE
echo $tmp2

$tmp3 = $Env:AWS_PROFILE
echo $tmp3

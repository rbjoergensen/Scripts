# Create variables once based on application and environment
$Endpoint = "https://lb-lan.cotv.net/nitro/v1"
$AppName  = "MyApp"
$AppEnv   = "Staging"
$FrontIp  = "10.1.4.100"
$LBVS     = "LBVS_"+$AppName+"_"+$AppEnv+"_HTTPS"
$SG       = "SG_"+$AppName+"_"+$AppEnv+"_HTTPS"
$MON      = "MON_"+$AppName+"_"+$AppEnv+"_HTTPS_"

. "\\cotv.net\files\Scripts\Helpers\NetscalerApiHelper.ps1"

# Print the getting started help message
Help

# Start a session with the endpoint
Login

# Exit the session
Logout

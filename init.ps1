###### Script to initialize Aggregate to the customized parameters passed into the docker container ######

# Define paths and default parameters
$basePath = "C:\windows\temp"
$warPath = "$($basePath)\ROOT.war"
$rootPath = "$($basePath)\ROOT"
$sqlserverSettingsPath = "$($basePath)\odk-sqlserver-it-settings-latest"
$sqlserverSettingsJarPath = "$($rootPath)\WEB-INF\lib\odk-sqlserver-it-settings-latest.jar"
$sqlserverSettingsJarBasePath = "$($basePath)\odk-sqlserver-it-settings-latest.jar"
$securityPropertiesPath = "$($sqlserverSettingsPath)\security.properties"
$jdbcPropertiesPath = "$($sqlserverSettingsPath)\jdbc.properties"
$resultPath = "C:\Tomcat\apache-tomcat-8.5.6\webapps\ROOT.war"

$hostnameKey = "security`.server`.hostname="
$portKey = "security`.server`.port="

$database = "odk_unit"
$authKey = "jdbc.url="

$schemaKey="jdbc.schema="
$schemaVal="odk_schema"

# Read environment variable inputs
$hostnameVal = $env:HOSTNAME = "odk-sync`.westus`.cloudapp`.azure`.com"
echo "Read hostname: $($hostnameVal)"

$portVal = $env:PORT = "80"
echo "Read port: $($portVal)"

$dbUser = $env:DB_USER = "mezuri-admin@mezuri-db"
echo "Read db user: $($dbUser)"

$dbPassword = $env:DB_PASS = "Password123"
echo "Read db password: $($dbPassword)"

$sqlServerAddress = $env:SQL_SRV_ADDR = "mezuri-db.database.windows.net:1433"
echo "Read sql server address: $($sqlServerAddress)"

$sqlServerTrustCertificate = $env:SQL_SRV_TRUST_CERT = "false"
echo "Read sql server trust certificate: $($sqlServerTrustCertificate)"

$sqlServerHostnameInCertificate = $env:SQL_SRV_HOST_IN_CERT = "*.database.windows.net"
echo "Read sql server hostname in certificate: $($sqlServerHostnameInCertificate)"

$user = $env:USERNAME
echo "Read user: $($user)"

$authVal = "jdbc:sqlserver://$($sqlServerAddress);database=$($database);user=$($dbUser);password=$($dbPassword);encrypt=true;trustServerCertificate=$($sqlServerTrustCertificate);hostNameInCertificate=$($sqlServerHostnameInCertificate);loginTimeout=30"
echo "Auth String: $($authVal)"

# Define functions for unzipping and rebuilding the war and jar files
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}
function Zip
{
	param([string]$inpath, [string]$zipfile)

    [System.IO.Compression.ZipFile]::CreateFromDirectory($inpath, $zipfile)
}

# Define a function to update a setting in a config file
function UpdateSetting
{
	param([string]$path, [string]$propKey, [string]$propVal)
	
	(Get-Content $path) | ForEach-Object { $_ -replace "$($propKey).+" , "$($propKey)$($propVal)" } | Set-Content $path
}

# Open up the provided war file
Unzip $warPath $rootPath

# Retrieve the old settings
Move-Item $sqlserverSettingsJarPath $sqlserverSettingsJarBasePath
Unzip $sqlserverSettingsJarBasePath $sqlserverSettingsPath

# Update the settings with the configured values
UpdateSetting $securityPropertiesPath $hostnameKey $hostnameVal
UpdateSetting $securityPropertiesPath $portKey $portVal
UpdateSetting $jdbcPropertiesPath $authKey $authVal
UpdateSetting $jdbcPropertiesPath $schemaKey $schemaVal

# Rebuid the settings jar
Zip $sqlserverSettingsPath $sqlserverSettingsJarPath

# Rebuild the root war
Zip $rootPath $resultPath

# Clean up
Remove-Item -Recurse -Force $rootPath
Remove-Item -Recurse -Force $sqlserverSettingsJarBasePath
Remove-Item -Recurse -Force $sqlserverSettingsPath

# Run tomcat
Start-Process -Filepath "C:\Tomcat\apache-tomcat-8.5.6\bin\catalina.bat" run

# Run forever to keep docker alive
while($true)
{
    $i++
}
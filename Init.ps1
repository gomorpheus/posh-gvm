#region Initialization
function Init-Posh-Sdk() {
    Write-Verbose 'Init posh-sdk'

    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'

    Check-JAVA-HOME

    # Check if $Global:PSDK_DIR is available, if not create it
    if ( !( Test-Path "$Global:PSDK_DIR\.meta" ) ) {
        New-Item -ItemType Directory "$Global:PSDK_DIR\.meta" | Out-Null
    }

    # Load candidates cache
    if ( ! (Test-Path $Script:PSDK_CANDIDATES_PATH) ) {
        Update-Candidates-Cache
    }

    Init-Candidate-Cache

    #Setup default paths
    Foreach ( $candidate in $Script:SDK_CANDIDATES ) {
		if ( !( Test-Path "$Global:PSDK_DIR\$candidate" ) ) {
			New-Item -ItemType Directory "$Global:PSDK_DIR\$candidate" | Out-Null
		}

        Set-Env-Candidate-Version $candidate 'current'
    }

    # Check if we can use unzip (which is much faster)
    Check-Unzip-On-Path
}

function Check-JAVA-HOME() {
	# Check for JAVA_HOME, If not set, try to interfere it
    if ( ! (Test-Path env:JAVA_HOME) ) {
        try {
            [Environment]::SetEnvironmentVariable('JAVA_HOME', (Get-Item (Get-Command 'javac').Path).Directory.Parent.FullName)
        } catch {
            throw "Could not find java, please set JAVA_HOME"
        }
    }
}

function Check-Unzip-On-Path() {
    try {
        Get-Command 'unzip.exe' | Out-Null
        $Script:UNZIP_ON_PATH = $true
    } catch {
        $Script:UNZIP_ON_PATH = $false
    }

    try {
        Get-Command '7z.exe' | Out-Null
        $Script:SEVENZ_ON_PATH = $true
    } catch {
        $Script:SEVENZ_ON_PATH = $false
    }
}
#endregion

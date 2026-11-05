# RAI installer — Windows PowerShell
# Usage: irm https://raw.githubusercontent.com/reasonaryai/rai-code/main/install.ps1 | iex

param(
    [string]$Version = "",
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# Each phase records its name so a failure reports what it was doing. A bare
# "Access is denied." carries no context otherwise.
$Step = "start"
$TEMP_ROOT = "(unresolved)"
function Write-StepFailure($errorRecord) {
    $message = if ($errorRecord -is [System.Management.Automation.ErrorRecord]) {
        $errorRecord.Exception.Message
    } else {
        [string]$errorRecord
    }
    Write-Host ""
    Write-Host "ERROR: $Step failed: $message" -ForegroundColor Red
    # Match the exception type and HRESULT, not the localized message text.
    $denied = $false
    if ($errorRecord -is [System.Management.Automation.ErrorRecord]) {
        $ex = $errorRecord.Exception
        $denied = ($ex -is [System.UnauthorizedAccessException]) -or ($ex.HResult -eq -2147024891)
    }
    if ($denied -or $message -match 'denied|UnauthorizedAccess') {
        Write-Host '  This is a permissions failure. The installer writes only to:' -ForegroundColor Yellow
        Write-Host "    temp:    $TEMP_ROOT" -ForegroundColor Yellow
        Write-Host "    install: $INSTALL_DIR" -ForegroundColor Yellow
        Write-Host '  Check those locations, or point them elsewhere before retrying:' -ForegroundColor Yellow
        Write-Host '    $env:TMP  = "$env:USERPROFILE\tmp"' -ForegroundColor Yellow
        Write-Host '    $env:TEMP = "$env:USERPROFILE\tmp"' -ForegroundColor Yellow
        Write-Host '    $env:RAI_INSTALL_DIR = "$env:LOCALAPPDATA\rai\bin"' -ForegroundColor Yellow
    }
}

$REPO = "reasonaryai/rai-code"
$INSTALL_DIR = if ($env:RAI_INSTALL_DIR) { $env:RAI_INSTALL_DIR } else { "$env:LOCALAPPDATA\rai\bin" }

# Release public key. It authenticates checksums.txt, so a tampered archive (or
# an attacker-controlled checksum file) cannot pass verification.
# Owner: run 'task release:keygen' and paste rai-release.pub here.
$RAI_RELEASE_PUBKEY = '-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqisonAhetRCMmT1n/ulr
5AP1FqCa398fNTYtGt/7KeIcTE9/PyHoV5RpwZhbWx2hLKBRLBY6puFXxAWAXOTF
USjSP+MNcjRdSiDkAvjL8N6jwdQoSfaRjKstBy6VgvhQWiwjcH21VgcH98BqC0Nz
ZibXGBM41SPxdDuQZc7FtBnA3z5AmFMydBIOSp+eAloqK9leVAEHIu1QknumndGW
LwIZDvR20nJYQDVlPiRaKqhOqu5ptfvcrFr+HZNjvlXytKiDmbFaEEr1NI0znnx+
9fMCgsGVYzuNeIoSJL+kYLwHSxUHHyjHIodBcqvXYupl3leN/XjVvqxdbHOkAyga
q6mhGSNu6LIi9+aHsw5le656P1xonF9ctiyAw/uV9lmPL7Jk6fbJjHddUxcZwzkS
pwZtKZaCdmeE3fuHWXZOR+iRmYVksUGDiuErr7w13hY8f8lHKqCWyUBrWGT1RwSj
Zt4pTkdEJAM19dh2Mn0cv11wEF7u0tddNMIUZGdrtjBmc5saRKyxZOmV2FUIh4uK
C0zvcf58IKI6DJuBWy8RBgYYJWmUKs6xO1RBpV2LGvygo59dXwhyRxzuPcfWrpae
MTFWbBYntasa/cNVH9O4WY5FO2cvs+kWR2JEbiTUBnckDzIz0AOhgXR+VhQS0NzF
heVGOkn1eh9oHph1j3l0zSECAwEAAQ==
-----END PUBLIC KEY-----'

# Where release assets are downloaded from. Override only for local testing
# (the trust anchor above still decides what is accepted).
$RAI_RELEASE_BASE_URL = if ($env:RAI_RELEASE_BASE_URL) {
    $env:RAI_RELEASE_BASE_URL
} else {
    "https://github.com/$REPO/releases/download"
}

if ($Help) {
    Write-Host "Usage: .\install.ps1 [-Version vX.Y.Z]"
    exit 0
}

Write-Host ""
Write-Host "  ██████╗  █████╗ ██╗     ██████╗ ██████╗ ██████╗ ███████╗"
Write-Host "  ██╔══██╗██╔══██╗██║    ██╔════╝██╔═══██╗██╔══██╗██╔════╝"
Write-Host "  ██████╔╝███████║██║    ██║     ██║   ██║██║  ██║█████╗ "
Write-Host "  ██╔══██╗██╔══██║██║    ██║     ██║   ██║██║  ██║██╔══╝"
Write-Host "  ██║  ██║██║  ██║██║    ╚██████╗╚██████╔╝██████╔╝███████╗"
Write-Host "  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═════╝ ╚═════╝╚══════╝ ╚══════╝"
Write-Host "  Reasonary AI Code — AI-powered coding assistant"
Write-Host ""

$arch = $env:PROCESSOR_ARCHITECTURE
if ($arch -ne "AMD64") {
    Write-Host "ERROR: Unsupported architecture: $arch (only x64 supported)" -ForegroundColor Red
    exit 1
}
$TARGET = "windows-amd64"

# Resolve version
if (-not $Version) {
    $Step = "resolving the latest release"
    Write-Host "-> Resolving latest release..."
    $Version = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/$REPO/main/VERSION").Content.Trim()
}
Write-Host "-> Installing rai $Version ($TARGET)..."

$DOWNLOAD_URL = "$RAI_RELEASE_BASE_URL/$Version/rai-$Version-$TARGET.zip"
$CHECKSUM_URL = "$RAI_RELEASE_BASE_URL/$Version/checksums.txt"
$SIGN_URL = "$RAI_RELEASE_BASE_URL/$Version/checksums.txt.sig"

# Resolve a writable temp root: GetTempPath honours TMP before TEMP and does
# not check writability, so prove the directory works and fall back once to
# %LOCALAPPDATA%\Temp (the standard per-user writable location).
function New-RaiTempDir($root) {
    $dir = Join-Path $root "rai-install-$([System.Guid]::NewGuid())"
    New-Item -ItemType Directory -Force -Path $dir -ErrorAction Stop | Out-Null
    Set-Content -LiteralPath (Join-Path $dir ".write-test") -Value "ok" -ErrorAction Stop
    Remove-Item -LiteralPath (Join-Path $dir ".write-test") -Force -ErrorAction SilentlyContinue
    return $dir
}

$Step = "resolving a writable temporary directory"
$TEMP_ROOT = [System.IO.Path]::GetTempPath()
$TEMP_FALLBACK = Join-Path $env:LOCALAPPDATA "Temp"
$TMPDIR = $null
try {
    $TMPDIR = New-RaiTempDir $TEMP_ROOT
} catch {
    $first = $_.Exception.Message
    if ($TEMP_ROOT -ne $TEMP_FALLBACK) {
        Write-Host "-> $TEMP_ROOT is not writable ($first); trying $TEMP_FALLBACK"
        $TEMP_ROOT = $TEMP_FALLBACK
        try {
            $TMPDIR = New-RaiTempDir $TEMP_FALLBACK
        } catch {
            Write-StepFailure $_
            throw
        }
    } else {
        Write-StepFailure $_
        throw
    }
}

try {
    # Download
    $Step = "downloading $DOWNLOAD_URL"
    Write-Host "-> Downloading..."
    Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile "$TMPDIR\rai.zip"
    Invoke-WebRequest -Uri $CHECKSUM_URL -OutFile "$TMPDIR\checksums.txt"
    try {
        Invoke-WebRequest -Uri $SIGN_URL -OutFile "$TMPDIR\checksums.txt.sig"
    } catch {
        Write-Host "ERROR: missing checksums.txt.sig for $Version - refusing to install an unsigned release" -ForegroundColor Red
        exit 1
    }

    # Verify the release signature before trusting checksums.txt
    if ($RAI_RELEASE_PUBKEY -eq 'PASTE_PUBLIC_KEY_HERE') {
        Write-Host "ERROR: this installer has no release public key embedded (RAI_RELEASE_PUBKEY)." -ForegroundColor Red
        Write-Host "       Owner: run 'task release:keygen' and paste rai-release.pub into install.ps1." -ForegroundColor Red
        exit 1
    }
    $Step = "verifying the release signature"
    Write-Host "-> Verifying release signature..."
    $pubPath = "$TMPDIR\rai-release.pub"
    Set-Content -Path $pubPath -Value $RAI_RELEASE_PUBKEY
    $verified = $false
    if (Get-Command openssl -ErrorAction SilentlyContinue) {
        & openssl dgst -sha256 -verify $pubPath -signature "$TMPDIR\checksums.txt.sig" "$TMPDIR\checksums.txt" | Out-Null
        $verified = ($LASTEXITCODE -eq 0)
    } elseif ($PSVersionTable.PSEdition -eq 'Core') {
        $rsa = [System.Security.Cryptography.RSA]::Create()
        $rsa.ImportFromPem($RAI_RELEASE_PUBKEY)
        $data = [System.IO.File]::ReadAllBytes("$TMPDIR\checksums.txt")
        $sig = [System.IO.File]::ReadAllBytes("$TMPDIR\checksums.txt.sig")
        $verified = $rsa.VerifyData($data, $sig,
            [System.Security.Cryptography.HashAlgorithmName]::SHA256,
            [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)
    } else {
        Write-Host "ERROR: PowerShell 7+ or openssl on PATH is required to verify the release signature." -ForegroundColor Red
        exit 1
    }
    if (-not $verified) {
        Write-Host "ERROR: release signature verification FAILED - refusing to install." -ForegroundColor Red
        exit 1
    }

    # Verify checksum
    $Step = "verifying the archive checksum"
    Write-Host "-> Verifying checksum..."
    $expected = (Select-String -Path "$TMPDIR\checksums.txt" -Pattern "rai-$Version-$TARGET.zip" | ForEach-Object { $_.Line.Split()[0] })
    $actual = (Get-FileHash -Path "$TMPDIR\rai.zip" -Algorithm SHA256).Hash.ToLower()
    if ($expected -ne $actual) {
        Write-Host "ERROR: Checksum mismatch!" -ForegroundColor Red
        Write-Host "  Expected: $expected" -ForegroundColor Red
        Write-Host "  Actual:   $actual" -ForegroundColor Red
        exit 1
    }
    Write-Host "  Checksum OK"

    # Extract
    $Step = "extracting the archive"
    Expand-Archive -Path "$TMPDIR\rai.zip" -DestinationPath "$TMPDIR\extracted"

    # Install
    $Step = "installing rai.exe into $INSTALL_DIR"
    New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null
    Copy-Item -Path "$TMPDIR\extracted\rai.exe" -Destination "$INSTALL_DIR\rai.exe" -Force

    $Step = "preparing the ripgrep search runtime"
    Write-Host "-> Preparing ripgrep search runtime..."
    & "$INSTALL_DIR\rai.exe" ripgrep install
    if ($LASTEXITCODE -ne 0) {
        throw "Ripgrep runtime installation failed. Retry the installer or run rai ripgrep install."
    }

    # Built-in browser tools require no separate npm/Node/Playwright setup.
    $Step = "preparing the browser runtime"
    Write-Host "-> Preparing browser runtime..."
    & "$INSTALL_DIR\rai.exe" browser install
    if ($LASTEXITCODE -ne 0) {
        throw "Browser runtime installation failed. Retry the installer or run rai browser install."
    }

    # Add to PATH for current session
    $Step = "adding $INSTALL_DIR to the user PATH"
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notlike "*$INSTALL_DIR*") {
        [Environment]::SetEnvironmentVariable("PATH", "$userPath;$INSTALL_DIR", "User")
        $env:PATH = "$env:PATH;$INSTALL_DIR"
    }

    Write-Host ""
    Write-Host "  -> Installed: $INSTALL_DIR\rai.exe"
    Write-Host ""
    Write-Host "  Run 'rai' to get started!"
    Write-Host "  (Restart your terminal if 'rai' is not found in PATH)"
} catch {
    Write-StepFailure $_
    # throw, not exit: `irm | iex` runs in the caller's session, and exit would
    # close it before the diagnosis is read. A thrown error also yields a
    # non-zero exit for `powershell -c`.
    throw
} finally {
    Remove-Item -Recurse -Force -LiteralPath $TMPDIR -ErrorAction SilentlyContinue
}

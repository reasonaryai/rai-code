#!/usr/bin/env bash
# RAI installer — Linux & macOS
# Usage: curl -fsSL https://raw.githubusercontent.com/reasonaryai/rai-code/main/install.sh | bash
set -euo pipefail

REPO="reasonaryai/rai-code"
INSTALL_DIR="${RAI_INSTALL_DIR:-$HOME/.local/bin}"
VERSION_FILE="https://raw.githubusercontent.com/$REPO/main/VERSION"
# Where release assets are downloaded from. Override only for local testing
# (the trust anchor below still decides what is accepted).
RAI_RELEASE_BASE_URL="${RAI_RELEASE_BASE_URL:-https://github.com/$REPO/releases/download}"

# Release public key. It authenticates checksums.txt, so a tampered archive
# (or an attacker-controlled checksum file) cannot pass verification.
# Owner: run 'task release:keygen' and paste rai-release.pub here.
RAI_RELEASE_PUBKEY='-----BEGIN PUBLIC KEY-----
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

# TEST-ONLY (used by .github/workflows/install-smoke.yml): trust a throwaway
# key instead of the release key so a locally built fake release can be
# installed. It is honoured only when RAI_INSTALL_TEST=1 AND the release is
# served from this machine (http://127.0.0.1 or http://localhost); against any
# real release URL the embedded key above is the only trust anchor.
if [ "${RAI_INSTALL_TEST:-}" = "1" ] && [ -n "${RAI_TEST_PUBKEY_FILE:-}" ]; then
    case "$RAI_RELEASE_BASE_URL" in
        http://127.0.0.1:*|http://localhost:*) RAI_RELEASE_PUBKEY=$(cat "$RAI_TEST_PUBKEY_FILE") ;;
        *) echo "ERROR: RAI_TEST_PUBKEY_FILE is only allowed with a local release URL" >&2; exit 1 ;;
    esac
fi

RUNTIMES="ask"
VERSION=""
while [ $# -gt 0 ]; do
    case "$1" in
        --version) VERSION="$2"; shift 2 ;;
        --with-runtimes) RUNTIMES="yes"; shift ;;
        --without-runtimes) RUNTIMES="no"; shift ;;
        --help|-h)
            echo "Usage: install.sh [--version vX.Y.Z] [--with-runtimes|--without-runtimes]"
            echo "  Installs rai to $INSTALL_DIR"
            exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

echo ""
echo "  ██████╗  █████╗ ██╗     ██████╗ ██████╗ ██████╗ ███████╗"
echo "  ██╔══██╗██╔══██╗██║    ██╔════╝██╔═══██╗██╔══██╗██╔════╝"
echo "  ██████╔╝███████║██║    ██║     ██║   ██║██║  ██║█████╗ "
echo "  ██╔══██╗██╔══██║██║    ██║     ██║   ██║██║  ██║██╔══╝"
echo "  ██║  ██║██║  ██║██║    ╚██████╗╚██████╔╝██████╔╝███████╗"
echo "  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═════╝ ╚═════╝╚══════╝ ╚══════╝"
echo "  Reasonary AI Code — AI-powered coding assistant"
echo ""

# Detect OS + arch -> target name
OS=$(uname -s)
ARCH=$(uname -m)

case "$OS" in
    Linux)
        case "$ARCH" in
            x86_64|amd64) TARGET="linux-amd64" ;;
            *) echo "ERROR: No rai release binary for Linux $ARCH" >&2; exit 1 ;;
        esac ;;
    Darwin)
        case "$ARCH" in
            arm64|aarch64) TARGET="darwin-arm64" ;;
            x86_64|amd64)  TARGET="darwin-amd64"   ;;
            *) echo "ERROR: Unsupported macOS arch: $ARCH" >&2; exit 1 ;;
        esac ;;
    *) echo "ERROR: Unsupported OS: $OS" >&2; exit 1 ;;
esac

# Resolve latest version if not specified
if [ -z "$VERSION" ]; then
    # Same source as `rai update`: the GitHub latest release first (no CDN
    # cache), the VERSION file only when the API is rate limited or unreachable.
    VERSION=$(curl -fsSL -H 'Accept: application/vnd.github+json' -H 'Cache-Control: no-cache' \
        "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null \
        | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\(v[0-9][0-9.]*\)".*/\1/p' | head -n 1) || VERSION=""
    if [ -z "$VERSION" ]; then
        VERSION=$(curl -fsSL -H 'Cache-Control: no-cache' "$VERSION_FILE?t=$(date +%s)" | tr -d '[:space:]')
    fi
    if [ -z "$VERSION" ]; then
        echo "ERROR: Could not determine latest version" >&2
        exit 1
    fi
fi
# Already installed? The receipt written by a previous install/update records
# the version and the SHA-256 of the file it installed; both must still match.
RECEIPT="$INSTALL_DIR/rai.updated-version"
if [ -f "$INSTALL_DIR/rai" ] && [ -f "$RECEIPT" ]; then
    if command -v shasum >/dev/null 2>&1; then
        CUR_HASH=$(shasum -a 256 "$INSTALL_DIR/rai" | awk '{print $1}')
    else
        CUR_HASH=$(sha256sum "$INSTALL_DIR/rai" | awk '{print $1}')
    fi
    if grep -q "\"Version\":\"${VERSION#v}\"" "$RECEIPT" && grep -q "\"Hash\":\"$CUR_HASH\"" "$RECEIPT"; then
        echo "-> rai $VERSION is already installed in $INSTALL_DIR (nothing to do)."
        echo "   If RAI is open, restart it to use $VERSION."
        exit 0
    fi
fi
echo "-> Installing rai $VERSION ($TARGET)..."

DOWNLOAD_URL="$RAI_RELEASE_BASE_URL/$VERSION/rai-$VERSION-$TARGET.tar.gz"
CHECKSUM_URL="$RAI_RELEASE_BASE_URL/$VERSION/checksums.txt"
SIGN_URL="$RAI_RELEASE_BASE_URL/$VERSION/checksums.txt.sig"

RAI_TMP_DIR=$(mktemp -d)
trap 'rm -rf "$RAI_TMP_DIR"' EXIT

PKG="rai-$VERSION-$TARGET.tar.gz"

# Download
echo "-> Downloading..."
curl -fsSL "$DOWNLOAD_URL" -o "$RAI_TMP_DIR/$PKG"
curl -fsSL "$CHECKSUM_URL" -o "$RAI_TMP_DIR/checksums.txt"
if ! curl -fsSL "$SIGN_URL" -o "$RAI_TMP_DIR/checksums.txt.sig"; then
    echo "ERROR: missing checksums.txt.sig for $VERSION — refusing to install an unsigned release" >&2
    exit 1
fi

# Verify the release signature before trusting checksums.txt
if [ "$RAI_RELEASE_PUBKEY" = "PASTE_PUBLIC_KEY_HERE" ]; then
    echo "ERROR: this installer has no release public key embedded (RAI_RELEASE_PUBKEY)." >&2
    echo "       Owner: run 'task release:keygen' and paste rai-release.pub into install.sh." >&2
    exit 1
fi
if ! command -v openssl >/dev/null 2>&1; then
    echo "ERROR: openssl is required to verify the release signature" >&2
    exit 1
fi
echo "-> Verifying release signature..."
printf '%s\n' "$RAI_RELEASE_PUBKEY" > "$RAI_TMP_DIR/rai-release.pub"
if ! openssl dgst -sha256 -verify "$RAI_TMP_DIR/rai-release.pub" \
        -signature "$RAI_TMP_DIR/checksums.txt.sig" "$RAI_TMP_DIR/checksums.txt" >/dev/null 2>&1; then
    echo "ERROR: release signature verification FAILED — refusing to install." >&2
    exit 1
fi

# Verify checksum
echo "-> Verifying checksum..."
cd "$RAI_TMP_DIR"
EXPECTED=$(awk -v pkg="$PKG" '$2 == pkg {print $1}' checksums.txt)
if [ -z "$EXPECTED" ]; then
    echo "ERROR: Missing checksum for $PKG" >&2
    exit 1
fi
if command -v shasum &>/dev/null; then
    ACTUAL=$(shasum -a 256 "$PKG" | awk '{print $1}')
elif command -v sha256sum &>/dev/null; then
    ACTUAL=$(sha256sum "$PKG" | awk '{print $1}')
else
    echo "ERROR: shasum or sha256sum is required to verify the installer" >&2
    exit 1
fi
if [ "$ACTUAL" != "$EXPECTED" ]; then
    echo "ERROR: Checksum mismatch for $PKG" >&2
    exit 1
fi

# Extract
tar -xzf "$PKG"

# Install
mkdir -p "$INSTALL_DIR"
# Never write over a running binary: Linux answers "Text file busy" and macOS
# invalidates the code signature of the live image, so the process is killed
# and the install looks like it half-worked. Stage beside the target and
# rename, which swaps the file atomically.
STAGED="$INSTALL_DIR/.rai.install.$$"
cp rai "$STAGED"
chmod +x "$STAGED"
if [ "$(uname -s)" = "Darwin" ]; then
    xattr -d com.apple.quarantine "$STAGED" 2>/dev/null || true
fi
mv -f "$STAGED" "$INSTALL_DIR/rai"

# Receipt: open RAI sessions (and the auto-updater) learn this release is
# already on disk and only suggest a restart instead of downloading it again.
if command -v shasum >/dev/null 2>&1; then
    BIN_HASH=$(shasum -a 256 "$INSTALL_DIR/rai" | awk '{print $1}')
else
    BIN_HASH=$(sha256sum "$INSTALL_DIR/rai" | awk '{print $1}')
fi
printf '{"Version":"%s","Hash":"%s"}' "${VERSION#v}" "$BIN_HASH" > "$INSTALL_DIR/rai.updated-version" 2>/dev/null || true

# The installed binary owns prompts, versions and persistent choices.
case "$RUNTIMES" in
    yes) "$INSTALL_DIR/rai" dependencies setup --yes ;;
    no) "$INSTALL_DIR/rai" dependencies setup --later ;;
    *) "$INSTALL_DIR/rai" dependencies setup ;;
esac

echo ""
echo "  -> Installed: $INSTALL_DIR/rai"
case ":${PATH:-}:" in
    *":$INSTALL_DIR:"*) echo "  Run 'rai' to get started!" ;;
    *)
        echo "  -> $INSTALL_DIR is not in this terminal's PATH."
        printf '  Run now: %q\n' "$INSTALL_DIR/rai"
        printf '  To enable the rai command, add this to your shell profile:\n    export PATH=%q:"$PATH"\n' "$INSTALL_DIR"
        ;;
esac
echo "  Update later with: rai update"

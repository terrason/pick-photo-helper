#!/bin/bash
# AUR publish script — called by GitHub Actions on tag push.
set -euo pipefail

AUR_REPO="ssh://aur@aur.archlinux.org/pick-photo-helper.git"
GIT_USER="terrason"
GIT_EMAIL="jterraghost@gmail.com"

# Extract version from tag (e.g. v0.1.0 -> 0.1.0)
ver="${GITHUB_REF_NAME#v}"
echo "==> Publishing version: ${ver}"

# Setup SSH for AUR
echo "==> Setting up SSH..."
mkdir -p ~/.ssh

echo "${AUR_SSH_PRIVATE_KEY}" > ~/.ssh/aur-key
cat ~/.ssh/aur-key
chmod 600 ~/.ssh/aur-key
cat > ~/.ssh/config <<'CONFIG'
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur-key
  StrictHostKeyChecking yes
  User aur
CONFIG
ssh-keyscan -t rsa aur.archlinux.org >> ~/.ssh/known_hosts 2>/dev/null
echo "----------------------------------------------------------------"
sha256sum /home/runner/.ssh/aur-key
echo "----------------------------------------------------------------"
# Clone current AUR repo
echo "==> Cloning AUR repo..."
git clone "${AUR_REPO}" /tmp/aur-repo

# Copy in updated files
cp PKGBUILD pick_photo_helper.py /tmp/aur-repo/
cd /tmp/aur-repo

# Update version
sed -i "s/^pkgver=.*/pkgver=${ver}/" PKGBUILD

# Generate .SRCINFO (no makepkg needed — bash source + templates)
echo "==> Generating .SRCINFO..."
tab=$'\t'
# shellcheck disable=SC1091
source PKGBUILD

cat > .SRCINFO <<SRC
pkgbase = ${pkgname}
${tab}pkgname = ${pkgname}
${tab}pkgver = ${pkgver}
${tab}pkgrel = ${pkgrel}
${tab}pkgdesc = ${pkgdesc}
${tab}url = ${url}
${tab}arch = ${arch}
${tab}license = ${license}
SRC

for dep in "${depends[@]}"; do
	echo "${tab}depends = ${dep}" >> .SRCINFO
done
for opt in "${optdepends[@]}"; do
	echo "${tab}optdepends = ${opt}" >> .SRCINFO
done
cat >> .SRCINFO <<SRC
${tab}source = ${source[0]}
${tab}sha256sums = ${sha256sums[0]}
SRC

# Commit and push
echo "==> Pushing to AUR..."
git config user.name "${GIT_USER}"
git config user.email "${GIT_EMAIL}"
git add -A
git commit -m "Update to ${ver}"
git push

echo "==> Done! pick-photo-helper ${ver} published to AUR."

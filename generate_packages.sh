#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
set -x  # Enable debug mode

# Define the directory containing .deb files
DEB_DIR="./debs"

# Ensure the debs directory exists
if [ ! -d "$DEB_DIR" ]; then
  echo "Directory $DEB_DIR does not exist."
  exit 1
fi

# List contents of DEB_DIR for debugging
ls -l "$DEB_DIR"

# Generate a temporary Packages file with new .deb info
dpkg-scanpackages -m "$DEB_DIR" > Packages.tmp

# If Packages file already exists, merge it with the new Packages
if [ -f Packages ]; then
  # Merge existing Packages with new entries, preserving manual sections
  awk 'NR==FNR{seen[$1]; next} !($1 in seen)' Packages Packages.tmp > Packages.new
  cat Packages.tmp >> Packages.new
  mv Packages.new Packages
else
  # If Packages doesn't exist, move the temp file to Packages
  mv Packages.tmp Packages
fi

# Output Packages file for verification
cat Packages

# Compress the Packages file
bzip2 -fks Packages
gzip -fk Packages

# Create the Release file
cat <<EOF > Release
Origin: Axs Repo
Label: Axs Repo
Suite: stable
Version: 1.0
Codename: axs
Architectures: iphoneos-arm iphoneos-arm64 iphoneos-arm64e
Components: main
Description: 自用插件分享，有问题请卸载！！！
EOF

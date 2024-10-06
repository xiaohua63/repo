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

# Create a temporary Packages file to hold new data
TEMP_PACKAGES=$(mktemp)

# Generate the Packages file
dpkg-scanpackages -m "$DEB_DIR" > "$TEMP_PACKAGES"

# If the Packages file exists, merge manually edited sections
if [ -f Packages ]; then
  # Create a merged Packages file
  cat Packages "$TEMP_PACKAGES" | sort -u > Packages.merged
  mv Packages.merged Packages
else
  # If no existing Packages file, just rename the temporary file
  mv "$TEMP_PACKAGES" Packages
fi

# Compress the Packages file
bzip2 -fks Packages
gzip -fk Packages

# Create the Release file
cat <<EOF > Release
Origin: Axs Repo
Label: Axs Repo
Suite: stable
Version: 1.0
Codename: Axs Repo
Architectures: iphoneos-arm64 iphoneos-arm64e
Components: main
Description: 自用插件分享，有问题请卸载！！！
EOF

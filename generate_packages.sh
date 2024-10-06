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

# 定义自定义的 Section 文件
CUSTOM_SECTIONS_FILE="./custom_sections.txt"

# 先保存自定义 Section 到临时文件
if [ -f "$CUSTOM_SECTIONS_FILE" ]; then
    cp "$CUSTOM_SECTIONS_FILE" custom_sections_backup.txt
fi

# Generate the Packages file
dpkg-scanpackages -m "$DEB_DIR" > Packages

# 合并自定义的 Section 信息
if [ -f "custom_sections_backup.txt" ]; then
    cat custom_sections_backup.txt >> Packages
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

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

# Check if there are any .deb files in the DEB_DIR
if ls "$DEB_DIR"/*.deb 1> /dev/null 2>&1; then
  # 先备份原来的 Packages 文件
  if [ -f Packages ]; then
    cp Packages Packages.bak
  fi

  # Generate the Packages file
  dpkg-scanpackages -m "$DEB_DIR" > Packages

  # 将备份的内容合并到新生成的 Packages 文件中
  if [ -f Packages.bak ]; then
    cat Packages.bak >> Packages
    sort -u Packages -o Packages  # 去重
    rm Packages.bak  # 删除备份文件
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
else
  echo "No .deb files found in $DEB_DIR. Skipping package generation."
fi

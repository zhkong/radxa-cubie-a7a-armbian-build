#!/bin/bash

# This script is executed inside the chroot during image creation.
# It replaces default Debian and Armbian repository sources with USTC mirrors.
# Runs before first boot — no user intervention required.

RELEASE=${RELEASE:-trixie}

# --- Debian USTC Mirror (DEB822 format for Debian 13+) ---

cat > /etc/apt/sources.list.d/debian.sources << EOF
Types: deb
URIs: https://mirrors.ustc.edu.cn/debian/
Suites: ${RELEASE} ${RELEASE}-updates ${RELEASE}-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

cat > /etc/apt/sources.list.d/debian-security.sources << EOF
Types: deb
URIs: https://mirrors.ustc.edu.cn/debian-security/
Suites: ${RELEASE}-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

# --- Armbian USTC Mirror ---

ARMBIAN_SOURCES="/etc/apt/sources.list.d/armbian.list"
ARMBIAN_SOURCES_DEB822="/etc/apt/sources.list.d/armbian.sources"

if [ -f "$ARMBIAN_SOURCES_DEB822" ]; then
	cat > "$ARMBIAN_SOURCES_DEB822" << EOF
Types: deb
URIs: https://mirrors.ustc.edu.cn/armbian/
Suites: ${RELEASE}
Components: main
Signed-By: /usr/share/keyrings/armbian.gpg
EOF
elif [ -f "$ARMBIAN_SOURCES" ]; then
	echo "deb [signed-by=/usr/share/keyrings/armbian.gpg] https://mirrors.ustc.edu.cn/armbian/ ${RELEASE} main" > "$ARMBIAN_SOURCES"
fi

# Remove legacy sources.list if present to avoid duplicate entries
if [ -f /etc/apt/sources.list ]; then
	: > /etc/apt/sources.list
fi

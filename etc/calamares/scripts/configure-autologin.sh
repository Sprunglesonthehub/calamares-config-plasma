#!/bin/bash

# Get the first non-root, non-system user
NEW_USER=$(grep '/home' /etc/passwd | grep -v '/home/\(lost+found\|sddm\)' | cut -d: -f1 | head -1)

# If a user was found, configure SDDM autologin
if [ -n "$NEW_USER" ]; then
    # Remove any existing SDDM autologin configuration
    if [ -d "/etc/sddm.conf.d" ]; then
        rm -f /etc/sddm.conf.d/autologin.conf
    else
        mkdir -p /etc/sddm.conf.d/
    fi

    # Also check for and remove legacy configuration if it exists
    if [ -f "/etc/sddm.conf" ]; then
        # Create backup of original file
        cp /etc/sddm.conf /etc/sddm.conf.bak
        # Remove any existing Autologin section from the file
        sed -i '/^\[Autologin\]/,/^\[/d' /etc/sddm.conf
    fi

    # Create new autologin configuration
    cat > /etc/sddm.conf.d/autologin.conf << EOF
[Autologin]
User=$NEW_USER
Session=plasma.desktop
Relogin=false
EOF
    echo "SDDM autologin configured for user: $NEW_USER"
else
    echo "No suitable user found for SDDM autologin"
fi

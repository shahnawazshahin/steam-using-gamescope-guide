#!/bin/bash

# Check if the script is run with sudo privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use 'sudo ./installer.sh'"
    exit 1
fi

# Set up variables for this script
SCRIPT_PERMISSIONS="755"
SESSION_FILE_PERMISSIONS="644"
STEAMOS_POLKIT_HELPERS_DIR="steamos-polkit-helpers"
USR_BIN_DIR="/usr/bin"
WAYLAND_SESSIONS_DIR="/usr/share/wayland-sessions"

# Get the username
USERNAME=$(logname 2>/dev/null || echo $SUDO_USER || echo $USER)

# Ensure the scripts have the correct permissions set
#
# 'gamescope-session'
chmod $SCRIPT_PERMISSIONS .$USR_BIN_DIR/gamescope-session

# 'jupiter-biosupdate'
chmod $SCRIPT_PERMISSIONS .$USR_BIN_DIR/jupiter-biosupdate
chmod $SCRIPT_PERMISSIONS .$USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/jupiter-biosupdate

# 'steamos-select-branch'
chmod $SCRIPT_PERMISSIONS .$USR_BIN_DIR/steamos-select-branch

# 'steamos-session-select'
chmod $SCRIPT_PERMISSIONS .$USR_BIN_DIR/steamos-session-select

# 'steamos-update'
chmod $SCRIPT_PERMISSIONS .$USR_BIN_DIR/steamos-update
chmod $SCRIPT_PERMISSIONS .$USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/steamos-update

# 'steamos-set-timezone'
chmod $SCRIPT_PERMISSIONS .$USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/steamos-set-timezone

# Ensure the session file has the correct permissions set
#
# 'steam.desktop'
chmod $SESSION_FILE_PERMISSIONS .$WAYLAND_SESSIONS_DIR/steam.desktop

# Create a 'steamos-polkit-helpers' folder under '/usr/bin'
sudo mkdir -p $USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR

# Copy the following scripts to the /usr/bin folder
#
# 'gamescope-session'
sudo cp .$USR_BIN_DIR/gamescope-session \
    $USR_BIN_DIR/gamescope-session

# 'jupiter-biosupdate'
sudo cp .$USR_BIN_DIR/jupiter-biosupdate \
    $USR_BIN_DIR/jupiter-biosupdate
sudo cp .$USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/jupiter-biosupdate \
    $USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/jupiter-biosupdate

# 'steamos-select-branch'
sudo cp .$USR_BIN_DIR/steamos-select-branch \
    $USR_BIN_DIR/steamos-select-branch

# 'steamos-session-select'
sudo cp .$USR_BIN_DIR/steamos-session-select \
    $USR_BIN_DIR/steamos-session-select

# 'steamos-update'
sudo cp .$USR_BIN_DIR/steamos-update \
    $USR_BIN_DIR/steamos-update
sudo cp .$USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/steamos-update \
    $USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/steamos-update

# 'steamos-set-timezone'
sudo cp .$USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/steamos-set-timezone \
    $USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/steamos-set-timezone

# Copy the following scripts to the /usr/share folder
#
# 'steam.desktop'
sudo cp .$WAYLAND_SESSIONS_DIR/steam.desktop \
    $WAYLAND_SESSIONS_DIR/steam.desktop

# Ask user about autologin configuration
echo
read -p "Do you want to enable autologin to the Steam gamescope session? (y/N) " -r
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    echo
    echo "Which display manager are you using?"
    echo "1) LightDM"
    echo "2) SDDM"
    echo "3) GDM/GDM3"
    echo "4) I don't know / Skip autologin"
    echo
    read -p "Enter your choice (1-4): " DM_CHOICE
    
    case "$DM_CHOICE" in
        1)
            echo "Configuring LightDM autologin for user: $USERNAME"
            
            # Backup and configure LightDM
            if [ -f /etc/lightdm/lightdm.conf ]; then
                cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.backup.$(date +%Y%m%d_%H%M%S)
            fi
            
            mkdir -p /etc/lightdm/lightdm.conf.d/
            cat > /etc/lightdm/lightdm.conf.d/50-gamescope-autologin.conf <<EOF
[Seat:*]
autologin-user=$USERNAME
autologin-session=steam
autologin-user-timeout=0
EOF
            
            # Add user to autologin group if it exists
            if getent group autologin > /dev/null 2>&1; then
                usermod -a -G autologin $USERNAME
            fi
            
            echo "LightDM autologin configured!"
            ;;
            
        2)
            echo "Configuring SDDM autologin for user: $USERNAME"
            
            # Backup and configure SDDM
            mkdir -p /etc/sddm.conf.d/
            cat > /etc/sddm.conf.d/autologin.conf <<EOF
[Autologin]
User=$USERNAME
Session=steam
Relogin=false

[General]
DisplayServer=wayland
EOF
            
            echo "SDDM autologin configured!"
            ;;
            
        3)
            echo "Configuring GDM autologin for user: $USERNAME"
            
            # Find GDM config path
            if [ -f /etc/gdm3/custom.conf ]; then
                GDM_CONF="/etc/gdm3/custom.conf"
            elif [ -f /etc/gdm/custom.conf ]; then
                GDM_CONF="/etc/gdm/custom.conf"
            else
                echo "Error: Could not find GDM configuration file"
                echo "Skipping autologin configuration"
                GDM_CONF=""
            fi
            
            if [ -n "$GDM_CONF" ]; then
                # Backup existing config
                cp "$GDM_CONF" "${GDM_CONF}.backup.$(date +%Y%m%d_%H%M%S)"
                
                # Update or add autologin settings
                if grep -q "^\[daemon\]" "$GDM_CONF"; then
                    # Section exists, update it
                    sed -i '/^\[daemon\]/,/^\[/ {
                        s/^AutomaticLoginEnable=.*/AutomaticLoginEnable=true/
                        s/^AutomaticLogin=.*/AutomaticLogin='$USERNAME'/
                    }' "$GDM_CONF"
                    
                    # Add lines if they don't exist
                    if ! grep -q "^AutomaticLoginEnable=" "$GDM_CONF"; then
                        sed -i "/^\[daemon\]/a AutomaticLoginEnable=true" "$GDM_CONF"
                    fi
                    if ! grep -q "^AutomaticLogin=" "$GDM_CONF"; then
                        sed -i "/^\[daemon\]/a AutomaticLogin=$USERNAME" "$GDM_CONF"
                    fi
                else
                    # Section doesn't exist, add it
                    echo "" >> "$GDM_CONF"
                    echo "[daemon]" >> "$GDM_CONF"
                    echo "AutomaticLoginEnable=true" >> "$GDM_CONF"
                    echo "AutomaticLogin=$USERNAME" >> "$GDM_CONF"
                fi
                
                echo "GDM autologin configured!"
            fi
            ;;
            
        *)
            echo "Skipping autologin configuration."
            ;;
    esac
    
    if [[ "$DM_CHOICE" =~ ^[1-3]$ ]]; then
        echo
        echo "Installation complete with autologin enabled!"
        echo "You can now:"
        echo "1. Reboot your system to automatically start in gaming mode"
        echo "   OR"
        echo "2. Log out and select 'Steam (gamescope)' from your display manager"
        echo
        read -p "Would you like to reboot now? (y/n): " -r
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
            echo "Rebooting..."
            sleep 2
            reboot
        fi
    fi
else
    echo
    echo "Installation complete!"
    echo "You can now log out and select 'Steam (gamescope)' from your display manager."
fi
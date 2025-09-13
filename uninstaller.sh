#!/bin/bash

# Check if the script is run with sudo privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use 'sudo ./uninstaller.sh'"
    exit 1
fi

# Set up variables for this script
STEAMOS_POLKIT_HELPERS_DIR="steamos-polkit-helpers"
USR_BIN_DIR="/usr/bin"
WAYLAND_SESSIONS_DIR="/usr/share/wayland-sessions"


USERNAME=$(logname 2>/dev/null || echo "$SUDO_USER" || echo "$USER")

echo "Starting Steam Gamescope session uninstallation..."

# Remove the following scripts from the /usr/bin folder
#
# 'gamescope-session'
[ -f $USR_BIN_DIR/gamescope-session ] && sudo rm $USR_BIN_DIR/gamescope-session

# 'jupiter-biosupdate'
[ -f $USR_BIN_DIR/jupiter-biosupdate ] && sudo rm $USR_BIN_DIR/jupiter-biosupdate
[ -f $USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/jupiter-biosupdate ] && sudo rm $USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/jupiter-biosupdate

# 'steamos-select-branch'
[ -f $USR_BIN_DIR/steamos-select-branch ] && sudo rm $USR_BIN_DIR/steamos-select-branch

# 'steamos-session-select'
[ -f $USR_BIN_DIR/steamos-session-select ] && sudo rm $USR_BIN_DIR/steamos-session-select

# 'steamos-update'
[ -f $USR_BIN_DIR/steamos-update ] && sudo rm $USR_BIN_DIR/steamos-update
[ -f $USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/steamos-update ] && sudo rm $USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/steamos-update

# 'steamos-set-timezone'
[ -f $USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/steamos-set-timezone ] && sudo rm $USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR/steamos-set-timezone

# Remove the following scripts from the /usr/share folder
#
# 'steam.desktop'
[ -f $WAYLAND_SESSIONS_DIR/steam.desktop ] && sudo rm $WAYLAND_SESSIONS_DIR/steam.desktop

# Remove the 'steamos-polkit-helpers' folder under '/usr/bin'
[ -d $USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR ] && sudo rm -rf $USR_BIN_DIR/$STEAMOS_POLKIT_HELPERS_DIR

# Remove the steamos-autologin script if it exists
[ -f $USR_BIN_DIR/steamos-autologin ] && sudo rm $USR_BIN_DIR/steamos-autologin

# Ask about removing autologin configuration
echo
read -p "Do you want to remove Steam gamescope autologin configuration? (y/N) " -r
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    # Use the steamos-autologin script if available (during uninstall, it might still be available temporarily)
    if [ -f ./steamos-autologin ]; then
        echo
        echo "Disabling autologin for user: $USERNAME"
        sudo ./steamos-autologin disable "$USERNAME"
    else
        # Fallback to manual removal if script is not available
        echo
        echo "Which display manager autologin should be removed?"
        echo "1) LightDM"
        echo "2) SDDM"
        echo "3) GDM/GDM3"
        echo "4) All of the above"
        echo "5) Skip autologin removal"
        echo
        read -r -p "Enter your choice (1-5): " DM_CHOICE
        
        remove_lightdm_autologin() {
            # Remove LightDM autologin configuration
            if [ -f /etc/lightdm/lightdm.conf.d/50-gamescope-autologin.conf ]; then
                rm /etc/lightdm/lightdm.conf.d/50-gamescope-autologin.conf
                echo "Removed LightDM autologin configuration"
            fi
            
            # Remove user from autologin group if no other autologin configs exist
            if getent group autologin > /dev/null 2>&1; then
                if ! find /etc/lightdm/lightdm.conf.d/ -name "*autologin*" 2>/dev/null | grep -q .; then
                    gpasswd -d "$USERNAME" autologin 2>/dev/null || true
                    echo "Removed $USERNAME from autologin group"
                fi
            fi
        }
        
        remove_sddm_autologin() {
            # Remove SDDM autologin configuration
            if [ -f /etc/sddm.conf.d/autologin.conf ]; then
                rm /etc/sddm.conf.d/autologin.conf
                echo "Removed SDDM autologin configuration"
            fi
        }
        
        remove_gdm_autologin() {
            # Find GDM config path
            local GDM_CONF=""
            if [ -f /etc/gdm3/custom.conf ]; then
                GDM_CONF="/etc/gdm3/custom.conf"
            elif [ -f /etc/gdm/custom.conf ]; then
                GDM_CONF="/etc/gdm/custom.conf"
            fi
            
            if [ -n "$GDM_CONF" ] && [ -f "$GDM_CONF" ]; then
                # Disable autologin in GDM
                if grep -q "^AutomaticLoginEnable=true" "$GDM_CONF"; then
                    sed -i 's/^AutomaticLoginEnable=true/AutomaticLoginEnable=false/' "$GDM_CONF"
                    sed -i 's/^AutomaticLogin=.*/AutomaticLogin=/' "$GDM_CONF"
                    echo "Disabled GDM autologin"
                fi
            fi
        }
        
        case "$DM_CHOICE" in
            1)
                remove_lightdm_autologin
                ;;
            2)
                remove_sddm_autologin
                ;;
            3)
                remove_gdm_autologin
                ;;
            4)
                echo "Removing all autologin configurations..."
                remove_lightdm_autologin
                remove_sddm_autologin
                remove_gdm_autologin
                ;;
            *)
                echo "Skipping autologin removal."
                ;;
        esac
    fi
fi

echo
echo "Uninstallation complete!"
echo "The Steam gamescope session has been removed from your system."

# Offer to restore from backups if they exist
echo
if ls /etc/lightdm/lightdm.conf.backup.* 2>/dev/null || \
   ls /etc/sddm.conf.backup.* 2>/dev/null || \
   ls /etc/gdm*/custom.conf.backup.* 2>/dev/null; then
    echo "Backup configuration files were found:"
    ls -la /etc/lightdm/lightdm.conf.backup.* 2>/dev/null || true
    ls -la /etc/sddm.conf.backup.* 2>/dev/null || true
    ls -la /etc/gdm*/custom.conf.backup.* 2>/dev/null || true
    echo
    echo "You can manually restore these if needed."
fi
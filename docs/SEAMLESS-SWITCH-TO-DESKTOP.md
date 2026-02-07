# Seamless `Switch to Desktop`

## Background

The experience on a Steam Deck provides a seamless switch between SteamOS mode and the desktop without presenting the login screen.

This section helps to recreate the experience using a minimalist approach, which has not been covered in the [GUIDE.md](https://github.com/shahnawazshahin/steam-using-gamescope-guide/blob/main/docs/GUIDE.md).

## Before we begin

The following are assumed:

- The [README.md](https://github.com/shahnawazshahin/steam-using-gamescope-guide/blob/main/README.md) or [GUIDE.md](https://github.com/shahnawazshahin/steam-using-gamescope-guide/blob/main/docs/GUIDE.md) has been followed for setting up SteamOS mode using Gamescope.
- The `locate` tool and `command` utility are installed on your system.
- A separate `steam` Linux user account set up on your system.

### Why are the `locate` tool and `command` utility required?

To get the full path of the desktop environment the `command` utility is used. This is usually included as a core utility with Linux distributions. You can check by running `command --help` from a terminal.

The `locate` tool is required to locate the full path of `plasma-dbus-run-session-if-needed`, which is required for running the Plasma desktop with Wayland. Unfortunately, the full path for `plasma-dbus-run-session-if-needed` differs between each distribution, but thankfully the `locate` tool can help with this.

The `plocate` package (which includes the `locate` tool) isn't usually installed on some Linux distributions. Check by running `locate --help` from a terminal to see if it is available. If not, follow the documents provided by the Linux distribution maintainer on how to install `plocate`. For example, with the following distributions:

- Arch Linux

```bash
  sudo pacman -Sy plocate
  sudo updatedb
```

- Fedora Linux

```bash
  sudo dnf install plocate
  sudo updatedb
```

### Why a separate `steam` Linux user account on my system?

This is important to consider this as a safety measure if multiple users are going to share the system and using autologin. This is because:

- The same Linux user account will be used when switching from SteamOS mode to the desktop, irrespective of the Steam user logged in, when autologin is used.

Also note that:

- The Steam client is installed at the user level, including the games.

- Multiple Steam user accounts can be logged in to Steam on the same instance running the single Linux user account.

To prevent any personal data being shared across different users, create a standard Linux user account (without privileged or `sudo` access). This can be set up within your desktop environment, or by running the following command line (for example):

```bash
sudo useradd -m steam
```

## Instructions

- Creating a copy of the `gamescope-session` script.

- Modifying the copy of the script to include a loop that switches between SteamOS mode and the desktop environment.

- Adding a check to ensure that only the `steam` user account can execute the copy of the script.

- Adding a new session in the display manager to invoke the new script.

- If required, enable autologin.

### 1. Copy the `gamescope-session` script

- Using a code editor, copy the `gamescope-session` in the `Developer` folder to a script called `gamescope-session-manager`

  - Alternatively, use the command line to copy the `gamescope-session` file to `gamescope-session-manager`

  ```bash 
  cp ~\Developer\gamescope-session ~\Developer\gamescope-session-manager
  ```

### 2. Add loop to the `gamescope-session-manager` script

- Using the code editor, modify the `gamescope-session-manager` to include a loop around the SteamOS mode launch.

    `~/Developer/gamescope-session-manager`

    ---
    ```bash
    #!/bin/bash

    MANGOAPP_OPT=""

    if command -v mangoapp &>/dev/null;
    then
    MANGOAPP_OPT="--mangoapp"
    fi

    while true; do  # Add start of loop
    gamescope $MANGOAPP_OPT -e -- steam -steamdeck -steamos3
    done # Add end of loop
    ```

### 3. Add a step to launch the desktop environment

- Depending on the desktop environment used, add either of the following lines to the `gamescope-session-manager` script after the launching of SteamOS mode.

  - For KDE Plasma Wayland:

  ```bash
  "$(locate plasma-dbus-run-session-if-needed)" "$(command -v startplasma-wayland)"
  ```

  - For Gnome:

  ```bash
  "$(command -v gnome-session)"
  ```

  - For Gnome Classic:

  ```bash
  env GNOME_SHELL_SESSION_MODE=classic "$(command -v gnome-session)"
  ```

  - For Cinnamon:

  ```bash
  "$(command -v cinnamon-session)"
  ```

  - For Ubuntu:

  ```bash
  "$(command -v cinnamon-session)"
  ```

  For example:

    `~/Developer/gamescope-session-manager`

    ---
    ```bash
    #!/bin/bash

    MANGOAPP_OPT=""

    if command -v mangoapp &>/dev/null; then
      MANGOAPP_OPT="--mangoapp"
    fi

    while true; do  # Add start of loop
      gamescope $MANGOAPP_OPT -e -- steam -steamdeck -steamos3

      # Add line to launch desktop
      "$(locate plasma-dbus-run-session-if-needed)" "$(command -v startplasma-wayland)"
    done  # Add end of loop
    ```

### 4. Add check for `steam` Linux user account

- To ensure this script is only executed by a single Linux user account (i.e., `steam` user account) add the following lines at the start of the `gamescope-session-manager` script

    `~/Developer/gamescope-session-manager`

    ---
    ```bash
    #!/bin/bash

    # Add check if `steam` Linux user account exists on the system
    getent passwd steam > /dev/null 2>&1 || exit 1

    MANGOAPP_OPT=""

    if command -v mangoapp &>/dev/null;
    then
    MANGOAPP_OPT="--mangoapp"
    fi

    while true; do  # Add start of loop
    gamescope $MANGOAPP_OPT -e -- steam -steamdeck -steamos3

    # Add line to launch desktop
    "$(locate plasma-dbus-run-session-if-needed)" "$(command -v startplasma-wayland)"
    done # Add end of loop
    ```

- From the terminal, set the permissions of the scripts with execute, and copy them to the following

  ```bash
  chmod +x ~/Developer/gamescope-session-manager
  ```
  ```bash
  sudo cp ~/Developer/gamescope-session-manager /usr/bin/
  ```

### 5. Add a new session option in the display manager

Let's add a configuation file to launch into SteamOS mode from the login screen (display manager) that seamlessly switchs to the desktop.

- (If it does not exist already) create a `Developer` folder in your `HOME` location using a file manager or from the command line as follows

  > `mkdir ~/Developer`

- Using the code editor, create a new file called `steam-seamless.desktop` in the `Developer` folder, add the following lines to the file and then save the file

  `~/Developer/steam-seamless.desktop`

  ---
  ```bash
  [Desktop Entry]
  Encoding=UTF-8
  Name=SteamOS seamless mode (Gamescope)
  Comment=Run SteamOS mode using Gamescope with seamless desktop switching 
  Exec=gamescope-session-manager
  Type=Application
  DesktopNames=gamescope
  ```

- From the terminal, copy the `steam-seamless.desktop` file into `/usr/share/wayland-sessions/` folder

  ```bash
  sudo cp ~/Developer/steam-seamless.desktop /usr/share/wayland-sessions/
  ```

- Log off from the desktop environment (e.g., KDE Plasma, Gnome).

- Follow the next steps based on the display manager used:

  - For SDDM, on the login screen select `SteamOS seamless mode (Gamescope)` from the session selection (located near the bottom left corner of the screen). Use the same login and password as you would log on to the linux desktop.
  
  - For GDM, on the login screen select your username and then select `SteamOS seamless mode (Gamescope)` from the session selection (located near the bottom right corner of the screen). Use the same password as you would log on to the linux desktop.

- This will launch Steam full screen in Gamescope and SteamOS mode.

At this point, the set up screen in SteamOS mode cannot be completed without helper scripts. The next following steps will fix these issues.

### 6. (Optional) Enable autologin

Each display manager has its own configuration files, and in most cases can be configured within the desktop environment. 

Alternatively, the following are guidelines on how to set up autologin by hand *(again, check with the relevant web resources from the Linux distribution maintainer for the most up-to-date information)*:

- For SDDM (typically used by KDE Plasma), create or edit the `autologin.conf` file and include the following (using `sudo`):

  /etc/sddm.conf.d/autologin.conf
  
  ---
  ```bash
  [Autologin]
  User=steam
  Session=steam-seamless
  ```

- For LightDM (typically used by Cinnamon), edit the `lightdm.conf` file to uncomment and adjust the following (using `sudo`):

  /etc/lightdm/lightdm.conf
  
  ---
  ```bash
  [Seat:*]
  autologin-user=steam
  autologin-session=steam-seamless
  ```
  Then run the following command so that the `steam` Linux user account is part of the autologin group:

  ```bash
  sudo groupadd -r autologin
  ```
  ```bash
  sudo usermod -aG autologin steam
  ```

- For GDM (typically used by Gnome and Ubuntu), add the following to the `custom.conf` file (using `sudo`):

  /etc/gdm/custom.conf
  
  ---
  ```bash
  [daemon]
  AutomaticLoginEnable=True
  AutomaticLogin=steam
  ```

  Then set the session to use for the `steam` Linux user account (using `sudo`):

  /var/lib/AccountsService/users/steam
  
  ---
  ```bash
  [User]
  Session=steam-seamless
  ```
## Why these step-by-step instructions are required?

### 1. Copy the `gamescope-session` script

To ensure the basic functionality remains intact, it is recommended to copy the original `gamescope-session` script to a new file (i.e., `gamescope-session-manager`). This way, you can revert back to the original configuration.

### 2. Add loop to the `gamescope-session-manager` script

This is a simple, endless loop that will be used to switch between SteamOS mode and the desktop. What happens in the loop is the following:

- Launch into SteamOS mode and wait until the user selects `Switch to Desktop`.

- When `Switch to Desktop` is selected in SteamOS mode, it invokes the `steamos-session-select` script to shutdown Steam. Once gracefully shutdown, continue the loop.

- Launch the desktop and wait until the user logs out of the desktop session.

- When the user logs out from the desktop, return to the beginning of the loop and repeat the process.

### 3. Add a step to launch the desktop environment

Depending on the desktop environment installed on the system, this is added to the script to launch the desktop. Without it, the loop will continuously relaunch into SteamOS mode each time `Switch to Desktop` is selected.

### 4. Add check for `steam` Linux user account

It is highly advised to create a separate, standard Linux user account (i.e., a `steam` user account) as it will automatically switch to the desktop without prompting a password. 

This is especially important if the session is to be shared by multiple users and to prevent any personal data being shared.

Also note that a separate Steam instance is installed for each Linux user account, which separates the games installed by default.

### 5. Add a new session option in the display manager

This adds another session option in the display manager (i.e., login screen) that the user can select, similar to the `SteamOS mode (Gamescope)` option. It will appear as `SteamOS seamless mode (Gamescope)`.

### 6. (Optional) Enable autologin

Enabling autologin to launch into `SteamOS seamless mode (Gamescope)` will give you an experience similar to the Steam Deck. Again, it is advised to create a separate, standard Linux user account if the session is to be shared by multiple users to prevent personal data being shared.

## Acknowledgements

- [vigneshiamvk](https://github.com/vigneshiamvk) for the idea to loop between SteamOS mode and the desktop environment.

- [vlshields](https://github.com/vlshields) for the discussion and information on the autologin configuration.

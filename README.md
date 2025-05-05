# Steam using Gamescope guide (aka DIY SteamOS mode)

A guide for setting up your favourite Linux distribution to launch Steam into SteamOS mode from the display manager (login screen) using Gamescope.

## Background

SteamOS is an Arch Linux based operating system developed by Valve. It is a gaming focused operating system for Steam Deck and other devices from partners working closely with Valve. At the moment, SteamOS isn't officially supported to run on different computers.

There are other Linux distributions, however, that leverages the excellent work from Valve and the community to provide excellent alternatives such as [Bazzite](https://bazzite.gg/) and the [Nobara Project](https://nobaraproject.org/). They've contributed additional tools and fixes to provide a SteamOS experience for different computers, making it quick and easy to set up a gaming rig with a console-like experience.

Various scripts, tools, patches, and policies are included in SteamOS and other related distributions to provide an optimised experience. However, the fundamental components for SteamOS mode to work are:

* The Steam client for Linux for the frontend.
* A microcompositor called [Gamescope](https://github.com/ValveSoftware/gamescope).

Both the Steam client for Linux and Gamescope are available for a variety of Linux distributions. Therefore, it is possible for *`anyone`* to launch into SteamOS mode from their Linux desktop of their choice (with a caveat - more on that later).

## Purpose

This guide will explain how to set up your Linux install to launch into SteamOS mode from the display manager (e.g., login screen). No complicated scripts or configurations are required.

* To help get set up quickly and easy, continue following this `README.md` guide.
* For details on how this all works, head over to the [wiki page](https://github.com/shahnawazshahin/steam-using-gamescope-guide/wiki/Steam-using-Gamescope-guide-%E2%80%90-Wiki-page).

### Why do this?

* The freedom to use any Linux distribution that supports Gamescope and Steam client for Linux - you don't need SteamOS or similar distributions to get the SteamOS experience.
* The freedom to use any desktop environment of your choice (e.g., [Plasma Desktop](https://kde.org/plasma-desktop/), [Gnome](https://www.gnome.org/), [Cinnamon](https://github.com/linuxmint/Cinnamon), etc).
* A much simpler way to launch into SteamOS mode directly from the display manager (login screen) (e.g., [SDDM](https://github.com/sddm/sddm), [GDM](https://wiki.gnome.org/Projects/GDM)), without any complex scripts, PolicyKit configurations, and unnecessary updates.
* To understand (and appreciate) the excellent work that Valve, the community, and their partners have put in to SteamOS.

## Before we begin

For a detailed guide on how this all works, please refer to the [wiki page](https://github.com/shahnawazshahin/steam-using-gamescope-guide/wiki/Steam-using-Gamescope-guide-%E2%80%90-Wiki-page).

The following are assumed:

* A PC with an AMD iGPU or AMD dedicated GPU.
* A display manager (SDDM and GDM have been tested).
* Steam client for Linux is installed.
* Gamescope is available on your Linux distribution of choice.
* MangoHud is available on the Linux distribution of choice.

Please take time in going through this `README.md` guide so that you feel confident before proceeding and to avoid any issues.

### Why these requirements?

#### A PC with an AMD iGPU or AMD dedicated GPU?

[Gamescope](https://github.com/ValveSoftware/gamescope) is designed to run on Mesa + AMD with minimal effort, and hence Gamescope works very well with AMD GPUs.

Whilst Intel GPUs isn't yet supported it can work but is a bit hit and miss - the experience may be suboptimal.

Gamescope is known to work with NVIDIA GPUs, but unfortunately it can occasionally break when either NVIDIA drivers for Linux or Gamescope are updated.

#### A display manager and desktop environment installed?

An option will be added to the session selector in the display manager to select from and log in directly to SteamOS mode.

#### Steam client for Linux installed?

Make sure that the Steam client for Linux is installed and on your system. Refer to the documentation from the Linux distribution on how to install the Steam launcher package **and make sure to install the latest Steam client using the launcher**.

> Note:
>
> * For AMD GPUs, make sure to select and install the `lib32-vulkan-radeon` package if prompted.
>
> * The Flatpak version of Steam hasn't been tested yet to confirm if it works.

#### Availability of Gamescope?

Gamescope is available as a package for most popular distributions. Refer to the [Status of Gamescope Packages](https://github.com/ValveSoftware/gamescope?tab=readme-ov-file#status-of-gamescope-packages) to see which Linux distribution provides this package.

However...

In practice, Arch Linux and Fedora are the two Linux distributions that works well.Other distributions like Debian or Ubuntu can vary but are improving over time.

Both Gamescope and the Steam client are constantly updated with new features, and having Linux distributions with rolling and semi-rolling keeps up with the pace.

> Note:
>
> Whilst not as straightforward, it is possible to build and install Gamescope manually if the binary package isn't available. Refer to the ['Building'](https://github.com/ValveSoftware/gamescope?tab=readme-ov-file#building) section on the [Gamescope repository on GitHub](https://github.com/ValveSoftware/gamescope).

#### Availability of MangoHud?

Technically this is optional, but to get the details on the performance of your system while gaming (e.g., frame counter, CPU and GPU usage, etc.) requires MangoHud installed. Refer to the [MangoHud](https://github.com/flightlessmango/MangoHud) for further information.

## Quick setup guide

* Install Gamescope.
* Install MangoHud.
* Download and install a set of scripts from this repository to help launch into SteamOS mode.
  * These includes fixes for running SteamOS set up for first time, performing updates within the Steam client, and switch back to the desktop.
* Launch into SteamOS mode and run through the set up process.

### Instructions

For these instructions, Arch Linux and Fedora will be used as examples for installing packages. It is assumed that privileged access will be required for running these instructions (e.g., using `sudo`).

#### 1. Install Gamescope

Install the gamescope package from the terminal.

* For Arch-based distributions:

  ```bash
  pacman -Sy gamescope
  ```

* For Fedora-based distributions:

  ```bash
  dnf install gamescope
  ```

#### 2. Install MangoHud

Install the manguhud and lib32-mangohud packages from the terminal

* For Arch-based distributions (requires multilib):

  ```bash
  pacman -Sy mangohud lib32-mangohud
  ```

* For Fedora-based distributions:

  ```bash
  dnf install mangohud
  ```

#### 3. Download and install the helper scripts

Download this repository and unpack the archive into a folder. It includes this README.md file, a set of helper scripts to launch Steam client into SteamOS mode, and an `installer.sh` script and `uninstaller.sh` script to install and uninstall the helper scripts respectively.

##### Simple option

The simple option is to open a terminal within the unpacked folder (or repository) and run the `installer.sh` script.

  ```bash
  ./installer.sh
  ```

##### Manual option

Alternatively, manually set the correct permissions and copy each helper script with the following set of commands. File permissions have been assigned to these helper scripts but feel free to cross-check.

* Create a `steamos-polkit-helpers` folder under `/usr/bin`:

  ```bash
  mkdir /usr/bin/steamos-polkit-helpers
  ```

* `gamescope-session`:

  ```bash
  chmod 755 ./usr/bin/gamescope-session
  ```

  ```bash
  cp ./usr/bin/gamescope-session /usr/bin/gamescope-session
  ```

* `jupiter-biosupdate`:

  ```bash
  chmod 755 ./usr/bin/jupiter-biosupdate
  ```

  ```bash
  chmod 755 ./usr/bin/steamos-polkit-helpers/jupiter-biosupdate
  ```

  ```bash
  cp ./usr/bin/jupiter-biosupdate /usr/bin/jupiter-biosupdate
  ```

  ```bash
  cp ./usr/bin/steamos-polkit-helpers/jupiter-biosupdate /usr/bin/steamos-polkit-helpers/jupiter-biosupdate
  ```

* `steamos-select-branch`:

  ```bash
  chmod 755 ./usr/bin/steamos-select-branch
  ```

  ```bash
  cp ./usr/bin/steamos-select-branch /usr/bin/steamos-select-branch
  ```

* `steamos-session-select`:

  ```bash
  chmod 755 ./usr/bin/steamos-session-select
  ```

  ```bash
  cp ./usr/bin/steamos-session-select /usr/bin/steamos-session-select
  ```

* `steamos-update`:

  ```bash
  chmod 755 ./usr/bin/steamos-update
  ```

  ```bash
  chmod 755 ./usr/bin/steamos-polkit-helpers/steamos-update
  ```

  ```bash
  cp ./usr/bin/steamos-update /usr/bin/steamos-update
  ```

  ```bash
  cp ./usr/bin/steamos-polkit-helpers/steamos-update /usr/bin/steamos-polkit-helpers/steamos-update
  ```

* `steamos-set-timezone`:

  ```bash
  chmod 755 ./usr/bin/steamos-polkit-helpers/steamos-set-timezone
  ```

  ```bash
  cp ./usr/bin/steamos-polkit-helpers/steamos-set-timezone /usr/bin/steamos-polkit-helpers/steamos-set-timezone
  ```

* `steam.desktop`:

  ```bash
  chmod 644 ./usr/share/wayland-sessions/steam.desktop
  ```

  ```bash
  cp ./usr/share/wayland-sessions/steam.desktop /usr/share/wayland-sessions/steam.desktop
  ```


#### 4. Launch SteamOS mode and run through SteamOS mode set up

* Return to the login screen (or display manager), either by logging off from the desktop environment (e.g., KDE, Gnome, Cinnamon, etc.) or restarting your computer.
* From the login screen (or display manager), select `SteamOS mode (Gamescope)` from the session selection and then log in.
  * For SDDM, on the login screen select `SteamOS mode (gamescope)` from the session selection (located near the bottom left corner of the screen). Use the same login and password as you would log on to the linux desktop.
  * For GDM, on the login screen select your username and then select `SteamOS mode (gamescope)` from the session selection (located near the bottom right corner of the screen). Use the same password as you would log on to the linux desktop.
* From the SteamOS welcome screen, run through the set up process by:
  * Selecting the language of your choice.
  * Setting the timezome.
  * If not logged in, log on to your Steam account.
  * Your computer will restart after completing the setup process.
* Log back in to `SteamOS mode (Gamescope)` and enjoy!

## FAQs and troubleshooting

### I've noticed that my computer cannot connect to the WiFi network name under SteamOS mode, but can on the desktop. How do I fix the WiFi connection issue when running in SteamOS mode?

When connecting to the WiFi network using NetworkManager from the display manager or desktop, the passphrase is stored as encrypted on your system and won't be available for others to connect.

With SteamOS, however, the WiFi network connection is stored so that other users can connect to the same network.

One workaround is to log onto the display manager or desktop first, log out, and then log in to SteamOS mode. But this can be inconvenient and defeats the purpose of logging straight into SteamOS mode at boot.

Another workaround is to set the WiFi connection for others to connect to it. This is a more practical solution (and this is how SteamOS sets a network connection). But please note note the passphrase for the WiFi connection will be stored as plain text (read-only by root). Understandably this can be a concern, so ways to mitigate this to:

* Set up a guest WiFi on the network and allow SteamOS mode to connect to that.
* Encrypt the drive on the system.

### When running Steam update in SteamOS mode, does my Linux install gets updated as well?

No, updates to your Linux install has to be performed separately using conventional methods.

It is possible to set up automatic updates depending on the Linux distribution to help keep your system up-to-date with features and security. But keep in mind of some of the risks of performing unattended upgrades.

### On Fedora Linux, notifications keeps popping up on `steamwebhelper` crashing. How do I fix this?

[TODO]

### I want to remove the changes made to my Linux install to launch into SteamOS mode. How do I do this?

The simple approach is to open a terminal within the unpacked folder (or repository) and run the `uninstaller.sh` script.

Alternatively, manually remove the scripts and the `steamos-polkit-helpers` folder:

* `gamescope-session`:

  ```bash
  rm /usr/bin/gamescope-session
  ```

* `jupiter-biosupdate`:

  ```bash
  rm /usr/bin/jupiter-biosupdate
  ```

  ```bash
  rm /usr/bin/steamos-polkit-helpers/jupiter-biosupdate
  ```

* `steamos-select-branch`:

  ```bash
  rm /usr/bin/steamos-select-branch
  ```

* `steamos-session-select`:

  ```bash
  rm /usr/bin/steamos-session-select
  ```

* `steamos-update`:

  ```bash
  rm /usr/bin/steamos-update
  ```

  ```bash
  rm /usr/bin/steamos-polkit-helpers/steamos-update
  ```

* `steamos-set-timezone`:

  ```bash
  rm /usr/bin/steamos-polkit-helpers/steamos-set-timezone
  ```

* `steam.desktop`:

  ```bash
  rm /usr/share/wayland-sessions/steam.desktop
  ```
* `steamos-polkit-helpers`:

  ```bash
  rm -rf /usr/bin/steamos-polkit-helpers
  ```

After that, remove the `mangohud` and `gamescope` packages:

* For Arch-based distributions:

  ```bash
  pacman -Rs gamescope
  ```
  
  ```bash
  pacman -Rs mangohud lib32-mangohud
  ```

* For Fedora-based distributions:

  ```bash
  dnf remove gamescope
  ```

  ```bash
  dnf remove mangohud
  ```

### I'm interested in understanding more about these script files. What do each of these script files do?

Details of each helper script include:

* `usr/bin/gamescope-session`: A script that launches the Steam client into SteamOS mode using Gamescope.

* `usr/bin/jupiter-biosupdate`: A dummy script that informs the Steam client of no bios updates as they`re only relevant for the Steam Deck and other SteamOS-compatible devices.

* `usr/bin/steamos-select-branch`: A dummy script that populates a value for Steam client updates to function but does not refer to specific SteamOS builds since updates to the operating system is managed separately.

* `usr/bin/steamos-session-select`: A script that invokes the Steam client to shutdown and return to the login screen (or display manager).

* `usr/bin/steamos-update`: A dummy script that informs the Steam client that updates to the underlying operating system is applied (since this is managed separately).

* `usr/bin/steamos-polkit-helpers/jupiter-biosupdate`: A dummy helper script that calls the `/usr/bin/jupiter-biosupdate` script. Steam client for Linux expects this script available in the `steamos-polkit-helpers` subfolder.

* `usr/bin/steamos-polkit-helpers/steamos-set-timezone`: A dummy helper script that simply exits since it is assumed the timezone on your system is already set. This is required when setting SteamOS mode for the first time. Steam client for Linux expects this script available in the `steamos-polkit-helpers` subfolder.

* `usr/bin/steamos-polkit-helpers/steamos-update`: A dummy helper script that calls the `/usr/bin/steamos-update` script. Steam client for Linux expects this script available in the `steamos-polkit-helpers` subfolder.

* `usr/share/wayland-sessions/steam.desktop`: A file that adds an option to the display manager (e.g., SDDM, GDM) that you can select and log into SteamOS mode. This calls the `/usr/bin/gamescope-session` script.
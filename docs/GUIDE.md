# Background

SteamOS is an Arch Linux based operating system developed by Valve. It is a gaming focused operating system for Steam Deck and other devices from partners working closely with Valve. At the moment, SteamOS isn't officially supported to run on different computers.

There are other Linux distributions out there such as [Bazzite](https://bazzite.gg/) and the [Nobara Project](https://nobaraproject.org/) that haved leveraged the excellent work that Valve and the community have done. They've contributed additional tools and fixes to provide a SteamOS experience for different computers, making it quick and easy to set up a gaming rig with a console-like experience.

Various scripts, tools, patches, and policies are included in SteamOS and other related distributions to provide an optimised experience. However, the fundamental components for SteamOS mode to work are:

* The Steam client for Linux for the frontend.
* A microcompositor called [Gamescope](https://github.com/ValveSoftware/gamescope).

Both the Steam Client for Linux and Gamescope are available for a variety of Linux distributions. Therefore, it is possible to launch into SteamOS mode from *`any`* Linux desktop of their choice (with a caveat - more on that later).

# Purpose

This guide will explain how the fundamentals of SteamOS works, and how to manually set up to launch into SteamOS mode from the login screen (or display manager). 

This is achieved using a microcompositor called [Gamescope](https://github.com/ValveSoftware/gamescope) to launch Steam in a separate session without a window manager.

## Why do this?

SteamOS and other Linux distributions like [Bazzite](https://bazzite.gg/) and the [Nobara Project](https://nobaraproject.org/) are indeed easier to use and install. They include all the necessary scripts and tools to keep your devices powered by SteamOS (such as the Steam Deck and Legion Go S SteamOS version) up-to-date, including the firmware and system updates.

Bazzite and the Nobara Project extends further by provide additional tools and fixes for the benefit of installing and running on any PC and keep them up-to-date.

But with the Steam Client for Linux and `Gamescope`, it is possible to:

* Use any Linux distribution if your choice provided that it supports the most recent version of Gamescope and Steam client for Linux.
* Use any desktop environment of your choice (e.g., [Plasma Desktop](https://kde.org/plasma-desktop/), [Gnome](https://www.gnome.org/), [Cinnamon](https://github.com/linuxmint/Cinnamon), etc).
* Simply launch into SteamOS mode directly from the login screen (display manager, such as [SDDM](https://github.com/sddm/sddm), [GDM](https://wiki.gnome.org/Projects/GDM), etc) without any complex scripts, tools, and Polkit configurations.
* To understand (and appreciate) the excellent work that Valve, the community, and their partners have put in to SteamOS.

The result is having a similar experience to the Steam Deck but running on your device using your favourite Linux distribution. But rather than a *game mode first* experience (like the Steam Deck), it will allow a choice of logging into either the desktop or to launch directly into SteamOS mode.

# Before we begin

For this guide, the following will be assumed:

* Arch Linux or Fedora have been tested and works well for these distributions. These will be used as examples for this guide.
* This works best with a PC with an AMD iGPU or AMD dedicated GPU. It can work on devices with NVIDIA or Intel GPUs, but can vary.
* A display manager (SDDM and GDM have been tested).
* Steam client for Linux is installed.
* Gamescope is available on your Linux distribution of choice (refer to the ['Status of Gamescope Packages'](https://github.com/ValveSoftware/gamescope?tab=readme-ov-file#status-of-gamescope-packages)).
* MangoHud is available on the Linux distribution of choice.
* A code editor to create scripts manually.

## Why these requirements?

### A PC with an AMD iGPU or AMD dedicated GPU?

[Gamescope](https://github.com/ValveSoftware/gamescope) is designed to run on Mesa + AMD with minimal effort, and hence Gamescope works very well with AMD GPUs.

Whilst Intel GPUs isn't yet supported it can work but is a bit hit and miss - the experience may be suboptimal.

Gamescope is known to work with NVIDIA GPUs, but unfortunately it can occasionally break when either NVIDIA drivers for Linux or Gamescope are updated.

### Which linux distribution shall I use, and why refer to Arch Linux and Fedora as examples?

Head over to ['Status of Gamescope Packages'](https://github.com/ValveSoftware/gamescope?tab=readme-ov-file#status-of-gamescope-packages) on GitHub for a list of linux distributions and the version of Gamescope available.

Arch Linux seems to work quite well as a rolling release distribution. In fact, Arch Linux forms as the basis for SteamOS. openSUSE Tumbleweed is another good rolling release distribution, and Fedora with its semi-rolling release cycle is also popular. Distributions with rolling and semi-rolling release cycles benefit from getting access to the most recent drivers and software, but with the caveat of keeping an eye on updates to avoid possible breakages.

Surprisingly, Ubuntu doesn't provide Gamescope as a package (although there is plan for it to be available for version 25.04). There are intructions available on Gamescope's [README.md](https://github.com/ValveSoftware/gamescope) file on how to build Gamescope from source.

Then of course there are distributions like Bazzite, Nobara and ChimeraOS that are purposely built to provide the SteamOS or Steam Deck experience out of the box.

One thing to note is that some distributions (like Manjaro) provide packages or repositories for [gamescope-session-steam](https://github.com/ChimeraOS/gamescope-session-steam) maintained by ChimeraOS. This is a collection of scripts that achieves the same results of launching into SteamOS mode from the display manager. 

With these alternatives in mind, this document aims to be useful in explaining how SteamOS works and the freedom in setting up on any linux distribution.

Arch Linux seems to be the natural choice and will be used as the example throughout this document.

### A display manager and desktop environment installed?

An option will be added to the session selector on the login screen (display manager) to choose from and log in directly to SteamOS mode.

* This will make it quick and easy to launch into Steam directly without having to launch into the desktop environment.
* You can also set the display manager to automatically launch into SteamOS mode.

### Steam installed?

The Steam Client for Linux has capabilities included to run as SteamOS with Gamescope. This is pretty much the fundamentals of SteamOS on the Steam Deck (Steam client on Linux + Gamescope + helper scripts).

Make sure that the Steam client for Linux is installed and on your system. Refer to the documentation from the Linux distribution on how to install the Steam launcher package **and make sure to install the latest Steam client using the launcher**.

> Note:
>
> * For Arch Linux and running on AMD GPUs, make sure to select and install the `lib32-vulkan-radeon` package if prompted.
>
> * The Flatpak version of Steam hasn't been tested yet to confirm if it works.

### Availability of Gamescope?

Gamescope is available in most package managers for popular distributions. Both Gamescope and the Steam client are constantly updated with new features, and having Linux distributions with rolling and semi-rolling release cycles (like Arch Linux and Fedora) helps keep up with the pace.

Other distributions have most recently started catching up. For example, from Ubuntu 25.04 and onwards, Gamescope is available in the APT package manager.

Refer to the [Status of Gamescope Packages](https://github.com/ValveSoftware/gamescope?tab=readme-ov-file#status-of-gamescope-packages) to see which Linux distribution provides this package.

> Note:
>
> Whilst not as straightforward, it is possible to build and install Gamescope manually if the binary package isn't available. Refer to the ['Building'](https://github.com/ValveSoftware/gamescope?tab=readme-ov-file#building) section on the [Gamescope repository on GitHub](https://github.com/ValveSoftware/gamescope).

### Availability of MangoHud?

This is optional, but to get the details on the performance of your system while gaming (e.g., frame counter, CPU and GPU usage, etc.) MangoHud is required. Refer to the [MangoHud](https://github.com/flightlessmango/MangoHud) for further information.

### Access to a code editor?

A code editor will be used to create the helper scripts required for this set up.

If a code editor is not installed on your system, you can use the web version of [Visual Studio Code](https://vscode.dev).

# Step-by-step guide

* Install Gamescope
* Install MangoHud
* Set up a set of scripts to help launch into SteamOS mode from the display manager + fixes for Steam client updates and first run setup.
* Launch into SteamOS mode and run through the set up process.

## Instructions

For these instructions, Arch Linux and Fedora will be used as examples for installing packages. It is assumed that privileged access will be required for running these instructions (e.g., using `sudo`).

### 1. Install Gamescope

[Gamescope](https://github.com/ValveSoftware/gamescope) is a lightweight compositor (a software that combines all the information and content to the screen). It includes capabilities to improve the image quality (e.g., upscaling, reduce screen tearing, HDR support).

It is required for the Steam Client for Linux to launch as SteamOS.

Install the Gamescope package from the terminal.

* For Arch-based distributions (which also includes packages for missing fonts for SteamOS mode):

  ```bash
  pacman -Sy gamescope lib32-fontconfig ttf-liberation wqy-zenhei
  ```

* For Fedora-based distributions:

  ```bash
  dnf install gamescope
  ```

### 2. (Optional) Install MangoHud

[MangoHud](https://github.com/flightlessmango/MangoHud) is a useful tool that displays system performance information whilst playing games (e.g., frame rate, power usage).

Although it is not required to launch the Steam client as SteamOS, it is required for the `Performance Quick Menu` to fully function.

Install the manguhud package from the terminal

* For Arch-based distributions (requires multilib):

  ```bash
  pacman -Sy mangohud lib32-mangohud
  ```

* For Fedora-based distributions:

  ```bash
  dnf install mangohud
  ```

### 3. (Optional) Testing the foundations of SteamOS mode

This is the fun part - this will demonstrate the fundamentals of how SteamOS works.

Running the following command line will launch SteamOS mode in a window.

  ```bash
  gamescope -e -- steam -steamdeck -steamos3
  ```

where:

  > -e (or --steam): tells Gamescope to integrate with the Steam Client
  Steam will open in a window with a logo appearing and then be presented with a welcome screen.

  > -steamdeck: Launch Steam with SteamDeck settings (e.g., compatibility mode enabled)

  > -steamos3: Launch steam into SteamOS mode, including capabilities to connect to the Internet, bluetooth settings, and other OS features.

After seeing it running, close the window to close SteamOS mode.

> Note: If either command fails, make sure the Steam client is downloaded and installed using the Steam launcher and then try again.

### 4. Create a helper script to launch into SteamOS mode

With the basic foundation in place, let's write a script to make it easier to launch into SteamOS mode.

The script will also check to if `MangoApp` is on the system and use it if available.

* Create a `Developer` folder in your `HOME` location using a file manager or from the command line as follows

  > `mkdir ~/Developer`

* Using the code editor, create a new file called `gamescope-session` in the `Developer` folder, add the following lines to the file and then save the file

  > `~/Developer/gamescope-session`
  >
  > ---
  >
  > `#!/bin/bash`
  >
  > `MANGOAPP_OPT=""`
  >
  > `if command -v mangoapp &>/dev/null`
  > `then`
  >   `MANGOAPP_OPT="--mangoapp"`
  > `fi`
  >
  > `gamescope $MANGOAPP_OPT -e -- steam -steamdeck -steamos3`

* Using the terminal, set the permissions of the file to execute and copy the file to the `/usr/bin/` folder

  > `chmod +x ~/Developer/gamescope-session`
  >
  > `sudo cp ~/Developer/gamescope-session /usr/bin/`

* Test the script by running the command from the terminal

  > `gamescope-session`

* SteamOS mode will launch in a window showing the set up screen.
* Close the window.

### 5. Add a new session option in the display manager

Let's add a configuation file to launch into SteamOS mode from the login screen (display manager).

* (If it does not exist already) create a `Developer` folder in your `HOME` location using a file manager or from the command line as follows

  > `mkdir ~/Developer`

* Using the code editor, create a new file called `steam.desktop` in the `Developer` folder, add the following lines to the file and then save the file

  `~/Developer/steam.desktop`
  >
  > ---
  >
  ```bash
  [Desktop Entry]
  Encoding=UTF-8
  Name=Steam (gamescope)
  Comment=Launch Steam within Gamescope`
  Exec=gamescope-session
  Type=Application
  DesktopNames=gamescope
  ```

* From the terminal, copy the `steam.desktop` file into `/usr/share/wayland-sessions/` folder

  > `sudo cp ~/Developer/steam.desktop /usr/share/wayland-sessions/`

* Log off from the desktop environment (e.g., KDE Plasma, Gnome).
* Follow the next steps based on the display manager used:
  * For SDDM, on the login screen select `Steam (gamescope)` from the session selection (located near the bottom left corner of the screen). Use the same login and password as you would log on to the linux desktop.
  * For GDM, on the login screen select your username and then select `Steam (gamescope)` from the session selection (located near the bottom right corner of the screen). Use the same password as you would log on to the linux desktop.
* This will launch Steam full screen in Gamescope and SteamOS mode.

At this point, the set up screen in SteamOS mode cannot be completed without helper scripts. The next following steps will fix these issues.

### 6. Create a dummy helper script required to set the system time

The Steam Client invokes a script called `steamos-set-timezone` when setting up SteamOS mode for the first time.

Without this script, the initial set up of SteamOS mode cannot complete.

That said, for most Linux distributions the timezone is usually set when installing Linux.

In this case, a dummy script will be created that will exit with code 0 back to inform the Steam Client that the timezone is already set.

* (If it does not exist already) create a `Developer` folder in your `HOME` location using a file manager or from the command line as follows

  > `mkdir ~/Developer`

* Using the code editor, create a new file called `steamos-set-timezone` in the `Developer/steamos-polkit-helpers` folder, add the following lines to the file and then save the file

  > `~/Developer/steamos-polkit-helpers/steamos-set-timezone`
  >
  > ---
  >
  > `#!/bin/bash`
  >
  > `exit 0;`

* From the terminal, set the permissions of the script with execute, create a `steamos-polkit-helpers` folder under `/usr/bin/` and copy the script

  > `chmod +x ~/Developer/gamescope-session`

  > `sudo mkdir /usr/bin/steamos-polkit-helpers`

  > `sudo cp ~/Developer/gamescope-session /usr/bin/`

### 7. Create a helper script to stop unecessary bios updates in SteamOS mode

Bios updates are relevant for devices powered by SteamOS. This is not required for other Linux distributions.

In this case, a dummy script will be created that will echo 'no updates configured for this bios' and exit with code 0 back to inform the Steam Client that bios updates are not required.

* (If it does not exist already) create a `Developer` folder in your `HOME` location using a file manager or from the command line as follows

  > `mkdir ~/Developer`

* Using the code editor, create a new file called `jupier-biosupdate` in the `Developer` folder, add the following lines to the file and then save the file

  > `~/Developer/jupier-biosupdate`
  >
  > ---
  >
  > `#!/bin/bash`
  >
  > `echo "No updates configured for this bios"`
  >
  > `exit 0;`

* This part is optional, but is useful to ensure the right environment is set when running the script to exit immediately on error. Using the code editor, create a new file called `jupier-biosupdate` in the `Developer/steamos-polkit-helpers` folder, add the following lines to the file and then save the file

  > `~/Developer/steamos-polkit-helpers/jupier-biosupdate`
  >
  > ---
  >
  > `#!/bin/bash`
  >
  > `set -eu`
  >
  > `exec /usr/bin/jupiter-biosupdate "$0"`

* From the terminal, set the permissions of the scripts with execute, and copy them to the following

  > `chmod +x ~/Developer/gamescope-session`

  > `sudo cp ~/Developer/gamescope-session /usr/bin/`

  Optionally, copy the polkit helper script

  > `chmod +x ~/Developer/steamos-polkit-helpers/jupiter-biosupdate`

  > `sudo cp ~/Developer/steamos-polkit-helpers/jupiter-biosupdate /usr/bin/steamos-polkit-helpers/`

### 8. Create a helper script to stop unecessary system updates in SteamOS mode

System updates are relevant for devices powered by SteamOS, but again is not required for other Linux distributions.

In this case, a dummy script will be created that will exit with code 7 back to inform the Steam Client that system updates are not required.

* (If it does not exist already) create a `Developer` folder in your `HOME` location using a file manager or from the command line as follows

  > `mkdir ~/Developer`

* Using the code editor, create a new file called `steamos-update` in the `Developer` folder, add the following lines to the file and then save the file

  > `~/Developer/steamos-update`
  >
  > ---
  >
  > `#!/bin/bash`
  >
  > `exit 7;`

* This part is optional, but a useful helper script can be created to ensure the right environment is set to exit immediately on error. Using the code editor, create a new file called `steamos-update` in the `Developer/steamos-polkit-helpers` folder, add the following lines to the file and then save the file

  > `~/Developer/steamos-polkit-helpers/steamos-update`
  >
  > ---
  >
  > `#!/bin/bash`
  >
  > `set -eu`
  >
  > `exec /usr/bin/steamos-update "$0"`

* Uisng the terminal, set the permissions of the scripts with execute and copy them to the following

  > `chmod +x ~/Developer/steamos-update`

  > `sudo cp ~/Developer/steamos-update /usr/bin/`

  Optionally, copy the polkit helper script

  > `chmod +x ~/Developer/steamos-polkit-helpers/steamos-update`

  > `sudo cp ~/Developer/steamos-polkit-helpers/steamos-update /usr/bin/steamos-polkit-helpers/`

### 9. Create a helper script to set the SteamOS branch required for the Steam Client

For devices powered by SteamOS, preview or beta branches can be chosen for testing. This is not required for other Linux distributions.

In this case, a dummy script will be created that will echo 'Not applicable for this OS'.

* (If it does not exist already) create a `Developer` folder in your `HOME` location using a file manager or from the command line as follows

  > `mkdir ~/Developer`

* Using the code editor, create a new file called `steamos-select-branch` in the `Developer` folder, add the following lines to the file and then save the file

  > `~/Developer/steamos-select-branch`
  >
  > ---
  >
  > `#!/bin/bash`
  >
  > `echo "Not applicable for this OS"`

* Using the terminal, set the permissions to the scripts and copy them to the following

  > `chmod +x ~/Developer/steamos-select-branch`
  >
  > `sudo cp ~/Developer/steamos-select-branch /usr/bin/`

### 10. Create a helper script for 'Switch to Desktop' feature to work

Nearly there. There is an option in SteamOS mode to 'Switch to Desktop'. On devices powered by SteamOS, this is a handy feature to access a full desktop experience.

When selecting 'Switch to Desktop', the Steam Client tries to invoke the `steamos-session-select`.

To mimmic this on other Linux distributions, a dummy script will be created that will shutdown the Steam Client. Once the Steam Client is shut down, it will return back to the login screen (display manager).

* (If it does not exist already) create a `Developer` folder in your `HOME` location using a file manager or from the command line as follows

  > `mkdir ~/Developer`

* Using the code editor, create a new file called `steamos-session-select` in the `Developer` folder, add the following lines to the file and then save the file

  > `~/Developer/steamos-session-select`
  >
  > ---
  >
  > `#!/bin/bash`
  >
  > `steam -shutdown`

* Using the terminal, set the permissions of the scripts with execute and copy them to the following

  > `chmod +x ~/Developer/steamos-session-select`
  >
  > `sudo cp ~/Developer/steamos-session-select /usr/bin/`

### 11. Run through Steam Deck set up

Run through the set up process by:

* Logging off from the desktop session
* Choosing 'Steam (Gamescope) from the 'session selector' and log in.

The SteamOS welcome screen will be presented. From there:

* Select the language of your choice
* Set the timezome
* Log on to your Steam account

You will then be presented with the home screen (like Big Picture mode).

That's it. Enjoy!

* Feel free to navigate in SteamOS using the mouse and/or keyboard.
* Navigate to the Steam menu, then Settings, and you should be able to see the bluetooth settings and other available networks.
* If a controller is set up, use the controller to open the Quick menu (holding the guide button + A) and the level slider should be functional on the `Performance Overlay`.

## Why these step-by-step instructions are required?

### Install Gamescope

[Gamescope](https://github.com/ValveSoftware/gamescope) is a micro compositor developed by Valve.

It can be run in either:

* An embedded session use case (without a separate window manager), or
* On top of a regular desktop (e.g., Gnome, KDE, Cinnamon)

Valve has done some excellent work in allowing Gamescope to integrate with Steam, enabling to launch Steam in an embedded session with ease. This is pretty much the basis of how the Steam Deck launches Steam at boot.

Hence `Gamescope` is required to launch into SteamOS mode from a Linux device.

### Install MangoHud

MangoHud is a tool used in SteamOS to show the 'Performance Overlay' for monitoring statistics during gameplay (e.g., frame rate, resource utilisation, temperatures).

The traditional approach was to set an environment variable `MANGOHUD=1` when launching Steam using Gamescope.

Now, a flag is used set when launching with `Gamescope` and is the preferred approach.

### Testing Steam launch with Gamescope in SteamOS mode and Mangoapp

It is also possible to use Gamescope with Steam on top of a regular desktop like KDE Plasma, Gnome, Cinnamon, etc. This makes it easier to test this concept by running a simple command from the terminal or command prompt.

  > `gamescope --mangoapp -e -- steam -steamdeck`.

Note: This command also enable MangoApp as well as launching into Steam Deck mode.

### Run through Steam Deck set up

The welcome screen is usually presented when running Steam in SteamOS mode for the first time. This is a similar experience found on the Steam Deck.

### Testing the launching into SteamOS mode using the `-steamdeck` and `-steamos3` flags

The `-steamos3` flag is key to launching into SteamOS mode that enables the following:

* The ability to connect to a network (without the need of a Network Manager or network configuration)
* Add and remove bluetooth devices within Steam
* Configure performance settings (e.g. mangohud, frame limit, scaling filter, etc)

These features are useful when running in SteamOS mode to avoid having to set up connections and bluetooth devices separately on a desktop session.

This has to be used in conjunction with the `-steamdeck` flag for it to run.

### Add a script to launch Steam in Gamescope and SteamOS mode

Steam supports a number of flags to tweak and optimise the experience when running Steam using Gamescope in an embedded session. These are often used for the Steam Deck for hardware compatibility (e.g. LCD and OLED screens, HDR, fan control, etc.)

Although this isn't required for the purpose of this concept, having a script to launch Steam using Gamescope will make it easier adapt and make further tweaks.

That said, such tweaks can affect compatibility when running games. Keeping things as simple as possible seems to be the most compatible way of launching games in SteamOS mode.

### Setting up a new session in the display manager

Adding a session entry to the display manager (e.g., SDDM, GDM) will allow Steam to launch using Gamescope in SteamOS mode directly without the need of a separate window manager.

Once it is running you can navigate through Steam using the keyboard or a controller. Using the `Esc` key on your keyboard or the guide button on the controller (e.g. Xbox button, PS button, Steam button, Stadia button, etc.) will open the Steam menu.

> **Pro tip**
>
> You can open the Quick menu using the controller by holding the guide button + A.

It is worth noting that when using KDE6, it is assumed that Wayland is used. With KDE5 there is a possibility that X11 is used
by default.

If `Steam (gamescope)` doesn't appear in the session entry on the display manager then copy the `steam.desktop` file into the `/usr/share/xsessions/` folder as well as the `/usr/share/wayland-sessions/`.

### Add a script to switch back to 'desktop mode' (back to the display manager)

When running Steam in SteamOS mode, you can send the computer to `Sleep`, `Shutdown` or `Restart` from selecting `Power` from the Steam menu.

However, when selecting `Switch to Desktop` it tries to invoke a script called `steamos-session-select`. Selecting the `Switch to Desktop` option will not work without the `steamos-session-select`script.

In this case, the `steamos-session-select` script will be created to invoke Steam to shut down and (in turn) return to the login screen (display manager). The `steamos-session-select` is normally expected in the `/usr/bin` folder.

How this can be achieved? Thankfully, there is a simple command to tell Steam to shutdown - `steam -shutdown`. We can test this with the following:

* Launch Steam on your desktop session
* Run the following command from a terminal:

  > `steam -shutdown`

This will close Steam gracefully.

### Applying fixes for software updates

Valve are continuously introducing new features and updates to Steam and Gamescope. The "OS Update Channel" is one of these new features, and expects a script called `steamos-select-branch` to provide a list of available channels under beta participation. Without this, updates will stop working from within SteamOS mode. Creating the `steamos-select-branch` that provides a dummy item for the "OS Update Channel" fixes the is issue.

Software updates also tries to invoke any available system and bios updates for the Steam Deck. These are not required for other Linux distributions, so two dummy scripts are created that simply exits (thinking that any system and bios updates have been carried out).

An alternative workaround to updating Steam is to launch Steam from the desktop and check for updates from there. 

# References

* Gamescope:
  * README.md - <https://github.com/ValveSoftware/gamescope>
* Arch wiki:
  * Gamescope - <https://wiki.archlinux.org/title/Gamescope>
  * Steam - <https://wiki.archlinux.org/title/Steam>
  * Vulkan - <https://wiki.archlinux.org/title/Vulkan>
  * MangoHud - <https://wiki.archlinux.org/title/MangoHud>

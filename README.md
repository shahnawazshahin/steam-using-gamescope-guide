# Steam using Gamescope guide

A step-by-step guide in setting up Arch Linux to launch Steam using Gamescope in SteamOS mode as an embedded session without a display manager.

## Purpose

The guide aims to provide a simple set of instructions that will enable an experience similar to the Steam Deck but on your computer.

Rather than a 'game mode first' experience with the option to launch the desktop (like the Steam Deck), instead it will allow a choice of logging into a full, flexible desktop with the option to launch directly into game mode.

This is achieved by using a microcompositor called [Gamescope](https://github.com/ValveSoftware/gamescope) to launch Steam in a separate session without a window manager.

### Why do this?

* To enable a console-like experience when using a desktop or mini PC - useful for a living room or entertainment centre set up
* The possibility of lower latency and better frame rates in games for a more responsive experience
* To experience what a Steam Deck is like
* To understand (and appreciate) the excellent work that Valve (and their partners) have put in
* The freedom to use any linux distribution that supports Gamescope, and not having to resort to tailor-made distributions

## Before we begin

Before we begin the following are assumed:

* A PC with an AMD iGPU or AMD dedicated GPU
* Any linux distribution that provides Gamescope as a package (Arch Linux will be used as an example)
* A display manager and desktop environment installed (e.g., SDDM and KDE Plasma, GDM and Gnome)
* Steam installed
* MangoHud installed
* A code editor installed

### Why these requirements?

#### A PC with an AMD iGPU or AMD dedicated GPU?

[Gamescope](https://github.com/ValveSoftware/gamescope) is designed to run on Mesa + AMD or Intel, or other Mesa/DRM drivers with minimal effort. It can also work with the NVIDIA proprietary driver (version 515.43.04+) with the `nvidia-drm.modeset=1` set to the kernel parameter.

But in practice the out-of-the-box experiece isn't as smooth and pleasant experience with Intel or NVIDIA drivers when integrating Gamescope with Steam.

#### Which linux distribution shall I use, and why refer to Arch Linux as an example?

Head over to Gamescope's [README.md](https://github.com/ValveSoftware/gamescope) file on GitHub for a list of linux distributions and the version of Gamescope available.

Arch Linux seems to work quite well as a rolling release distribution. In fact, Arch Linux forms as the basis for SteamOS. openSUSE Tumbleweed is another good rolling release distribution, and Fedora with its semi-rolling release cycle is also popular. Distributions with rolling and semi-rolling release cycles benefit from getting access to the most recent drivers and software, but with the caveat of keeping an eye on updates to avoid possible breakages.

Surprisingly, Ubuntu doesn't provide Gamescope as a package (although there is plan for it to be available for version 25.04). There are intructions available on Gamescope's [README.md](https://github.com/ValveSoftware/gamescope) file on how to build Gamescope from source.

Then of course there are distributions like Bazzite, Nobara and ChimeraOS that are purposely built to provide the SteamOS or Steam Deck experience out of the box.

One thing to note is that some distributions (like Manjaro) provide packages or repositories for [gamescope-session-steam](https://github.com/ChimeraOS/gamescope-session-steam) maintained by ChimeraOS. This is a collection of scripts that achieves the same results of launching into SteamOS mode from the display manager. 

With these alternatives in mind, this document aims to be useful in explaining how SteamOS works and the freedom in setting up on any linux distribution.

Arch Linux seems to be the natural choice and will be used as the example throughout this document.

#### A display manager and desktop environment installed?

* This will make it easier to understand the concept and setting up the configurations and scripts
* Also, the Steam Deck comes with KDE Plasma - it will be nice in keeping things consistent
* But it can also work with other display managers and desktop environments like GDM and Gnome

#### Steam installed?

* The [steam](https://archlinux.org/packages/?name=steam) is the recommended package for Arch Linux
  * `sudo pacman -Syu multilib/steam`
  * For AMD GPUs, make sure to select and install [lib32-vulkan-radeon](https://archlinux.org/packages/?name=lib32-vulkan-radeon) when prompted
* This should work with the [steam-native](https://archlinux.org/packages/?name=steam-native-runtime) package as well
* Flatpak version of Steam hasn't been tested yet to see if it works for this.

#### A code editor?

* [Visual Studio Code](https://wiki.archlinux.org/title/Visual_Studio_Code) is a popular choice
  * `sudo pacman -Syu extra/code`
* The [code](https://archlinux.org/packages/?name=code) package is available on Arch Linux

## Step-by-step guide

* Install Gamescope
* Install MangoHud
* Testing Steam launching with Gamescope
* Run through Steam Deck set up
* Testing Steam launching with Gamescope in SteamOS mode and Mangoapp
* Add a script to launch Steam in Gamescope and SteamOS mode
* Setting up a new session in the display manager (e.g., SDDM, GDM)
* Add a script to switch back to 'desktop mode' (back to the display manager)
* Apply fixes for software updates

### Instructions

#### 1. Install Gamescope

* Install the gamescope package from the terminal

  > `sudo pacman -Syu gamescope`

#### 2. Install MangoHud

* Install the manguhud and lib32-mangohud packages (available under multilib) from the terminal

  > `sudo pacman -Syu mangohud lib32-mangohud`

#### 3. Testing Steam launch in Gamescope

* To test this, run the following command to launch Steam within a Gamescope instance from the terminal

  > `gamescope -e -- steam -steamdeck`

* Steam will open in a window with a logo appearing and then be presented with a welcome screen.

#### 4. Run through Steam Deck set up

* Run through the set up process by:
  * Selecting the language of your choice
  * Setting the timezome
  * Logging on to your Steam account
* You will then be presented with the home screen (like Big Picture mode).
* Close the window to exit from Steam.

#### 5. Testing Steam launch with Gamescope in SteamOS mode and Mangoapp

* Run the following command from the terminal [^1]

  > `gamescope --mangoapp -e -- steam -steamdeck -steamos3`

* This will run Steam again in a in a window. Navigate to the Steam menu, then Settings, and you should be able to see the bluetooth settings and other available networks.
* Using a controller, open the Quick menu (holding the guide button + A) and select the desired level for the `Performance Overlay`. Run a game and the performance overlay should appear.

[^1]: Be sure to type `--mangoapp` and not `--mangohud`. Also, don't miss the `3` when typing `-steamos3` as it won't work without it.

#### 6. Add a script to launch Steam in Gamescope and SteamOS mode

* Create a `Developer` folder in your `HOME` location using a file manager or from the command line as follows

  > `mkdir ~/Developer`

* Using a code editor, create a new file called `gamescope-session` in the `Developer` folder, add the following lines to the file and then save the file

  > `~/Developer/gamescope-session`
  >
  > ---
  >
  > `#!/bin/bash`
  >
  > `gamescope --mangoapp -e -- steam -steamdeck -steamos3`

* Set the permissions to the file and copy the file to the `/usr/bin/` folder

  > `chmod +x ~/Developer/gamescope-session`
  >
  > `sudo cp ~/Developer/gamescope-session /usr/bin/`

* Test the script by running the command

  > `gamescope-session`

* Steam will open in a window running in in Gamescope and SteamOS mode.
* Close the window.

#### 7. Setting up a new session in the display manager

* (If it does not exist already) create a `Developer` folder in your `HOME` location using a file manager or from the command line as follows

  > `mkdir ~/Developer`

* Using a code editor, create a new file called `steam.desktop` in the `Developer` folder, add the following lines to the file and then save the file

  > `~/Developer/steam.desktop`
  >
  > ---
  >
  > `[Desktop Entry]` \
  > `Encoding=UTF-8` \
  > `Name=Steam (gamescope)` \
  > `Comment=Launch Steam within Gamescope` \
  > `Exec=gamescope-session` \
  > `Type=Application` \
  > `DesktopNames=gamescope`

* From the terminal, copy the `steam.desktop` file into `/usr/share/wayland-sessions/` folder

  > `sudo cp ~/Developer/steam.desktop /usr/share/wayland-sessions/`

* Log off from the desktop environment (e.g., KDE Plasma, Gnome).
* Follow the next steps based on the display manager used:
  * For SDDM, on the login screen select `Steam (gamescope)` from the session selection (located near the bottom left corner of the screen). Use the same login and password as you would log on to the linux desktop.
  * For GDM, on the login screen select your username and then select `Steam (gamescope)` from the session selection (located near the bottom right corner of the screen). Use the same password as you would log on to the linux desktop.
* This will launch Steam full screen in Gamescope and SteamOS mode.

#### 8. Add a script to switch back to 'desktop mode' (back to login screen)

To enable the `Switch to Desktop` invoke Steam to shut down the `steamos-session-select` will be created and placed under the `/usr/bin` folder.

* (If it does not exist already) create a `Developer` folder in your `HOME` location using a file manager or from the command line as follows

  > `mkdir ~/Developer`

* Using a code editor, create a new file named `steamos-session-select` in the `Developer` folder, add the following lines to the file and then save the file

  > `~/Developer/steamos-session-select`
  >
  > ---
  >
  > `#!/bin/bash`
  >
  > `steam -shutdown`

* From the terminal, set the permissions to `steamos-session-select` and then copy the script into `/usr/bin/` folder

  > `chmod +x ~/Developer/steamos-session-select`
  >
  > `sudo cp ~/Developer/steamos-session-select /usr/bin/`

* Test this by either:
  * Launching Steam using Gamescope in SteamOS mode as a regular desktop from the command prompt

    > `gamescope --mangoapp -e -- steam -steamdeck -steamos3`

  * Launching in an embeeded session by logging off from the desktop (KDE Plasma) and log in again using `Steam (gamescope)` from the session selection
* Using the `Esc` key on the keyboard, or the guide button on your controller (e.g. Xbox button, PS button, Steam button, Stadia button, etc.), select the `Power` option, then select `Switch to Desktop` to return to the display manager login

#### 9. Apply fixes for software updates

To fix the issue with software updates within SteamOS mode, a script called `steamos-select-branch` is required and will be created and placed under the `/usr/bin` folder.

* (If it does not exist already) create a `Developer` folder in your `HOME` location using a file manager or from the command line as follows

  > `mkdir ~/Developer`

* Using a code editor, create a new file named `steamos-select-branch` in the `Developer` folder, add the following lines to the file and then save the file

  > `~/Developer/steamos-select-branch`
  >
  > ---
  >
  > `#!/bin/bash`
  >
  > `echo "Not applicable for this OS"`

* From the terminal, set the permissions to `steamos-select-branch` and then copy the script into `/usr/bin/` folder

  > `chmod +x ~/Developer/steamos-select-branch`
  >
  > `sudo cp ~/Developer/steamos-select-branch /usr/bin/`

Next, when checking for Steam Client updates via SteamOS mode it tries to invoke a script called `steamos-update`. For this, a dummy script will be created that will simply run an `exit` command with exit code 7 (indicating that no system updates are required).

* Using a code editor, create a new file named `steamos-update` in the `Developer` folder, add the following lines to the file and then save the file

  > `~/Developer/steamos-update`
  >
  > ---
  >
  > `#!/bin/bash`
  >
  > `exit 7;`

* From the terminal, set the permissions to `steamos-update` and then copy the script into `/usr/bin/` folder

  > `chmod +x ~/Developer/steamos-update`
  >
  > `sudo cp ~/Developer/steamos-update /usr/bin/`

Another script that SteamOS mode tries to invoke when running software updates within SteamOS mode is `jupiter-biosupdate`. For this, a dummy script will be created that will simply run an `exit` command.

* Using a code editor, create a new file named `jupiter-biosupdate` in the `Developer` folder, add the following lines to the file and then save the file

  > `~/Developer/jupiter-biosupdate`
  >
  > ---
  >
  > `#!/bin/bash`
  >
  > `exit 0;`

* From the terminal, set the permissions to `jupiter-biosupdate` and then copy the script into `/usr/bin/` folder

  > `chmod +x ~/Developer/jupiter-biosupdate`
  >
  > `sudo cp ~/Developer/jupiter-biosupdate /usr/bin/`

* To test this:
  * Launch Steam using Gamescope in SteamOS mode
  * Select Steam menu and navigate to Settings
  * Check the "Check for Updates" button under "System" if it is available.
    * Notice that "Not applicable for this OS" is also populated for "OS Update Channel".
  * Updates should work when selecting the "Check for Updates" button but it will prompt an error in the end, which can be ignored.

### Why these step-by-step instructions?

#### Install Gamescope?

[Gamescope](https://github.com/ValveSoftware/gamescope) is a micro compositor developed by Valve.

It can be run in either:

* an embedded session use case (without a separate window manager), and
* on top of a regular desktop (Gnome, KDE, Cinnamon, etc)

Valve has done some excellent work in allowing Gamescope to integrate with Steam, enabling to launch Steam in an embedded session with ease. This is pretty much the basis of how the Steam Deck launches Steam at boot.

#### Install MangoHud?

MangoHud is the tool used to allow Steam to display the 'Performance Overlay' for monitoring statistics like frames per second (FPS), resource utilisation, temperatures, etc.

The traditional approach was to set an environment variable `MANGOHUD=1` when launching Steam using Gamescope. MangoHud now comes with MangoApp, which is the preferred application to use with Gamescope.

#### Testing Steam launch with Gamescope in SteamOS mode and Mangoapp

It is also possible to use Gamescope with Steam on top of a regular desktop like KDE Plasma, Gnome, Cinnamon, etc. This makes it easier to test this concept by running a simple command from the terminal or command prompt.

  > `gamescope --mangoapp -e -- steam -steamdeck`.

Note: This command also enable MangoApp as well as launching into Steam Deck mode.

#### Run through Steam Deck set up

The welcome screen is usually presented when running Steam in Steam Deck mode for the first time. This is a similar experience found on the Steam Deck.

Without doing this it won't be possible to launch Steam using Gamescope in SteamOS mode as the application will fail on the update process that prevents this set up process to complete.

#### Testing Steam launch in Gamescope and SteamOS mode

It is useful to test if Steam can launch using Gamescope in SteamOS mode as this will enable the following features:

* The ability to connect to a network (without the need of a Network Manager or network configuration)
* Add and remove bluetooth devices within Steam
* Configure performance settings (e.g. mangohud, frame limit, scaling filter, etc)

These features are useful when running Steam using Gamescope in an embedded session to avoid having to set up connections and bluetooth devices separately on a desktop session.

#### Add a script to launch Steam in Gamescope and SteamOS mode

Steam supports a number of flags to tweak and optimise the experience when running Steam using Gamescope in an embedded session. These are often used for the Steam Deck for hardware compatibility (e.g. LCD and OLED screens, HDR, fan control, etc.)

Although this isn't required for the purpose of this concept, it will be useful to prepare a script to launch Steam using Gamescope and make further tweaks in future.

That said, such tweaks can affect compatibility when running games. Keeping things as simple and vanilla as possible seems to be the most compatible way of launching games from Steam.

#### Setting up a new session in the display manager

Adding a session entry to the display manager (e.g., SDDM, GDM) will allow Steam to launch using Gamescope in SteamOS mode directly without the need of a separate window manager.

Once it is running you can navigate through Steam using the keyboard or a controller. Using the `Esc` key on your keyboard or the guide button on the controller (e.g. Xbox button, PS button, Steam button, Stadia button, etc.) will open the Steam menu.

> **Pro tip**
>
> You can open the Quick menu using the controller by holding the guide button + A.

It is worth noting that if using KDE6 it is assumed that Wayland is used. With KDE5 there is a possibility that X11 is used
by default.

If `Steam (gamescope)` doesn't appear in the session entry on the display manager then copy the `steam.desktop` file into the `/usr/share/xsessions/` folder as well as the `/usr/share/wayland-sessions/`.

#### Add a script to switch back to 'desktop mode' (back to the display manager)

When running Steam using Gamescope in SteamOS mode, you can send the computer to `Sleep`, `Shutdown` or `Restart` from selecting `Power` from the Steam menu.

However, when selecting `Switch to Desktop` it tries to invoke a script called `steamos-session-select`. Selecting the `Switch to Desktop` option will not work without the `steamos-session-select`script.

In this case, the `steamos-session-select` script will be created to invoke Steam to shut down and (in turn) return to the login screen (display manager). The `steamos-session-select` is normally expected in the `/usr/bin` folder.

How this can be achieved? Thankfully, there is a simple command to tell Steam to shutdown - `steam -shutdown`. We can test this with the following:

* Launch Steam on your desktop session
* Run the following command from a terminal:

  > `steam -shutdown`

This will close Steam gracefully.

#### Applying fixes for software updates

Valve are continuously introducing new features and updates to Steam and Gamescope. The "OS Update Channel" is one of these new features, and expects a script called `steamos-select-branch` to provide a list of available channels under beta participation. Without this, updates will stop working from within SteamOS mode. Creating the `steamos-select-branch` that provides a dummy item for the "OS Update Channel" fixes the is issue.

Software updates also tries to invoke any available system and bios updates for the Steam Deck. This is not required for linux distributions, so two dummy scripts are created that simply exits (thinking that any system and bios updates has been carried out).

An alternative workaround to updating Steam is to launch Steam from the desktop and check for updates from there. 

## References

* Gamescope:
  * README.md - <https://github.com/ValveSoftware/gamescope>
* Arch wiki:
  * Gamescope - <https://wiki.archlinux.org/title/Gamescope>
  * Steam - <https://wiki.archlinux.org/title/Steam>
  * Vulkan - <https://wiki.archlinux.org/title/Vulkan>
  * MangoHud - <https://wiki.archlinux.org/title/MangoHud>

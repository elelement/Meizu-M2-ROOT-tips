# Meizu-M2-ROOT-tips
If you have a Meizu M2 and you are unable to get root access, install a new firmware or connect it through ADB, this guide is for you. The instructions that you will find here helped me to get all of them.
**Please, while this procedure is safe to use, I'm not responsible of any possible damage to your phone. I'm only recollecting useful information from forums and my personal experience.**

## Root problems
This is for users who already have a Meizu account and supposed root priviliges that are not working. I found myself with a phone telling me that it was rooted (settings/accounts/<your flyme account>/permisssions: open), but at the same time, unable to launch applications as root. SuperSU doesn't prompt you for super user permissions, so I was unable to delete any of the preinstalled applications. I tried everything, installing new firmware, cleaning cache and data, anything. Finally, after reading a lot of forums and paying attention to what was written in them I found the answer: [http://forum.xda-developers.com/galaxy-s6/general/root-pingpongroot-s6-root-tool-t3103016/page7](http://forum.xda-developers.com/galaxy-s6/general/root-pingpongroot-s6-root-tool-t3103016/page7)

Basically, you need to install the KingsUser app, which is some kind of SuperSU, but with "prompting permissions" feature working. You can download it from this repository.

**Update**: you may need to change your device name in order to make it work.


## ADB
Only for Ubuntu users (probably for all Debian distros). This is another thing hard to configure or at least it was for me. In order to get ADB working do the following:
1. Install android adb tools on Ubuntu:
  ```
  sudo apt-get install android-tools-adb
  ```
2. Create the file adb_usb.ini at your .android local folder:
  ```
  echo "0x2a45" > ~/.android/adb_usb.ini
  ```
3. Add a new udev rule for your Meizu M2:
  ```
  sudo echo "SUBSYSTEM==\"usb\", SYSFS{idVendor}==\"2a45\", SYSFS{idProduct}==\"0c02\", MODE=\"0666\"" > /etc/udev/rules.d/51-android.rules
  ```
  You may be asking you how did I get the idVendor and the idProduct; well it is as easy as typing (you may check that the phone is connected as data transfer mode):
  ```
  lsub
  ```
  You will see a device with no name on bus 001 :
  ```
  Bus 001 Device 032: ID 2a45:0c02 
  ```
  
  To see a name for this device, you have to edit the file /var/lib/usbutils/usb.ids. Once opened you will notice that there is a list of all the hardware vendors and their products. They are listed in ascending order by vendor ID, so find where it will go your "2a45" device and the "Meizu lines" that follows: (I'm showing you more devices so you can see how it should look like):
  ```
  2899  Toptronic Industrial Co., Ltd
        012c  Camera Device
  2a45  Meizu
        0c02 Meizu M2
  2c02  Planex Communications
        14ea  GW-US11H WLAN
  2c1a  Dolphin Peripherals
        0000  Wireless Optical Mouse

  ```
  
  Now you should see your device name while typing lsusb:
  ```
  Bus 001 Device 032: ID 2a45:0c02 Meizu Meizu M2
  ```
4. Restart udev to apply changes
  ```
  sudo udev restart
  ```
5. Disconnect your phone and kill adb server, just in case it was running:
  ```
  adb kill-server
  ```
6. Ensure your phone is on "debugging mode" and launch adb service:
  ```
  adb devices
  ```
  This will start the service and show you your connected devices. You should see now something like:
  ```
  <my_user>@<my_computer>:~$ adb devices 
  * daemon not running. starting it now on port 5037 *
  * daemon started successfully *
  List of devices attached 
  88UFBMK26DBZ	device
  ```
  
  **Pay attention** to the authorization message that your phone will prompt you.
  
7. Launch a shell
  ```
  adb shell
  ```
  
You're done. ADB should be working on your Ubuntu computer. 

Any thoughts or corrections are very welcome.

## Install TWRP and SuperSU

In this section is intended to help users to replace Meizu's custom recovery software by the one provided by TWRP [https://twrp.me/](https://twrp.me/) which is by far better and in my case helped me to install the latest Meizu's firmware withouth the annoying "Firmware corrupt" message that you will in see in most occasions. Please note that you will lose all your data stored in your internal storage, not the external SD.
Please, feel free to correct me as I'm writing this by heart, reviewing the sources I used to achieve my goal.

### TWRP

This section is based on this post at Meizu fans forums:

[https://meizufans.eu/forum/topic/3675/m2-mini-twrp-recov(ery?page=1](https://meizufans.eu/forum/topic/3675/m2-mini-twrp-recovery?page=1)

> First of all, you need to be root before installing TWRP and to have [BusyBox](https://play.google.com/store/apps/details?id=stericson.busybox) installed into your Meizu M2. 

I will guide you step by step during the process.

1. Download unlock_bootloader.sh + twrp_2.8.7.0.img
2. Copy and paste unlock_bootloader.sh into your phone's internal storage (i.e. /sdcard. If you see two sdcard, use sdcard0, which is the internal storage)
3. Open a terminal and type: 
	```
    adb shell
	su
	sh /sdcard/unlock_bootloader.sh
    exit
    ```
4. Then
	```
	adb reboot bootloader
	fastboot oem unlock
    ```
5. Now you have to wait. Before using fastboot command you'll see on your phone a black screen with a small white text at the bottom of the screen. After using fastboot you will be asked to continue by pushing "Volume up" key. Wait then till it says is done working.
6. When is over (the text on he screen will warn you), shutdown the phone by pressing power button for a few seconds.
7. Power on the phone and wait until phone boots into Flyme OS [^boot error](If somehow your phone enters in an endless boot and reboot loop, withouth booting into Flyme OS, there's a trick: reboot on recovery mode (Volumen up + power off, push Start (even if you don't have anything to flash) and restart.)
8. Once restarted type, copy twrp_2.8.7.0.img into your /sdcard directory:
	```
    adb reboot bootloader
    fastboot flash recovery twrp_2.8.7.0.img
    ```
9. You will see again a black screen with white text. Wait until it finishes.
10. Power off the phone.
11. Volume Up + Power to enter your new TWRP recovery mode.

### SuperSU

Download SuperSU binary from this repo and copy/paste it again, into your /sdcard from your internal storage. Now that you have installed TWRP it will be simple to flash it:

1. Reboot in recovery mode: Volume up + power off buttons.
2. Select "install zip from sdcard" and choose "UPDATE-SuperSU-v2.65-20151226141550.zip".
3. Wait for completion and reboot the phone. It will take a while to restart; don't panic because you will see the Meizu logo for a while till it changes to "applying changes".
4. Back again to our Flyme OS, open the application and update the binaries.

You're done!


![alt text](https://www.dropbox.com/s/iz10l0ukjf8u3f0/RevisionArtboard_1_copy.png?raw=1)
# Scarlet Spectre
This is a tool for building a Debian 9 live boot ISO capable of automating part of the penetration test procedures on Windows based networks.

## How it works?
It presumes you are able to boot from a USB Flash Drive on the target machine.

During the boot proccess it will automatically mount NTFS drives on the machine while looking for Windows installed on them, then it will extract password hashes and copy the registry hives onto the USB drive.

Your are also able to launch an NBT-DS poisoning attack using Responder.

The tool is capable of automatically acquiring network configuration data from the Windows Registry hives if it is not able to setup the interfaces using DHCP.

## Usage:
Just get a new **Debian 9** install on a VM and then execute setup.sh **AS ROOT** 
```
./setup.sh
```

Then, just use Rufus to burn the resulting image.
### This is a PoC
I recommend you git clone/checkout this on a Debian 9 freshly installd VM.

The iso has been tested using Rufus 2.18 for burning it into the USB Flash Drive on **ISO mode**.



## Todo:
- Configuring WiFi networks
- UEFI Support (Counting on you, Debian)
- Custom Scripts/Modes

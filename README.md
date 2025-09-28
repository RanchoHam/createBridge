# createBridge

This shell script is for use on Raspberry PI OS machines running Raspberry Pi OS Bookworm (or later?) version.  
This involves modifying the simh target OS boot.ini script, replacing the NAT device with a Bridge device, and
setting the parameters for the attaching the bridge device to the ethernet device.  

## Description

The script will first determine if the operating conditions are correct:  it must be run as root and it must be executed from an approved simh guest OS directory.  At the moment that is only the systems/211bsd+ directory.  

It will then gather the parameters necessary to facilllitate the new (or rebuilt) bridge device.  

It will then modify the simh guest OS boot.ini script to use the bridge device in lieu of the NAT device.  

Finally it will use the Network Manager's CLI to create (or modify) a bridge device.  

## Getting Started

### Dependencies

* This was developed on and tested against the Raspberry Pi OS Bookworm version.
* nmcli  
* bash  
* git  
* obsolescence/pidp11 repository  

### Installing

* How/where to download this shell script
* If necessary, clone the pidp11 repository and run the install script to download 211bsd+  
```
cd /opt
sudo git clone https://github.com/obsolescence/pidp11.git
sudo /opt/pidp11/install/install.sh
```
```
cd ~/repos # or any writable directory  
git clone https://github.com/RanchoHam/createBridge.git  
```
* Any modifications needed to be made to files/folders  
```
cd createBridge
ln -f -s `pwd`/createBridge.sh /opt/pidp11/systems/211bsd+/createBridge.sh  
```

### Executing program

* How to run the program
* Step-by-step bullets
```
cd /opt/pidp11/systems/211bsd+
sudo ./createBridge -h
# re-run the script without the -h parameter but with the required options and parameters as indicated by the Usage: prompt
sudo ./createBridge -H ...
```

## Help

Helper info:  
```
sudo ./createBridge -h
T```

## Authors

Contributors names and contact info

 Rich McDonald`
 50395146+RanchoHam@users.noreply.github.com

## Version History

* 0.1
    * Initial Release

## License

This project is licensed under the MIT License - see the LICENSE.md file for details

## Acknowledgments

Inspiration, code snippets, etc.
* Malcom Ray (Sheepless) for the raw code I shamelessly inserted in this scipt

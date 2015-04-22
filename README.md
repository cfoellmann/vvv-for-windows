# VVV for Windows

> Trying to automate running VVV on Windows as much as possible

## Versions

Current Versions:
- Virtual Box: `4.3.14-95030`
- Vagrant: `1.6.3`

|    _VVV Master_   | Vagrant 1.6.2 | Vagrant 1.6.3 |
|:-----------------:|:-------------:|:-------------:|
| VirtualBox 4.3.14 |       OK      |       OK      |

Open [table_compatibility.tgn](https://github.com/cfoellmann/vvv-for-windows/blob/master/table_compatibility.tgn) on [Markdown Tables Generator](http://www.tablesgenerator.com/markdown_tables) to edit

## Howto
....Coming Soon!?

Aiming for something as simple as this:

> Do __NOT__ do this at the moment!!
> Open CMD, Copy&Paste:
```
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/cfoellmann/vvv-for-windows/master/vvv-installer.ps1'))"
```

## Scripts
### [vvv-installer.ps1](https://github.com/cfoellmann/vvv-for-windows/blob/master/vvv-installer.ps1)
- Arguments:
	- `--checkonly` = only check installed versions (without installation, up- or downgrades)
	- `--vbext` = install "VirtualBox Extension Pack"
	- `-vvvsource <source>` = use a custom VVV package (example: `-vvvsource "https://github.com/Varying-Vagrant-Vagrants/VVV.git"`)
	- `-vvvpath <absolutepath>` = set the destination path of your VVV folder (example: `-vvvpath "C:\path\to\vvv"`)
- Functions
	- Check VirtualBox
		- is VirtualBox installed? (Install)
		- is VirtualBox version equal to target version? (forced Up-/Downgrade)
	- Check Vagrant
		- is Vagrant installed? (Install)
		- is Vagrant version equal to target version? (forced Up-/Downgrade)
	- Check VVV
		- is VVV present? (Load)
		- is VVV tracked via Git? (Pull)
	- Check Custom Sites for VVV
		- TBD

## @todo
- Installation: VirtualBox + Enforce defined version
- Installation: Vagrant + Enforce defined version
- Load VVV files
- Add custom sites to VVV installation
- Provision VVV

## Changelog
- 0.0.1 [2014-??-??]
	- TBD

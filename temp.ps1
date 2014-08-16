
    if ($VagrantCustomPath) {
        $customPath = "VAGRANTAPPDIR=" + $VagrantCustomPath
    } else {
        $customPath = ""
    }







# fix environment
# VBOX_INSTALL_PATH=C:\Program Files\Oracle\VirtualBox\
# PATH + ;C:\Program Files\Oracle\VirtualBox
[Environment]::SetEnvironmentVariable( "Path", $env:Path + ";C:\Program Files\Oracle\VirtualBox", [System.EnvironmentVariableTarget]::Machine )
# does this remove placeholders
[Environment]::SetEnvironmentVariable( "VBOX_INSTALL_PATH", "C:\Program Files\Oracle\VirtualBox\", [System.EnvironmentVariableTarget]::Machine )




# STUFF


#$username=Read-Host "Please enter a username"
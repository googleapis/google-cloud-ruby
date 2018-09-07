REM PowerShell -command "& iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))"

REM configure chocolatey
CALL choco feature disable --name showDownloadProgress
CALL choco feature enable -n=allowGlobalConfirmation

REM download and install uru
PowerShell -command "& Invoke-WebRequest -outf uru.nupkg https://bitbucket.org/jonforums/uru/downloads/uru.0.8.5.nupkg"
CALL choco install uru -source "%cd%"

REM install ruby versions and git
CALL choco install ruby --version 2.3.3 
CALL choco install ruby --version 2.4.1.2 
CALL choco install ruby --version 2.5.1.2
CALL refreshenv
CALL uru admin add --recurse C:\tools\ --dirtag
CALL refreshenv
CALL choco install ruby2.devkit git
CALL refreshenv

REM install bundler on each ruby version
CALL uru 23
CALL gem update --system
CALL gem install bundler
CALL uru 24
CALL gem update --system
CALL gem install bundler
CALL uru 25
CALL gem update --system
CALL gem install bundler

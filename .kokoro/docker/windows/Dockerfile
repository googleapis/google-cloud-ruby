FROM microsoft/windowsservercore:latest

# install chocolatey
ENV chocolateyUseWindowsCompression false
RUN PowerShell -Command \
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

RUN choco feature disable --name showDownloadProgress
RUN choco feature enable -n=allowGlobalConfirmation 

# Install rubies and uru
RUN PowerShell -Command \
    iwr -outf uru.nupkg https://bitbucket.org/jonforums/uru/downloads/uru.0.8.5.nupkg
RUN cinst ruby --version 2.3.3 
RUN cinst ruby --version 2.4.1.2 
RUN cinst ruby --version 2.5.1.2
RUN ruby2.devkit git
RUN cinst uru -source $PWD
RUN uru admin add --recurse C:\tools\ --dirtag

# Add bundler to rubies
RUN uru 23; gem update --system; gem install bundler
RUN uru 24; gem update --system; gem install bundler
RUN uru 25; gem update --system; gem install bundler

FROM microsoft/windowsservercore:ltsc2016

# install chocolatey
ENV chocolateyUseWindowsCompression false
RUN powershell -Command \
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); \
    choco feature disable --name showDownloadProgress; \
    choco feature enable -n=allowGlobalConfirmation 

# Install rubies and uru
RUN iwr -outf uru.nupkg https://bitbucket.org/jonforums/uru/downloads/uru.0.8.5.nupkg
RUN choco install ruby --version 2.3.3 ruby --version 2.4.1.2 ruby --version 2.5.1.2 \
    ruby2.devkit git
RUN choco install uru -source $PWD
RUN uru admin add --recurse C:\tools\ --dirtag

# Add bundler to rubies
RUN uru 23
RUN gem update --system
RUN gem install bundler
RUN uru 24
RUN gem update --system
RUN gem install bundler
RUN uru 25
RUN gem update --system
RUN gem install bundler

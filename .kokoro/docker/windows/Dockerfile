FROM microsoft/windowsservercore:ltsc2016

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

ENV chocolateyUseWindowsCompression=false
ENV HOMEPATH=\\Users\\ContainerAdministrator
ENV HOMEDRIVE=C:
ENV HOME=C:\\Users\\ContainerAdministrator

# Fixes https://cloud.google.com/compute/docs/containers/#mtu_failures
# There is a similar script that has to run periodically on the VM as well.
RUN $output = netsh interface ipv4 show subinterfaces; \
    for ($i = 0; $i -le ($output.length - 1); $i += 1) { \
        if($output[$i] -like '*vEthernet*') { \
            $interfaces = $output[$i] \
        } \
    }; \
    $interfaces = $interfaces -replace '\d+\s+', ''; \
    $interface = $interfaces.Trim().TrimEnd().TrimStart(); \
    netsh interface ipv4 set subinterface interface=$interface mtu=1460 store=persistent

RUN iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); \
    choco feature disable --name showDownloadProgress

RUN choco feature enable -n=allowGlobalConfirmation; \
    choco install git

# Rubocop expects us to use native line endings
RUN git config --global core.autocrlf true

RUN [Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'; \
    Invoke-WebRequest -Method Get -Uri https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.5.3-1/rubyinstaller-devkit-2.5.3-1-x64.exe -OutFile C:\rubyinstaller.exe ; \
	Start-Process C:\rubyinstaller.exe -ArgumentList '/silent' -Wait ; \
	Remove-Item C:\rubyinstaller.exe -Force

RUN C:\Ruby25-x64\bin\ridk install 1 2 3

RUN gem install --no-document bundler:1.17.3

RUN gem update --system

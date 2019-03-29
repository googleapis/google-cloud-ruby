FROM microsoft/windowsservercore:ltsc2016

ENV chocolateyUseWindowsCompression false

RUN powershell -Command \
    $output = netsh interface ipv4 show subinterfaces; \
    for ($i = 0; $i -le ($output.length - 1); $i += 1) { \
        if($output[$i] -like '*vEthernet*') { \
            $interfaces = $output[$i] \
        } \
    }; \
    $interfaces = $interfaces -replace '\d+\s+', ''; \
    $interface = $interfaces.Trim().TrimEnd().TrimStart(); \
    netsh interface ipv4 set subinterface interface=$interface mtu=1460 store=persistent

RUN powershell -Command \
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); \
    choco feature disable --name showDownloadProgress

RUN powershell -Command \
    choco feature enable -n=allowGlobalConfirmation; \
    choco install git; \
    choco install ruby --version 2.6.1.1; \
    choco install msys2 --params "/NoUpdate"

RUN powershell -Command \
    ridk install 2 3

RUN powershell -Command \
    gem install bundler:1.17.3

RUN powershell -Command \
    $env_vars = Get-ChildItem Env: ; \
    for ($i = 0; $i -le ($env_vars.length - 1); $i += 1) { \
        foreach($k in $env_vars[$i].Keys) { \
            SETX $k.Name $k.Value \
        } \
    };

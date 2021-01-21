@ECHO OFF

2>NUL CALL :%1_%2
IF ERRORLEVEL 1 CALL :DEFAULT_CASE

EXIT /B

:init_
    IF　EXIST ..\sonatype-install-master (
    
        XCOPY /s /e ..\sonatype-install-master c:\sonatype\ > NUL
        CD c:\sonatype\
    )

    IF EXIST ..\sonatype-install-master (
        RMDIR /Q /S "..\sonatype-install-master"
    )
    GOTO END_CASE

:doctor_
    # Check for java
    ECHO Checking Java command ...
    where /q java && (
        ECHO [OK]
    ) || (
        ECHO [!] Java not found
        ECHO    Type these two commands in sequence:
        ECHO    set path=%%PATH%%;c:\sonatype\java\bin\
        ECHO    setx /m PATH "%%PATH%%;c:\sonatype\java\bin\"
        GOTO END_CASE
    )
    ECHO.
    
    ECHO Validating certificate ...
    java -jar nxiq\certificate\SSLPoke.jar clm.sonatype.com 443 1> NUL 2> tmp 
    FOR /F %%A in ("tmp") DO If %%~zA equ 0 (
        ECHO [OK]
        
    ) ELSE (
        ECHO [!] Validation failed
        ECHO    Open https://clm.sonatype.com/ping in the browser
        ECHO    Download .DER X509 certificate to c:\sonatype\nxiq\certificate\sonatype.cer
        ECHO    Then, use this command to import .CER certificate:
        ECHO    keytool -importcert -file "nxiq\certificate\sonatype.cer" -storepass changeit -keystore "java\jre\lib\security\cacerts" -alias clm.sonatype.com
        
    )
    DEL tmp
    
    GOTO END_CASE
    
:install_nxiq
    ECHO Installing Nexus IQ Server Service ...
    CALL nxiq\bin\clm.bat install
    CALL nxiq\bin\clm.bat start
    GOTO END_CASE

:start_nxiq
    ECHO Starting Nexus IQ Server Service ...
    CALL nxiq\bin\clm.bat start
    GOTO END_CASE

:stop_nxiq
    ECHO stopping Nexus IQ Server Service ...
    CALL nxiq\bin\clm.bat stop
    GOTO END_CASE

:restart_nxiq
    ECHO stopping Nexus IQ Server Service ...
    CALL nxiq\bin\clm.bat stop
    ECHO Starting Nexus IQ Server Service ...
    CALL nxiq\bin\clm.bat start
    GOTO END_CASE

:remove_nxiq
    ECHO Removing Nexus IQ Server Service ...
    CALL nxiq\bin\clm.bat uninstall
    GOTO END_CASE

:install_nxrm
    ECHO Installing Nexus Repository Manager Service ...
    CALL nxrm\nexus\bin\nexus.exe /install
    GOTO END_CASE

:start_nxrm
    ECHO Starting Nexus Repository Manager Service ...
    CALL nxrm\nexus\bin\nexus.exe /start
    GOTO END_CASE

:stop_nxrm
    ECHO stopping Nexus Repository Manager Service ...
    CALL nxrm\nexus\bin\nexus.exe /stop
    GOTO END_CASE

:restart_nxrm
    ECHO stopping Nexus Repository Manager Service ...
    CALL nxrm\nexus\bin\nexus.exe /stop
    ECHO Starting Nexus Repository Manager Service ...
    CALL nxrm\nexus\bin\nexus.exe /start
    GOTO END_CASE

:remove_nxrm
    ECHO Removing Nexus Repository Manager Service ...
    CALL nxrm\nexus\bin\nexus.exe /uninstall
    GOTO END_CASE

    
:DEFAULT_CASE
    ECHO Usage:
    ECHO    sonatype.bat [command] [app]
    ECHO.
    ECHO Command:
    ECHO    install     Install as a service
    ECHO    start       Start service
    ECHO    stop        Stop service
    ECHO    restart     Restart service
    ECHO    remove      Remove service
    ECHO    doctor      Check prerequisites
    ECHO.
    ECHO App:
    ECHO    nxiq        Nexus IQ Server
    ECHO    nxrm        Nexus Repository Manager
    GOTO END_CASE
    
:END_CASE
    VER > NUL # reset ERRORLEVEL
    GOTO :EOF # return from CALL

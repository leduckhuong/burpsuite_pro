@echo off
setlocal enabledelayedexpansion

REM ==========================================
REM Burp Suite Professional Installer for Windows
REM Install directory: C:\Burpsuite
REM Requirement: Windows with curl + JDK 21 in PATH
REM ==========================================

set INSTALL_DIR=C:\Burpsuite

echo [*] Checking install directory...
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
)

echo [*] Copying loader.jar and icon...
copy /Y loader.jar "%INSTALL_DIR%\"
copy /Y burpsuitepro.ico "%INSTALL_DIR%\"

echo [*] Downloading the latest Burp Suite release...
cd /d "%INSTALL_DIR%"

REM Fetch release page
curl -s -o releases.html https://portswigger.net/burp/releases

REM Extract version (simple: first YYYY-MM-DD found)
for /f "tokens=2 delims=-<> " %%A in ('findstr /r "professional-community-[0-9][0-9][0-9][0-9]" releases.html') do (
    set VERSION=%%A
    goto :foundver
)
:foundver

echo [*] Latest version: %VERSION%
set DOWNLOAD_URL=https://portswigger-cdn.net/burp/releases/download?product=pro^&version=%VERSION%^&type=jar
curl -L -o "burpsuite_pro_v%VERSION%.jar" "%DOWNLOAD_URL%"


echo [*] Creating burpsuite.bat launcher...
(
echo @echo off
echo java --add-opens=java.desktop/javax.swing=ALL-UNNAMED ^
 --add-opens=java.base/java.lang=ALL-UNNAMED ^
 --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED ^
 --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED ^
 --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED ^
 -javaagent:"%INSTALL_DIR%\loader.jar" -noverify -jar "%INSTALL_DIR%\burpsuite_pro_v%VERSION%.jar"
) > "%INSTALL_DIR%\burpsuite.bat"

echo [*] Creating burploader.bat (Keygen)...
(
echo @echo off
echo java -jar "%INSTALL_DIR%\loader.jar"
) > "%INSTALL_DIR%\burploader.bat"

echo [*] Starting Keygen and Burp Suite...
start cmd /c "%INSTALL_DIR%\burploader.bat"
timeout /t 3 >nul
start cmd /c "%INSTALL_DIR%\burpsuite.bat"

echo [✓] Burp Suite Professional installation completed!
pause
endlocal

@echo off
REM Atalho para o iniciar.ps1 (duplo clique ou "iniciar.bat"). Argumentos são repassados.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0iniciar.ps1" %*
pause

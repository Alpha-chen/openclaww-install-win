Write-Host "Copying install script into WSL..."

wsl mkdir -p ~/openclaw-install

wsl bash -c "cat > ~/openclaw-install/linux-install.sh" < linux-install.sh

Write-Host "Running installation inside Ubuntu..."

wsl bash ~/openclaw-install/linux-install.sh

Write-Host "OpenClaw installation finished."
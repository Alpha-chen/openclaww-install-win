Write-Host "Installing WSL2 and Ubuntu..."

wsl --install -d Ubuntu

Write-Host "Waiting for installation..."
Start-Sleep -Seconds 20

Write-Host "Setting default WSL version..."
wsl --set-default-version 2

Write-Host "WSL installation complete."
Write-Host "Please open Ubuntu once to create user account."
# 解决 OpenClaw 报「没有 vm」— 启用 WSL 所需虚拟机组件
# 请以管理员身份运行 PowerShell 后执行本脚本

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw 修复：启用 WSL 虚拟机支持" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否以管理员运行（非必须，但 DISM 需要管理员）
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "建议：以管理员身份运行 PowerShell 再执行本脚本，否则可能无法启用组件。" -ForegroundColor Yellow
    Write-Host "继续尝试执行..." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "[1/3] 启用「虚拟机平台」(VirtualMachinePlatform)..." -ForegroundColor Green
try {
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    if ($LASTEXITCODE -ne 0) { throw "DISM 返回错误" }
} catch {
    Write-Host "失败: $_" -ForegroundColor Red
    Write-Host "请确认已用管理员身份运行 PowerShell。" -ForegroundColor Yellow
    exit 1
}

Write-Host "[2/3] 启用「适用于 Linux 的 Windows 子系统」(WSL)..." -ForegroundColor Green
try {
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    if ($LASTEXITCODE -ne 0) { throw "DISM 返回错误" }
} catch {
    Write-Host "失败: $_" -ForegroundColor Red
    exit 1
}

Write-Host "[3/3] 检查 WSL 是否已安装..." -ForegroundColor Green
$wslOk = $false
try {
    $wslList = wsl -l -v 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host $wslList
        $wslOk = $true
    }
} catch {
    # 忽略，可能尚未安装
}

if (-not $wslOk) {
    Write-Host "当前尚未安装 WSL 或 Ubuntu。重启后将自动提示安装，或请手动执行：" -ForegroundColor Yellow
    Write-Host "  wsl --install -d Ubuntu" -ForegroundColor White
} else {
    Write-Host "WSL 已就绪。若之前报「没有 vm」，重启后应可正常使用。" -ForegroundColor Green
}

Write-Host ""
Write-Host "*** 请重启电脑以使「虚拟机平台」生效 ***" -ForegroundColor Magenta
Write-Host "重启后请执行：" -ForegroundColor Cyan
Write-Host "  1. 若尚未安装 Ubuntu: wsl --install -d Ubuntu" -ForegroundColor White
Write-Host "  2. 安装 OpenClaw: .\3-setup-openclaw.ps1" -ForegroundColor White
Write-Host "  3. 启动 OpenClaw: .\start-openclaw.ps1" -ForegroundColor White
Write-Host ""

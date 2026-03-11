 **Windows → WSL2 → Ubuntu → Node → OpenClaw → 启动脚本** 的完整自动化方案。
思路是用 **PowerShell 脚本 orchestrate + WSL 内 bash 脚本执行 Linux 环境安装**。这样稳定且可重复执行。

涉及软件：

* Windows Subsystem for Linux
* Ubuntu
* Node.js
* OpenClaw

---

# 一、脚本结构（推荐）

建议放在一个目录：

```
openclaw-install/
│
├── install-wsl.ps1
├── setup-openclaw.ps1
├── start-openclaw.ps1
└── linux-install.sh
```

职责：

| 脚本                 | 作用                           |
| ------------------ | ---------------------------- |
| install-wsl.ps1    | 安装 WSL + Ubuntu              |
| setup-openclaw.ps1 | 进入 Ubuntu 安装 Node + OpenClaw |
| linux-install.sh   | Linux 环境安装脚本                 |
| start-openclaw.ps1 | 以后快速启动 agent                 |

---

# 二、install-wsl.ps1

**安装 WSL + Ubuntu**

```powershell
Write-Host "Installing WSL2 and Ubuntu..."

wsl --install -d Ubuntu

Write-Host "Waiting for installation..."
Start-Sleep -Seconds 20

Write-Host "Setting default WSL version..."
wsl --set-default-version 2

Write-Host "WSL installation complete."
Write-Host "Please open Ubuntu once to create user account."
```

执行：

```powershell
powershell -ExecutionPolicy Bypass -File install-wsl.ps1
```

第一次会让你：

```
Create UNIX username
Create password
```

---

# 三、linux-install.sh

这是 **Ubuntu 内执行脚本**。

```bash
#!/bin/bash

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing dependencies..."
sudo apt install -y curl git build-essential

echo "Installing Node.js 20..."

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

echo "Checking versions..."
node -v
npm -v

echo "Installing OpenClaw..."

sudo npm install -g openclaw

echo "Initializing OpenClaw..."

openclaw init

echo "Installation complete!"
```

保存后需要：

```bash
chmod +x linux-install.sh
```

---

# 四、setup-openclaw.ps1

**PowerShell 调用 WSL 执行 Linux 安装**

```powershell
Write-Host "Copying install script into WSL..."

wsl mkdir -p ~/openclaw-install

wsl bash -c "cat > ~/openclaw-install/linux-install.sh" < linux-install.sh

Write-Host "Running installation inside Ubuntu..."

wsl bash ~/openclaw-install/linux-install.sh

Write-Host "OpenClaw installation finished."
```

执行：

```powershell
powershell -ExecutionPolicy Bypass -File setup-openclaw.ps1
```

这个脚本会自动：

1. 进入 Ubuntu
2. 安装 Node
3. 安装 npm
4. 安装 OpenClaw
5. 初始化 agent

---

# 五、start-openclaw.ps1

以后 **Windows 直接启动 agent**：

```powershell
Write-Host "Starting OpenClaw in WSL..."

wsl bash -c "cd ~ && openclaw start"
```

执行：

```powershell
powershell -ExecutionPolicy Bypass -File start-openclaw.ps1
```

---

# 六、测试 Agent

进入：

```powershell
wsl
```

然后：

```bash
openclaw chat
```

如果能聊天说明成功。

---

# 七、最终使用流程

只需执行三步：

### 1 安装 WSL

```
install-wsl.ps1
```

---

### 2 安装 OpenClaw

```
setup-openclaw.ps1
```

---

### 3 启动 Agent

```
start-openclaw.ps1
```

---

# 八、故障排除：提示「没有 vm」

运行 OpenClaw 或执行 `start-openclaw.ps1` / `wsl` 时出现 **「没有 vm」** 或类似“需要虚拟机/虚拟机平台”的提示，说明 **WSL 依赖的 Windows 虚拟机组件未启用**，或 **WSL 尚未安装**。

## 原因简述

- OpenClaw 在 Windows 上通过 **WSL2（Ubuntu）** 运行，WSL2 依赖 Windows 的「虚拟机平台」。
- 若未启用该组件或未安装 WSL，就会报“没有 vm”或无法启动 WSL。

## 解决步骤

### 1. 用脚本一键修复（推荐）

在 **以管理员身份打开的 PowerShell** 中执行：

```powershell
cd "d:\XPG\openclaw\win-install-openclaw"
powershell -ExecutionPolicy Bypass -File fix-no-vm.ps1
```

脚本会：启用「虚拟机平台」和「适用于 Linux 的 Windows 子系统」→ 安装/更新 WSL → 提示重启。**重启完成后**再执行下面的步骤 2。

### 2. 手动启用（若不用脚本）

在 **以管理员身份打开的 PowerShell** 中依次执行：

```powershell
# 启用「虚拟机平台」（WSL2 必需）
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 启用「适用于 Linux 的 Windows 子系统」
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

执行后 **必须重启电脑**。重启后再执行：

```powershell
wsl --install -d Ubuntu
```

首次会要求创建 Ubuntu 用户名和密码。

### 3. 确认 WSL 正常

重启并安装好 Ubuntu 后，在 PowerShell 中执行：

```powershell
wsl -l -v
```

应能看到 `Ubuntu` 且版本为 `2`。然后：

```powershell
wsl bash -c "echo OK"
```

若输出 `OK`，说明 WSL 已就绪，可以按文档执行 `setup-openclaw.ps1` 或 `start-openclaw.ps1`。

### 4. 仍不行的情形

- **BIOS 虚拟化**：进 BIOS 确认已开启 CPU 虚拟化（Intel VT-x 或 AMD-V）。
- **Windows 版本**：需 Windows 10 版本 19041 及以上或 Windows 11。
- **家庭版**：若提示与 Hyper-V 相关，可先尝试只启用上面两个组件并重启，多数情况下足够 WSL2 使用。

---

# 九、进阶（推荐）

后面你可能还会加：

* Ollama 本地模型
* Telegram bot
* Feishu bot

我可以给你一套 **完整自动化版本（企业级脚本）**：

一个脚本自动完成：

```
Windows
 └─ WSL
     └─ Ubuntu
         ├─ Node
         ├─ OpenClaw
         ├─ Ollama
         └─ Llama3
```

甚至可以做到：

**双击 PowerShell → 10分钟生成 AI Agent 环境。**



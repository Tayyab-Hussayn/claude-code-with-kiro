# 🚀 Claude Code with Kiro CLI - Complete Linux Setup Guide

> **Use Claude Code for FREE with Kiro CLI!**

This guide provides a step-by-step walkthrough for setting up Claude Code with Kiro CLI on Linux & windows systems (tested on Arch Linux). By following this guide, you'll have a fully functional Claude Code setup using Kiro's free tier without spending a dime.


## 🎯 Overview

### What is this setup?

This tutorial teaches you how to:
- Use **Kiro CLI** (AWS CodeWhisperer) for authentication
- Set up a **local gateway** that translates OpenAI-compatible requests to Kiro's API
- Connect **Claude Code** to use Kiro's free credits
- Get access to Claude 4.5 sonnet completely free

### Architecture

```
Claude Code → Router → Kiro Gateway → Kiro CLI → AWS CodeWhisperer API
```

### Why use this method?

- ✅ **100% Free** - credits from Kiro CLI
- ✅ **No API Key Required** - Uses OAuth authentication
- ✅ **Full Claude Access** - All Claude 4 models available
- ✅ **Privacy Focused** - All processing happens locally through your gateway
- ✅ **Learning Purpose** - Understand how authentication tokens work in practice

---

## 🔧 Prerequisites

Before starting, ensure you have the following installed:

### Required Software

| Software | Minimum Version | Installation Command (Arch) |
|----------|-----------------|----------------------------|
| Python | 3.10+ | `sudo pacman -S python` |
| Node.js | Latest LTS | `sudo pacman -S nodejs npm` |
| Git | Any | `sudo pacman -S git` |
| pip | Latest | `sudo pacman -S python-pip` |

### Verify Installation

```bash
# Check Python version
python --version

# Check Node.js version
node --version

# Check npm version
npm --version

# Check Git version
git --version
```

---

## 📦 Installation Steps

### Step 1: Install Kiro CLI

```bash
# Install Kiro CLI globally via npm
npm install -g @aws/kiro-cli

# Verify installation
kiro --version
```

### Step 2: Login to Kiro CLI

```bash
# Login to cli
kiro login
```

Follow the authentication process in your browser. After successful login, verify with:

✅ **Important:** Keep your Kiro CLI session active throughout the setup.

---

### Step 3: Set Up Kiro OpenAI Gateway

This gateway creates a local server that translates OpenAI-compatible requests to Kiro's API.

#### 3.1 Clone the Repository

```bash
# Navigate to your home directory
cd ~

# Clone the gateway repository
https://github.com/Tayyab-Hussayn/claude-code-with-kiro.git

# Enter the directory
cd kiro-openai-gateway
```

#### 3.2 Install Python Dependencies

```bash
# Install required packages
pip install -r requirements.txt
```

#### 3.3 Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit the configuration
nano .env
```

#### 3.4 Update .env File

In the `.env` file, make these changes:

1. **Comment out the IDE credentials** (add `#` at the start):
```bash
# KIRO_CREDS_FILE="~/.aws/sso/cache/kiro-auth-token.json"
```

2. **Enable CLI database** (uncomment or add):
```bash
KIRO_CLI_DB_FILE="~/.local/share/kiro-cli/data.sqlite3"
```

3. **Set your proxy API key** (choose any password):
```bash
PROXY_API_KEY="your-super-secret-password-123"
```

**⚠️ Important:** Remember this password - you'll need it in the router configuration!

Save and exit (Ctrl+X, then Y, then Enter).

#### 3.5 Start the Gateway Server

```bash
python main.py
```

✅ **Success Indicator:** You should see:
```
Server running at http://0.0.0.0:8000
```

#### 3.6 Test the Gateway

Open a **new terminal** and run:

```bash
curl http://localhost:8000
```

Expected response:
```json
{"status":"ok","message":"Kiro Gateway is running","version":"2.3"}
```

🎉 If you see this, your gateway is working correctly!

**📌 Note:** Keep this terminal running. The gateway must stay active for Claude Code to work.

---

### Step 4: Install Claude Code and Router

#### 4.1 Install Required Packages

```bash
# Install official Claude Code CLI
npm install -g @anthropic-ai/claude-code

# Install the router
npm install -g @musistudio/claude-code-router
```

#### 4.2 Verify Installation

```bash
# Check Claude Code
claude --version

# Check router
ccr --version
```

---

## ⚙️ Configuration

### Step 5: Configure Claude Code Router

#### 5.1 Create Configuration Directory

```bash
mkdir -p ~/.claude-code-router
```

#### 5.2 Create Configuration File

```bash
nano ~/.claude-code-router/config.json
```

#### 5.3 Paste This Configuration

```json
{
  "LOG": true,
  "LOG_LEVEL": "debug",
  "Providers": [
    {
      "name": "kiro",
      "api_base_url": "http://localhost:8000/v1/chat/completions",
      "api_key": "your-super-secret-password-123",
      "models": [
        "claude-sonnet-4-5",
        "claude-haiku-4-5"
      ],
      "transformer": {
        "use": ["openrouter"]
      }
    }
  ],
  "Router": {
    "default": "kiro,claude-sonnet-4-5",
    "think": "kiro,claude-sonnet-4-5",
    "background": "kiro,claude-sonnet-4-5",
    "longContext": "kiro,claude-sonnet-4-5",
    "webSearch": "kiro,claude-sonnet-4-5"
  }
}
```

**⚠️ Critical:** The `api_key` value **must match** the `PROXY_API_KEY` you set in the `.env` file!

#### 5.4 Configuration Explained

| Key | Description |
|-----|-------------|
| `api_base_url` | Points to your local Kiro gateway server |
| `api_key` | Must match `PROXY_API_KEY` from `.env` file |
| `models` | Available Claude models through Kiro |
| `Router.default` | Default model for all requests |
| `Router.think` | Model used for complex reasoning tasks |
| `Router.background` | Model for background processing |

Save and exit (Ctrl+X, then Y, then Enter).

---

## 🚀 Usage

### Step 6: Launch Claude Code

#### 6.1 Start the Router Service

Open a **new terminal** (keeping the gateway running in the first one):

```bash
ccr start
```

✅ This starts the router service in the background.

#### 6.2 Launch Claude Code

```bash
ccr code
```

This will open the Claude Code interface connected to Kiro!

#### 6.3 Test Your Setup

Try a simple prompt:

```
Hi! Can you confirm you're working? What model are you using?
```

🎉 **Congratulations!** You're now using Claude Code with Kiro's free credits!

---

### Terminal Management

You should have **2 terminals running**:

| Terminal | Command | Purpose |
|----------|---------|---------|
| Terminal 1 | `python main.py` | Kiro Gateway Server (must stay running) |
| Terminal 2 | `ccr code` | Claude Code Interface |

---

### Useful Commands

```bash
# Check which model is active
ccr model

# Stop the router
ccr stop

# Restart the router
ccr restart

# View router logs
ccr logs

# Check router status
ccr status
```
## Happy coding with claude. 

## 📧 Contact

**Maintainer:** Tayyab Hussain
- GitHub: [@tayyabhussayn](https://github.com/Tayyab-Hussayn)
- LinkedIn: [Tayyab Hussayn](https://www.linkedin.com/in/tayyab-hussayn/)
- Email: tayyabhussayn@gmail.com

---

*Last Updated: January 2026*

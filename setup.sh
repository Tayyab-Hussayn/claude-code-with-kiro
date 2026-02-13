#!/bin/bash

# ============================================================================
# Claude Code + Kiro CLI - Automated Setup Script
# ============================================================================
# This script automates the entire setup process for using Claude Code with
# Kiro CLI authentication on Linux systems.
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
GATEWAY_DIR="$HOME/kiro-openai-gateway"
ROUTER_CONFIG_DIR="$HOME/.claude-code-router"
ROUTER_CONFIG_FILE="$ROUTER_CONFIG_DIR/config.json"
PROXY_API_KEY="tayyab123"
KIRO_CLI_DB_PATH="~/.local/share/kiro-cli/data.sqlite3"

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo -e "\n${CYAN}${BOLD}================================${NC}"
    echo -e "${CYAN}${BOLD}$1${NC}"
    echo -e "${CYAN}${BOLD}================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_step() {
    echo -e "\n${MAGENTA}${BOLD}▶ $1${NC}"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# Startup Banner
# ============================================================================

clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   Claude Code + Kiro CLI - Automated Setup Script        ║
║                                                           ║
║   This script will automatically configure:              ║
║   • Kiro OpenAI Gateway                                  ║
║   • Claude Code CLI                                      ║
║   • Claude Code Router                                   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

sleep 2

# ============================================================================
# Step 1: Check Prerequisites
# ============================================================================

print_header "Step 1: Checking Prerequisites"

# Check Python
print_step "Checking Python installation..."
if check_command python3; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    print_success "Python $PYTHON_VERSION is installed"
else
    print_error "Python 3 is not installed. Please install Python 3.10+ first."
    echo -e "${YELLOW}Install with: sudo pacman -S python${NC}"
    exit 1
fi

# Check pip
print_step "Checking pip installation..."
if check_command pip || check_command pip3; then
    PIP_CMD=$(check_command pip3 && echo "pip3" || echo "pip")
    print_success "pip is installed"
else
    print_error "pip is not installed. Please install pip first."
    echo -e "${YELLOW}Install with: sudo pacman -S python-pip${NC}"
    exit 1
fi

# Check Node.js
print_step "Checking Node.js installation..."
if check_command node; then
    NODE_VERSION=$(node --version)
    print_success "Node.js $NODE_VERSION is installed"
else
    print_error "Node.js is not installed. Please install Node.js first."
    echo -e "${YELLOW}Install with: sudo pacman -S nodejs npm${NC}"
    exit 1
fi

# Check npm
print_step "Checking npm installation..."
if check_command npm; then
    NPM_VERSION=$(npm --version)
    print_success "npm $NPM_VERSION is installed"
else
    print_error "npm is not installed. Please install npm first."
    exit 1
fi

# Check Git
print_step "Checking Git installation..."
if check_command git; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    print_success "Git $GIT_VERSION is installed"
else
    print_error "Git is not installed. Please install Git first."
    echo -e "${YELLOW}Install with: sudo pacman -S git${NC}"
    exit 1
fi

# Check Kiro CLI
print_step "Checking Kiro CLI installation..."
if check_command kiro; then
    print_success "Kiro CLI is installed"
    
    # Check if logged in
    if kiro whoami &> /dev/null; then
        print_success "Kiro CLI is logged in"
    else
        print_warning "Kiro CLI is not logged in"
        echo -e "${YELLOW}Please run 'kiro login' before continuing${NC}"
        read -p "Press Enter after logging in..."
    fi
else
    print_error "Kiro CLI is not installed."
    echo -e "${YELLOW}Install with: npm install -g @aws/kiro-cli${NC}"
    echo -e "${YELLOW}Then run: kiro login${NC}"
    exit 1
fi

print_success "All prerequisites are satisfied!"

# ============================================================================
# Step 2: Setup Kiro OpenAI Gateway
# ============================================================================

print_header "Step 2: Setting up Kiro OpenAI Gateway"

# Clone or update repository
print_step "Cloning Kiro OpenAI Gateway repository..."
if [ -d "$GATEWAY_DIR" ]; then
    print_info "Gateway directory already exists, pulling latest changes..."
    cd "$GATEWAY_DIR"
    git pull origin main
    print_success "Repository updated"
else
    print_info "Cloning repository..."
    https://github.com/Tayyab-Hussayn/claude-code-with-kiro.git "$GATEWAY_DIR"
    cd "$GATEWAY_DIR"
    print_success "Repository cloned successfully"
fi

# Install Python dependencies
print_step "Installing Python dependencies (this may take a moment)..."
echo ""
$PIP_CMD install -r requirements.txt --break-system-packages
echo ""
print_success "Python dependencies installed"

# Create .env file with default configuration
print_step "Creating .env configuration file..."
cat > .env << EOF
# Kiro Gateway - Environment Configuration
# Auto-generated by setup script

# ===========================================
# REQUIRED
# ===========================================

# Password to protect YOUR proxy server
PROXY_API_KEY="$PROXY_API_KEY"

# ===========================================
# Kiro CLI SQLite database (AWS SSO)
# ===========================================

# Path to kiro-cli SQLite database
KIRO_CLI_DB_FILE="$KIRO_CLI_DB_PATH"

# ===========================================
# OPTIONAL SETTINGS
# ===========================================

# Log level: TRACE, DEBUG, INFO, WARNING, ERROR, CRITICAL
LOG_LEVEL="INFO"

# Server settings
SERVER_HOST="0.0.0.0"
SERVER_PORT="8000"

# Debug mode: off, errors, all
DEBUG_MODE="off"

# Fake reasoning (extended thinking)
FAKE_REASONING=true
FAKE_REASONING_MAX_TOKENS=4000
FAKE_REASONING_HANDLING=as_reasoning_content

# Truncation recovery
TRUNCATION_RECOVERY=true
EOF

print_success ".env file created with default configuration"
print_info "Default PROXY_API_KEY: $PROXY_API_KEY"

# Test gateway startup (quick check)
print_step "Testing gateway server startup..."
timeout 5 python main.py &> /dev/null &
GATEWAY_PID=$!
sleep 3

if ps -p $GATEWAY_PID > /dev/null; then
    kill $GATEWAY_PID 2>/dev/null || true
    print_success "Gateway server test successful"
else
    print_warning "Gateway test had issues, but continuing..."
fi

# ============================================================================
# Step 3: Install Claude Code CLI
# ============================================================================

print_header "Step 3: Installing Claude Code CLI"

print_step "Checking if Claude Code is already installed..."
if check_command claude; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
    print_success "Claude Code is already installed (version: $CLAUDE_VERSION)"
    print_info "Updating to latest version..."
    echo ""
    npm update -g @anthropic-ai/claude-code
    echo ""
    print_success "Claude Code updated"
else
    print_step "Installing Claude Code CLI..."
    echo ""
    npm install -g @anthropic-ai/claude-code
    echo ""
    print_success "Claude Code CLI installed successfully"
fi

# ============================================================================
# Step 4: Install Claude Code Router
# ============================================================================

print_header "Step 4: Installing Claude Code Router"

print_step "Checking if Claude Code Router is already installed..."
if check_command ccr; then
    CCR_VERSION=$(ccr --version 2>/dev/null || echo "unknown")
    print_success "Claude Code Router is already installed (version: $CCR_VERSION)"
    print_info "Updating to latest version..."
    echo ""
    npm update -g @musistudio/claude-code-router
    echo ""
    print_success "Claude Code Router updated"
else
    print_step "Installing Claude Code Router..."
    echo ""
    npm install -g @musistudio/claude-code-router
    echo ""
    print_success "Claude Code Router installed successfully"
fi

# ============================================================================
# Step 5: Configure Claude Code Router
# ============================================================================

print_header "Step 5: Configuring Claude Code Router"

# Create config directory if it doesn't exist
print_step "Creating router configuration directory..."
mkdir -p "$ROUTER_CONFIG_DIR"
print_success "Directory created: $ROUTER_CONFIG_DIR"

# Create/overwrite config.json
print_step "Creating router configuration file..."
cat > "$ROUTER_CONFIG_FILE" << 'EOF'
{
  "LOG": true,
  "LOG_LEVEL": "debug",
  "Providers": [
    {
      "name": "kiro",
      "api_base_url": "http://localhost:8000/v1/chat/completions",
      "api_key": "tayyab123",
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
EOF

print_success "Router configuration file created"
print_info "Configuration saved to: $ROUTER_CONFIG_FILE"

# ============================================================================
# Step 6: Create Helper Scripts
# ============================================================================

print_header "Step 6: Creating Helper Scripts"

# Create start-gateway.sh
print_step "Creating gateway startup script..."
cat > "$GATEWAY_DIR/start-gateway.sh" << 'EOF'
#!/bin/bash
cd "$HOME/kiro-openai-gateway"
echo "🚀 Starting Kiro Gateway Server..."
echo "📍 Server will run at http://localhost:8000"
echo "⏸️  Press Ctrl+C to stop"
echo ""
python main.py
EOF
chmod +x "$GATEWAY_DIR/setup.sh"
print_success "Created: $GATEWAY_DIR/setup.sh"

# Create start-router.sh
print_step "Creating router startup script..."
cat > "$HOME/start-router.sh" << 'EOF'
#!/bin/bash
echo "🚀 Starting Claude Code Router..."
ccr start
echo ""
echo "✅ Router started successfully!"
echo "📝 You can now run: ccr code"
echo ""
EOF
chmod +x "$HOME/start-router.sh"
print_success "Created: $HOME/start-router.sh"

# Create start-claude.sh
print_step "Creating Claude Code startup script..."
cat > "$HOME/start-claude.sh" << 'EOF'
#!/bin/bash
echo "🚀 Starting Claude Code..."
echo "💡 Make sure the gateway and router are running!"
echo ""
ccr code
EOF
chmod +x "$HOME/start-claude.sh"
print_success "Created: $HOME/start-claude.sh"

# Create status check script
print_step "Creating status check script..."
cat > "$HOME/check-status.sh" << 'EOF'
#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "======================================"
echo "Claude Code + Kiro - Status Check"
echo "======================================"
echo ""

# Check Gateway
echo -n "Gateway Server: "
if curl -s http://localhost:8000 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Running${NC}"
else
    echo -e "${RED}❌ Not Running${NC}"
    echo "   Start with: cd ~/kiro-openai-gateway && python main.py"
fi

# Check Router
echo -n "Router Service: "
if ccr status 2>/dev/null | grep -q "running"; then
    echo -e "${GREEN}✅ Running${NC}"
else
    echo -e "${RED}❌ Not Running${NC}"
    echo "   Start with: ccr start"
fi

# Check Kiro CLI
echo -n "Kiro CLI Auth: "
if kiro whoami &> /dev/null; then
    echo -e "${GREEN}✅ Logged In${NC}"
else
    echo -e "${RED}❌ Not Logged In${NC}"
    echo "   Login with: kiro login"
fi

echo ""
echo "======================================"
EOF
chmod +x "$HOME/check-status.sh"
print_success "Created: $HOME/check-status.sh"

# ============================================================================
# Setup Complete!
# ============================================================================

print_header "🎉 Setup Complete!"

echo -e "${GREEN}${BOLD}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║              ✅ Installation Successful! ✅               ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

print_info "All components have been installed and configured!"
echo ""

# Display next steps
echo -e "${CYAN}${BOLD}📋 Next Steps:${NC}\n"

echo -e "${YELLOW}${BOLD}1. Start the Gateway Server:${NC}"
echo -e "   ${GREEN}cd ~/kiro-openai-gateway && python main.py${NC}"
echo -e "   Or use the helper script: ${GREEN}~/kiro-openai-gateway/start-gateway.sh${NC}"
echo -e "   ${BLUE}ℹ️  Keep this terminal running${NC}\n"

echo -e "${YELLOW}${BOLD}2. In a NEW terminal, start the Router:${NC}"
echo -e "   ${GREEN}ccr start${NC}"
echo -e "   Or use the helper script: ${GREEN}~/start-router.sh${NC}\n"

echo -e "${YELLOW}${BOLD}3. In another NEW terminal, start Claude Code:${NC}"
echo -e "   ${GREEN}ccr code${NC}"
echo -e "   Or use the helper script: ${GREEN}~/start-claude.sh${NC}\n"

echo -e "${CYAN}${BOLD}📊 Useful Commands:${NC}\n"
echo -e "   ${GREEN}ccr status${NC}        - Check router status"
echo -e "   ${GREEN}ccr model${NC}         - View active model"
echo -e "   ${GREEN}ccr logs${NC}          - View router logs"
echo -e "   ${GREEN}ccr stop${NC}          - Stop the router"
echo -e "   ${GREEN}~/check-status.sh${NC} - Check all services status\n"

echo -e "${CYAN}${BOLD}📁 Important Locations:${NC}\n"
echo -e "   Gateway:        ${GREEN}$GATEWAY_DIR${NC}"
echo -e "   Gateway .env:   ${GREEN}$GATEWAY_DIR/.env${NC}"
echo -e "   Router config:  ${GREEN}$ROUTER_CONFIG_FILE${NC}"
echo -e "   API Key:        ${GREEN}$PROXY_API_KEY${NC}\n"

echo -e "${CYAN}${BOLD}🔧 Quick Start (All-in-One):${NC}\n"
echo -e "   Terminal 1: ${GREEN}cd ~/kiro-openai-gateway && python main.py${NC}"
echo -e "   Terminal 2: ${GREEN}ccr start && ccr code${NC}\n"

echo -e "${CYAN}${BOLD}🆘 Troubleshooting:${NC}\n"
echo -e "   If gateway fails: Check ${GREEN}kiro login${NC} status"
echo -e "   If router fails:  Verify ${GREEN}~/.claude-code-router/config.json${NC}"
echo -e "   Check all:        Run ${GREEN}~/check-status.sh${NC}\n"

echo -e "${GREEN}${BOLD}✨ Happy coding with Claude! ✨${NC}\n"

# Optional: Ask if user wants to start services now
echo ""
read -p "Would you like to start the gateway server now? (y/n): " START_NOW

if [[ "$START_NOW" =~ ^[Yy]$ ]]; then
    echo ""
    print_info "Starting gateway server..."
    echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}\n"
    cd "$GATEWAY_DIR"
    python main.py
else
    echo ""
    print_info "Setup complete! Start the services when ready."
    echo ""
fi

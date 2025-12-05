#!/bin/bash

# Script tự động setup GitHub Actions Self-Hosted Runner
# Usage: ./setup-runner.sh YOUR_TOKEN

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Setup GitHub Actions Self-Hosted Runner${NC}"
echo ""

# Kiểm tra token
if [ -z "$1" ]; then
    echo -e "${RED}❌ Lỗi: Cần cung cấp token${NC}"
    echo "Usage: ./setup-runner.sh YOUR_TOKEN"
    echo ""
    echo "Lấy token từ: https://github.com/finallbossl/test_ci-cd/settings/actions/runners"
    exit 1
fi

TOKEN=$1
REPO_URL="https://github.com/finallbossl/test_ci-cd"
RUNNER_NAME="finalboss"

echo -e "${YELLOW}📦 Đang download runner...${NC}"

# Tạo thư mục
mkdir -p ~/actions-runner && cd ~/actions-runner

# Download runner (version mới nhất)
RUNNER_VERSION="2.311.0"
RUNNER_FILE="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"

if [ ! -f "$RUNNER_FILE" ]; then
    echo "Downloading runner ${RUNNER_VERSION}..."
    curl -o "$RUNNER_FILE" -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_FILE}"
else
    echo "Runner file đã tồn tại, bỏ qua download"
fi

# Giải nén
if [ ! -d "./bin" ]; then
    echo -e "${YELLOW}📂 Đang giải nén...${NC}"
    tar xzf "$RUNNER_FILE"
else
    echo "Runner đã được giải nén"
fi

# Cấu hình runner
echo -e "${YELLOW}⚙️  Đang cấu hình runner...${NC}"
./config.sh --url "$REPO_URL" --token "$TOKEN" --name "$RUNNER_NAME" --work _work --replace

# Cài đặt như service
echo -e "${YELLOW}🔧 Đang cài đặt service...${NC}"
sudo ./svc.sh install

# Start service
echo -e "${YELLOW}▶️  Đang start service...${NC}"
sudo ./svc.sh start

# Kiểm tra status
echo ""
echo -e "${GREEN}✅ Setup hoàn tất!${NC}"
echo ""
echo "Kiểm tra status:"
sudo ./svc.sh status

echo ""
echo -e "${GREEN}📋 Kiểm tra runner trên GitHub:${NC}"
echo "https://github.com/finallbossl/test_ci-cd/settings/actions/runners"
echo ""
echo -e "${YELLOW}💡 Lưu ý:${NC}"
echo "- Runner sẽ tự động start khi server reboot"
echo "- Xem logs: sudo journalctl -u actions.runner.*.service -f"
echo "- Restart: sudo ./svc.sh restart"


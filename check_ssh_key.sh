#!/bin/bash

# Script để kiểm tra SSH key format trước khi thêm vào GitHub Secrets

echo "🔍 Kiểm tra SSH Key Format"
echo "=========================="
echo ""

# Màu sắc
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Kiểm tra file key
KEY_FILE="$1"

if [ -z "$KEY_FILE" ]; then
    echo -e "${YELLOW}Usage: ./check_ssh_key.sh <path-to-private-key>${NC}"
    echo "Example: ./check_ssh_key.sh ~/.ssh/github_actions_deploy"
    exit 1
fi

if [ ! -f "$KEY_FILE" ]; then
    echo -e "${RED}❌ File không tồn tại: $KEY_FILE${NC}"
    exit 1
fi

echo "📄 Đang kiểm tra file: $KEY_FILE"
echo ""

# Kiểm tra BEGIN
if grep -q "BEGIN.*PRIVATE KEY" "$KEY_FILE"; then
    echo -e "${GREEN}✅ Có BEGIN marker${NC}"
else
    echo -e "${RED}❌ THIẾU BEGIN marker!${NC}"
    echo "   Key phải bắt đầu bằng: -----BEGIN OPENSSH PRIVATE KEY-----"
    exit 1
fi

# Kiểm tra END
if grep -q "END.*PRIVATE KEY" "$KEY_FILE"; then
    echo -e "${GREEN}✅ Có END marker${NC}"
else
    echo -e "${RED}❌ THIẾU END marker!${NC}"
    echo "   Key phải kết thúc bằng: -----END OPENSSH PRIVATE KEY-----"
    exit 1
fi

# Kiểm tra format OpenSSH
if grep -q "BEGIN OPENSSH PRIVATE KEY" "$KEY_FILE"; then
    echo -e "${GREEN}✅ Đúng format OpenSSH${NC}"
else
    echo -e "${YELLOW}⚠️  Có thể là format cũ (PEM)${NC}"
    echo "   Khuyến nghị: Tạo lại key với ed25519"
fi

# Kiểm tra permissions
PERMS=$(stat -c "%a" "$KEY_FILE" 2>/dev/null || stat -f "%OLp" "$KEY_FILE" 2>/dev/null)
if [ "$PERMS" = "600" ] || [ "$PERMS" = "400" ]; then
    echo -e "${GREEN}✅ Permissions đúng: $PERMS${NC}"
else
    echo -e "${YELLOW}⚠️  Permissions: $PERMS (khuyến nghị: 600)${NC}"
    echo "   Chạy: chmod 600 $KEY_FILE"
fi

# Kiểm tra passphrase
if ssh-keygen -y -f "$KEY_FILE" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Key không có passphrase (tốt cho CI/CD)${NC}"
else
    echo -e "${RED}❌ Key có passphrase hoặc format sai!${NC}"
    echo "   CI/CD cần key không có passphrase"
    exit 1
fi

# Hiển thị fingerprint
FINGERPRINT=$(ssh-keygen -l -f "$KEY_FILE" 2>/dev/null | awk '{print $2}')
if [ -n "$FINGERPRINT" ]; then
    echo -e "${GREEN}✅ Fingerprint: $FINGERPRINT${NC}"
fi

echo ""
echo -e "${GREEN}✅ SSH Key format hợp lệ!${NC}"
echo ""
echo "📋 Để thêm vào GitHub Secrets:"
echo "1. Copy toàn bộ nội dung file:"
echo "   cat $KEY_FILE"
echo ""
echo "2. Vào: https://github.com/finallbossl/test_ci-cd/settings/secrets/actions"
echo "3. Thêm/Update secret: PRODUCTION_SSH_KEY"
echo "4. Paste toàn bộ nội dung (bao gồm BEGIN và END)"
echo ""


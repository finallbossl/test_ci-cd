#!/bin/bash
# Script mở port 8080 cho backend trên Linux server

echo "🔧 Opening port 8080 for backend..."

# Kiểm tra và mở port với ufw (nếu có)
if command -v ufw &> /dev/null; then
    echo "📋 Using ufw..."
    sudo ufw allow 8080/tcp
    sudo ufw status | grep 8080
    echo "✅ Port 8080 opened with ufw"
fi

# Kiểm tra và mở port với iptables (nếu có)
if command -v iptables &> /dev/null; then
    echo "📋 Checking iptables..."
    # Kiểm tra rule đã tồn tại chưa
    if ! sudo iptables -C INPUT -p tcp --dport 8080 -j ACCEPT 2>/dev/null; then
        echo "📋 Adding iptables rule..."
        sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
        echo "✅ Port 8080 opened with iptables"
    else
        echo "✅ Port 8080 rule already exists in iptables"
    fi
fi

# Kiểm tra port có đang listen không
echo ""
echo "📋 Checking if port 8080 is listening..."
if netstat -tlnp 2>/dev/null | grep -q ":8080"; then
    echo "✅ Port 8080 is listening:"
    netstat -tlnp 2>/dev/null | grep ":8080"
elif ss -tlnp 2>/dev/null | grep -q ":8080"; then
    echo "✅ Port 8080 is listening:"
    ss -tlnp 2>/dev/null | grep ":8080"
else
    echo "⚠️  Port 8080 is not listening (backend may not be running)"
fi

echo ""
echo "✨ Done! Test connection from Windows:"
echo "   Test-NetConnection -ComputerName 172.24.180.191 -Port 8080"
echo "   curl http://172.24.180.191:8080/health"


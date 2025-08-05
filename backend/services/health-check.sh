#!/bin/bash

# Weltenwind Services Health Check
echo "🏥 Weltenwind Services Health Check"
echo "===================================="
echo ""

failed_services=0

echo "📊 Service Health Status:"

# Backend API Check
echo -n "Backend API (Port 3000): "
if nc -z localhost 3000 2>/dev/null; then
    echo "✅ HEALTHY"
else
    echo "❌ UNHEALTHY"
    failed_services=$((failed_services + 1))
fi

# Swagger Docs über nginx (nicht separater Port)
echo -n "Swagger Docs (via nginx): "
if curl -k -s https://localhost/docs/ | grep -q "swagger" 2>/dev/null; then
    echo "✅ HEALTHY"
else
    echo "❌ UNHEALTHY"
    failed_services=$((failed_services + 1))
fi

# Prisma Studio Check  
echo -n "Prisma Studio (Port 5555): "
if nc -z localhost 5555 2>/dev/null; then
    echo "✅ HEALTHY"
else
    echo "❌ UNHEALTHY"
    failed_services=$((failed_services + 1))
fi

# PostgreSQL Check
echo -n "PostgreSQL Database: "
if systemctl is-active postgresql >/dev/null 2>&1; then
    echo "✅ ACTIVE"
else
    echo "❌ INACTIVE"
    failed_services=$((failed_services + 1))
fi

echo ""
echo "🌐 nginx Reverse Proxy Status:"

# nginx Service Check
echo -n "nginx Service: "
if systemctl is-active nginx >/dev/null 2>&1 || systemctl is-active weltenwind-nginx >/dev/null 2>&1; then
    echo "✅ ACTIVE"
else
    echo "❌ INACTIVE"
    failed_services=$((failed_services + 1))
fi

# HTTP Port Check
echo -n "HTTP Port 80: "
if nc -z localhost 80 2>/dev/null; then
    echo "✅ OPEN"
else
    echo "❌ CLOSED"
    failed_services=$((failed_services + 1))
fi

# HTTPS Port Check
echo -n "HTTPS Port 443: "
if nc -z localhost 443 2>/dev/null; then
    echo "✅ OPEN"
else
    echo "❌ CLOSED"
    failed_services=$((failed_services + 1))
fi

# HTTPS Proxy Check
echo -n "HTTPS Proxy to Backend: "
if curl -k -s https://localhost/api/health >/dev/null 2>&1; then
    echo "✅ WORKING"
else
    echo "❌ FAILED"
    failed_services=$((failed_services + 1))
fi

# API-Combined YAML Check  
echo -n "API-Combined YAML (HTTPS): "
if curl -k -s https://localhost/api-combined.yaml | grep -q "openapi:" 2>/dev/null; then
    echo "✅ WORKING"
else
    echo "❌ FAILED"
    failed_services=$((failed_services + 1))
fi

echo ""
echo "💽 System Resources:"

# Disk Space Check
disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
echo -n "Disk Space (Root): "
if [ "$disk_usage" -lt 80 ]; then
    echo "✅ OK (${disk_usage}% used)"
else
    echo "⚠️ WARNING (${disk_usage}% used)"
fi

# Memory Check
memory_usage=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
echo -n "Memory Usage: "
echo "✅ OK (${memory_usage}% used)"

echo ""
echo "🔧 systemd Service Status:"

# Service Status Checks (ohne weltenwind-docs)
services="weltenwind-backend weltenwind-studio"
if systemctl is-active weltenwind-nginx >/dev/null 2>&1 || systemctl is-active nginx >/dev/null 2>&1; then
    services="$services weltenwind-nginx"
fi

for service in $services; do
    echo -n "$service: "
    if systemctl is-active "$service" >/dev/null 2>&1; then
        echo "✅ ACTIVE"
    else
        echo "❌ INACTIVE"
        failed_services=$((failed_services + 1))
    fi
done

echo ""
echo "===================================="

# Exit Status
if [ $failed_services -eq 0 ]; then
    echo "✅ All systems healthy!"
    exit 0
else
    echo "⚠️ $failed_services service(s) have issues"
    exit 1
fi

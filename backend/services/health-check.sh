#!/bin/bash

# Weltenwind Services Health Check Script
# Prüft alle Services und deren Gesundheitsstatus

set -e

# Farben für Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏥 Weltenwind Services Health Check${NC}"
echo "===================================="
echo

# Health Check Funktionen
check_backend_health() {
    echo -n "Backend API (Port 3000): "
    if curl -s -f http://localhost:3000/api/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ HEALTHY${NC}"
        return 0
    else
        echo -e "${RED}❌ UNHEALTHY${NC}"
        return 1
    fi
}

check_docs_health() {
    echo -n "Swagger Docs (Port 3001): "
    if nc -z localhost 3001 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ HEALTHY${NC}"
        return 0
    else
        echo -e "${RED}❌ UNHEALTHY${NC}"
        return 1
    fi
}

check_studio_health() {
    echo -n "Prisma Studio (Port 5555): "
    if nc -z localhost 5555 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ HEALTHY${NC}"
        return 0
    else
        echo -e "${RED}❌ UNHEALTHY${NC}"
        return 1
    fi
}

check_postgresql() {
    echo -n "PostgreSQL Database: "
    if systemctl is-active --quiet postgresql; then
        echo -e "${GREEN}✅ ACTIVE${NC}"
        return 0
    else
        echo -e "${RED}❌ INACTIVE${NC}"
        return 1
    fi
}

check_disk_space() {
    echo -n "Disk Space (Root): "
    usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$usage" -lt 80 ]; then
        echo -e "${GREEN}✅ OK (${usage}% used)${NC}"
        return 0
    elif [ "$usage" -lt 90 ]; then
        echo -e "${YELLOW}⚠️  WARNING (${usage}% used)${NC}"
        return 1
    else
        echo -e "${RED}❌ CRITICAL (${usage}% used)${NC}"
        return 2
    fi
}

check_memory_usage() {
    echo -n "Memory Usage: "
    mem_usage=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
    mem_usage_int=${mem_usage%.*}
    
    if [ "$mem_usage_int" -lt 80 ]; then
        echo -e "${GREEN}✅ OK (${mem_usage}% used)${NC}"
        return 0
    elif [ "$mem_usage_int" -lt 90 ]; then
        echo -e "${YELLOW}⚠️  WARNING (${mem_usage}% used)${NC}"
        return 1
    else
        echo -e "${RED}❌ CRITICAL (${mem_usage}% used)${NC}"
        return 2
    fi
}

# Main Health Checks
echo -e "${YELLOW}📊 Service Health Status:${NC}"
backend_status=0
docs_status=0
studio_status=0
postgres_status=0

check_backend_health || backend_status=$?
check_docs_health || docs_status=$?
check_studio_health || studio_status=$?
check_postgresql || postgres_status=$?

echo
echo -e "${YELLOW}💽 System Resources:${NC}"
check_disk_space
check_memory_usage

echo
echo -e "${YELLOW}🔧 systemd Service Status:${NC}"
for service in weltenwind-backend weltenwind-docs weltenwind-studio; do
    echo -n "$service: "
    if systemctl is-active --quiet $service; then
        echo -e "${GREEN}✅ ACTIVE${NC}"
    else
        echo -e "${RED}❌ INACTIVE${NC}"
    fi
done

# Overall Status
echo
echo "===================================="
failed_services=0
[ $backend_status -ne 0 ] && ((failed_services++))
[ $docs_status -ne 0 ] && ((failed_services++))
[ $studio_status -ne 0 ] && ((failed_services++))
[ $postgres_status -ne 0 ] && ((failed_services++))

if [ $failed_services -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL SERVICES HEALTHY${NC}"
    exit 0
else
    echo -e "${RED}⚠️  $failed_services SERVICE(S) UNHEALTHY${NC}"
    echo
    echo "Troubleshooting Commands:"
    echo "- Check logs: sudo journalctl -u weltenwind-backend -f"
    echo "- Restart services: sudo systemctl restart weltenwind.target"
    echo "- Check ports: sudo netstat -tlnp | grep ':300[01]\\|:5555'"
    exit 1
fi
#!/bin/bash

# Định nghĩa mã màu ANSI cho Terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ACTION=$1

case "$ACTION" in
    start)
        echo -e "${YELLOW}Đang khởi động hệ thống QuickBite...${NC}"
        docker compose up -d --build

        echo -e "${YELLOW}Đang kiểm tra trạng thái Database (PostgreSQL)...${NC}"
        DB_READY=false
        TIMEOUT=10
        ELAPSED=0

        while [ $ELAPSED -lt $TIMEOUT ]; do
            # Kiểm tra pg_isready bên trong container database (giả định tên container là storex-postgres hoặc thay thế tương ứng)
            if docker compose exec -T postgres pg_isready -U admin -d storex_db > /dev/null 2>&1; then
                DB_READY=true
                break
            fi
            sleep 2
            ELAPSED=$((ELAPSED + 2))
        done

        if [ "$DB_READY" = false ]; then
            echo -e "${RED}[LỖI] Database không sẵn sàng trong thời gian cho phép!${NC}"
            echo -e "${YELLOW}Hiển thị 20 dòng log cuối của backend:${NC}"
            docker compose logs --tail=20 backend
            echo -e "${RED}Đang tự động dọn dẹp hệ thống (docker compose down)...${NC}"
            docker compose down
            exit 1
        fi

        echo -e "${YELLOW}Database đã sẵn sàng! Đang kiểm tra API /actuator/health của Backend...${NC}"
        API_READY=false
        TIMEOUT=15
        ELAPSED=0

        while [ $ELAPSED -lt $TIMEOUT ]; do
            # Gọi health endpoint của Spring Boot (port 8080)
            RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/health)
            if [ "$RESPONSE" = "200" ]; then
                API_READY=true
                break
            fi
            sleep 2
            ELAPSED=$((ELAPSED + 2))
        done

        if [ "$API_READY" = true ]; then
            echo -e "${GREEN}HỆ THỐNG QUICKBITE HOẠT ĐỘNG ỔN ĐỊNH!${NC}"
            exit 0
        else
            echo -e "${RED}[LỖI] API Backend không phản hồi hoặc báo lỗi (Health Check thất bại)!${NC}"
            echo -e "${YELLOW}Hiển thị 20 dòng log cuối của backend:${NC}"
            docker compose logs --tail=20 backend
            echo -e "${RED}Đang tự động dọn dẹp hệ thống (docker compose down)...${NC}"
            docker compose down
            exit 1
        fi
        ;;

    stop)
        echo -e "${YELLOW}Đang tạm dừng hệ thống QuickBite...${NC}"
        docker compose stop
        echo -e "${GREEN}Đã dừng hệ thống thành công.${NC}"
        ;;

    clean)
        echo -e "${YELLOW}Đang dọn dẹp sạch sẽ tài nguyên (bao gồm cả volumes)...${NC}"
        docker compose down -v
        echo -e "${GREEN}Đã dọn dẹp sạch sẽ toàn bộ tài nguyên.${NC}"
        ;;

    *)
        echo -e "${RED}Cách sử dụng không hợp lệ!${NC}"
        echo "Sử dụng: $0 [start | stop | clean]"
        exit 1
        ;;
es-ac
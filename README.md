# StoreX Multi-Environment Deployment

Hệ thống quản lý cấu hình Docker Compose tách biệt giữa **Staging** và **Production** nhằm tuân thủ nguyên tắc DRY và đảm bảo tính an toàn cho môi trường Production.

## Cấu trúc file
- `docker-compose.yml`: Khung cấu hình chung (Base).
- `docker-compose.override.yml`: Cấu hình phục vụ Staging/Dev (tự động load, mở port debug, 1 replica).
- `docker-compose.prod.yml`: Cấu hình chuyên biệt cho Production (3 replicas, restart always, giới hạn RAM 512M).

## Hướng dẫn sử dụng

### 1. Chạy trên môi trường Staging (Local Development)
```bash
docker compose up -d

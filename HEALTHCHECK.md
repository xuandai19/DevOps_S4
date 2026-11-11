# StoreX – Docker Compose Healthcheck và Volumes

## 1. Mục đích

Bổ sung Healthcheck cho PostgreSQL và Redis để đảm bảo Backend chỉ khởi động khi các dịch vụ phụ thuộc đã sẵn sàng.

Đồng thời sử dụng Docker Named Volume để bảo toàn dữ liệu PostgreSQL khi container bị xóa.

## 2. Healthcheck PostgreSQL

Sử dụng lệnh:

`pg_isready -U admin -d storex_db`

Lệnh này kiểm tra PostgreSQL đã sẵn sàng nhận kết nối hay chưa.

## 3. Healthcheck Redis

Sử dụng lệnh:

`redis-cli ping`

Nếu Redis hoạt động bình thường, hệ thống trả về `PONG`.

## 4. Depends_on

Sử dụng:

`condition: service_healthy`

Backend chỉ khởi động khi cả PostgreSQL và Redis đạt trạng thái healthy.

Điều này giúp hạn chế lỗi kết nối do Backend khởi động quá sớm.

## 5. Docker Volumes

Khai báo:

`storex_postgres_data:/var/lib/postgresql/data`

Named Volume giúp lưu dữ liệu PostgreSQL độc lập với vòng đời container.

Khi chạy `docker compose down`, container bị xóa nhưng dữ liệu vẫn được giữ lại trong volume.

Khi chạy lại `docker compose up -d`, PostgreSQL sử dụng lại dữ liệu đã lưu.

## 6. Kết quả kiểm thử

- PostgreSQL đạt trạng thái healthy.
- Redis đạt trạng thái healthy.
- Backend khởi động sau khi hai dịch vụ sẵn sàng.
- Dữ liệu PostgreSQL vẫn tồn tại sau khi thực hiện `docker compose down` và `docker compose up -d`.

**Kết luận:** Đã cấu hình thành công Docker Compose Healthcheck, service dependency và persistent volume cho hệ thống StoreX.


## MTProxy Là Gì?

MTProxy là một proxy server sử dụng giao thức MTProto của Telegram, giúp người dùng truy cập Telegram một cách an toàn và ổn định, đặc biệt trong các khu vực bị chặn hoặc hạn chế truy cập. Docker image mtproxy/mtproxy là một phiên bản không chính thức, được xây dựng từ mã nguồn chính thức của Telegram, cung cấp một giải pháp dễ dàng triển khai proxy mà không cần cấu hình phức tạp.

Dưới đây là hướng dẫn chi tiết bằng tiếng Việt để cài đặt và sử dụng MTProxy thông qua Docker, dựa trên thông tin từ  [Docker Hub](https://hub.docker.com/r/mtproxy/mtproxy).

## Yêu cầu

-   Máy chủ với  **Docker**  đã được cài đặt.
-   Kết nối internet và quyền truy cập vào Docker Hub.
-   Cổng 11443 (hoặc cổng tùy chỉnh) mở trên máy chủ để kết nối.

## Hướng dẫn cài đặt

### Bước 1: Tải Docker Image

Trước tiên, bạn cần tải image mtproxy/mtproxy từ Docker Hub. Mở terminal và chạy lệnh sau:

```
docker pull mtproxy/mtproxy
```

Lệnh này sẽ tải phiên bản mới nhất của MTProxy về máy chủ của bạn.

### Bước 2: Chạy MTProxy để kiểm tra

Để thử nghiệm nhanh, bạn có thể chạy container MTProxy mà không cần lưu trữ cấu hình lâu dài. Sử dụng lệnh sau:

```
docker run -it --rm -p 11443:443 mtproxy/mtproxy
```

**Chú thích:**

-   **-it**: Chạy container ở chế độ tương tác.
-   **–rm**: Xóa container sau khi thoát.
-   **-p 11443:443**: Ánh xạ cổng 11443 của máy chủ đến cổng 443 của container.

Sau khi chạy, container sẽ tự động tạo một  **secret**  ngẫu nhiên (mã bí mật) và hiển thị trong log. Log sẽ chứa các thông tin quan trọng như:

-   **Secret**: Mã bí mật để cấu hình proxy.
-   **tg:// link**: Liên kết để cấu hình proxy trực tiếp trong ứng dụng Telegram.
-   **t.me link**: Liên kết để chia sẻ proxy qua Telegram.
-   **External IP**: Địa chỉ IP công cộng của máy chủ.

**Lưu ý**: Nếu bạn sử dụng cổng khác 11443, bạn cần chỉnh sửa liên kết  `tg://`  hoặc  `t.me`  để hoạt động đúng cổng đã chọn.

**Ví dụ output log:**

```
[+] No secret passed. Will generate 1 random ones.
[*] Final configuration:
[*]   Secret 1: ...
[*]   tg:// link for secret 1 auto configuration: tg://proxy?server=...&port=443&secret=...
[*]   t.me link for secret 1: https://t.me/proxy?server=...&port=443&secret=...
[*]   Tag: no tag
[*]   External IP: ...
```

Sao chép liên kết  `tg://`  hoặc  `t.me`  và dán vào ứng dụng Telegram để cấu hình proxy.

### Bước 3: Chạy MTProxy ở chế độ Daemon

Để triển khai MTProxy lâu dài và tự động khởi động lại khi máy chủ hoặc Docker khởi động lại, sử dụng lệnh sau:

```
docker run -d -p 11443:443 --name=mtproxy --restart=always -v mtproxy:/data mtproxy/mtproxy
```

**Giải thích:**

-   **-d**: Chạy container ở chế độ nền (daemon).
-   **–name=mtproxy**: Đặt tên cho container là mtproxy.
-   **–restart=always**: Tự động khởi động lại container khi máy chủ hoặc Docker restart.
-   **-v mtproxy:/data**: Lưu trữ secret và cấu hình trong volume mtproxy để đảm bảo dữ liệu không bị mất khi container khởi động lại.


Sau khi chạy, kiểm tra log để lấy liên kết cấu hình Telegram:

```
docker logs -f mtproxy
```

Sao chép liên kết  `tg://`  hoặc t.me từ log và sử dụng trong ứng dụng Telegram.

![CleanShot 2025 05 26 at 15.52.54](https://dotrungquan.info/wp-content/uploads/2025/05/CleanShot-2025-05-26-at-15.52.54.png "Hướng dẫn cài đặt MTProxy để truy cập Telegram 5")

![CleanShot 2025 05 26 at 15.54.47](https://dotrungquan.info/wp-content/uploads/2025/05/CleanShot-2025-05-26-at-15.54.47.png "Hướng dẫn cài đặt MTProxy để truy cập Telegram 6")

## Mẹo sử dụng

-   **Lưu trữ Secret**: Secret được lưu trong volume  `/data`  và sẽ được giữ nguyên qua các lần nâng cấp container.
-   **Cổng tùy chỉnh**: Bạn có thể thay đổi cổng (ví dụ: -p 8443:443) nhưng cần sửa lại liên kết  `tg://`  hoặc  `t.me`  để khớp với cổng mới.
-   **Khởi động lại định kỳ**: Telegram khuyến nghị khởi động lại container mỗi ngày để cập nhật danh sách IP của Telegram core servers. Bạn có thể thiết lập cron job để tự động hóa:

```
docker restart mtproxy
```

## Đăng ký Proxy với Telegram (Không bắt buộc)

Để theo dõi thống kê sử dụng và kích hoạt tính năng kiếm tiền, bạn có thể đăng ký proxy với Telegram thông qua bot  **@MTProxybot**. Làm theo các bước sau:

1.  Mở Telegram và bắt đầu chat với  **@MTProxybot**.
2.  Làm theo hướng dẫn của bot để đăng ký proxy.
3.  Bot sẽ cung cấp một  **TAG**. Cập nhật container với TAG bằng cách chạy lại với biến môi trường:

```
docker run -d -p 11443:443 --name=mtproxy --restart=always -v mtproxy:/data -e TAG=3f40462915a3e6026a4d790127b95ded mtproxy/mtproxy
```

**Lưu ý**: TAG không được lưu trữ trong volume, vì vậy bạn cần cung cấp lại mỗi khi chạy container mới.

## Cấu hình nâng cao

Bạn có thể tùy chỉnh MTProxy thông qua các biến môi trường. Dưới đây là một số tùy chọn quan trọng:

### 1.  **SECRET/SECRET_COUNT**

-   **SECRET**: Chỉ định secret tùy chỉnh (16 byte ở định dạng hex). Ví dụ:

```
docker run -d -p 11443:443 --name=mtproxy --restart=always -v mtproxy:/data -e SECRET=00baadf00d15abad1deaa51sbaadcafe mtproxy/mtproxy
```

-   **SECRET_COUNT**: Tự động tạo số lượng secret ngẫu nhiên (tối đa 16). Ví dụ:

```
docker run -d -p 11443:443 --name=mtproxy --restart=always -v mtproxy:/data -e SECRET_COUNT=4 mtproxy/mtproxy
```

### 2. WORKERS

Mặc định, MTProxy sử dụng 1 worker, hỗ trợ tối đa 60.000 kết nối. Nếu bạn có nhiều người dùng, tăng số lượng worker:

```
docker run -d -p 11443:443 --name=mtproxy --restart=always -v mtproxy:/data -e WORKERS=16 mtproxy/mtproxy
```

### **3. Các niến môi trường khác**

-   **DEBUG**: Bật chế độ debug (true).
-   **IP**: Chỉ định IP công cộng của máy chủ nếu tự động phát hiện thất bại.
-   **INTERNAL_IP**: IP nội bộ cho NAT.
-   **PORT**: Cổng lắng nghe (mặc định: 443).
-   **INTERNAL_PORT**: Cổng giám sát (mặc định: 2398).  **ARGS**: Thêm tham số tùy chỉnh cho binary mtproto-proxy.

## Giám sát

MTProxy cung cấp số liệu thống kê qua endpoint http://localhost:2398/stats. Để truy cập, chạy lệnh:

```
docker exec mtproxy curl http://localhost:2398/stats
```

**Các số liệu bao gồm:**

-   **ready_targets**: Số lượng Telegram core servers mà proxy sẽ kết nối.
-   **active_targets**: Số lượng server thực tế đã kết nối.
-   **total_special_connections**: Số lượng kết nối client.
-   **total_max_special_connections**: Giới hạn kết nối (60.000 × số worker).

## Khắc phục sự cố

### 1. Client mắc kẹt ở trạng thái “Connecting”

-   Kiểm tra firewall hoặc DPI chặn cổng 11443.
-   Đảm bảo ánh xạ cổng Docker đúng (-p 11443:443).
-   Kiểm tra xem ISP hoặc chính phủ có chặn giao thức MTProto không.

### 2. Client kắc kẹt ở trạng thái “Updating”

-   Kiểm tra firewall giữa proxy và Telegram core servers.
-   Đảm bảo thời gian hệ thống đồng bộ với UTC (sai lệch < 5 giây). Cài đặt ntp hoặc chrony để đồng bộ thời gian.
-   Nếu proxy nằm sau NAT, chỉ định IP và INTERNAL_IP trong biến môi trường.

## Kết luận

Cài đặt MTProxy bằng Docker là một cách đơn giản và hiệu quả để thiết lập proxy cho Telegram. Với các bước trên, bạn có thể nhanh chóng triển khai một proxy server ổn định, hỗ trợ truy cập Telegram ở những khu vực bị hạn chế. Nếu cần tùy chỉnh thêm, hãy sử dụng các biến môi trường để tối ưu hiệu suất và quản lý proxy.

Source [dotrungquan.info](https://dotrungquan.info/cai-dat-mtproxy-de-truy-cap-telegram/).

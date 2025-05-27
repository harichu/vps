
SOCKS5 là một giao thức proxy phổ biến, được nhiều người ưa chuộng nhờ khả năng cải tiến vượt trội so với các phiên bản trước. Trong bài viết này, tôi sẽ hướng dẫn bạn cách thiết lập SOCKS5 trên VPS của riêng mình một cách ngắn gọn và dễ thực hiện.

## SOCKS5 là gì?

SOCKS5 là phiên bản mới nhất của giao thức SOCKS, hoạt động như một cầu nối trung gian giữa máy khách và máy chủ qua proxy. Giao thức này hỗ trợ cả TCP và UDP, mang lại độ bảo mật cao hơn so với SOCKS4. SOCKS5 cung cấp ba phương thức xác thực chính:

-   Không cần xác thực: Kết nối trực tiếp mà không yêu cầu thông tin đăng nhập.
-   Xác thực bằng tên người dùng/mật khẩu: Yêu cầu thông tin đăng nhập để truy cập.
-   GSS-API: Sử dụng xác thực cấp hệ điều hành để kiểm tra danh tính.

## SOCKS5 hoạt động như thế nào?

SOCKS5 định tuyến lưu lượng mạng qua một máy chủ proxy, thay thế địa chỉ IP của bạn bằng IP của proxy trước khi gửi đến đích. Ví dụ:

Nếu IP của bạn là 1.2.3.4 và bạn sử dụng proxy SOCKS5 với IP 5.6.7.8, máy chủ đích (như một trang web) sẽ thấy yêu cầu đến từ IP 5.6.7.8, giúp che giấu IP thực của bạn. Điều này rất hữu ích để vượt qua các giới hạn địa lý hoặc ẩn vị trí. Tuy nhiên, khác với VPN, SOCKS5 không mã hóa lưu lượng, nên dữ liệu vẫn có thể bị theo dõi. Vì vậy, nó chỉ cung cấp mức độ “gần như ẩn danh” và bạn nên kết hợp với các công cụ bảo mật khác để tăng cường an toàn.

![Socks5 proxy hoat dong](https://dotrungquan.info/wp-content/uploads/2025/05/Socks5-proxy-hoat-dong.webp "Hướng dẫn cài đặt SOCKS5 trên VPS 3")

## Chuẩn bị cài đặt SOCKS5

Để thiết lập SOCKS5 trên VPS, bạn cần:

-   VPS: Cấu hình tối thiểu 1 vCPU, 1GB RAM, 10GB ổ cứng.
-   Hệ điều hành: Bài viết này sử dụng AlmaLinux 8.6, nhưng bạn cũng có thể dùng Ubuntu 20.04/22.04 LTS.
-   Công cụ: Docker để triển khai SOCKS5 một cách nhanh chóng.

## Các bước cài đặt SOCKS5

### Bước 1: Cài đặt Docker trên VPS

Chúng ta sẽ sử dụng Docker để triển khai SOCKS5 vì tính tiện lợi và dễ quản lý. Dưới đây là cách cài đặt Docker trên AlmaLinux hoặc Ubuntu.

-   **Trên Ubuntu 20.04/22.04**:

```
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get install ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

-   **Trên AlmaLinux 8.x**

```
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf remove podman buildah
sudo dnf install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
```

### Bước 2: Cài đặt SOCKS5 trên Docker

Sau khi cài đặt Docker, bạn có thể triển khai SOCKS5 bằng lệnh sau:

```
docker run -d --name my-socks5 --restart=always -p 1080:1080 -e PROXY_USER=user1 -e PROXY_PASSWORD=pass123 -e PROXY_PORT=1080 serjs/go-socks5-proxy
```

**Giải thích lệnh**:

-   **–name my-socks5**: Đặt tên container (có thể thay đổi tùy ý).
-   **-p 1080:1080**: Ánh xạ cổng 1080 trên VPS với cổng 1080 của container.
-   **-e PROXY_PORT=1080**: Cổng SOCKS5 sẽ sử dụng.
-   **-e PROXY_USER=user1**: Tên người dùng để xác thực.
-   **-e PROXY_PASSWORD=pass123**: Mật khẩu cho người dùng.

Bạn có thể thay đổi các thông số như cổng, tên người dùng, mật khẩu theo nhu cầu. Nếu muốn thêm người dùng khác, chỉ cần chạy lại lệnh với các thông số khác biệt (không được trùng cổng hoặc tên container).

### Bước 3: Kiểm tra và sử dụng SOCKS5

Sau khi chạy lệnh trên, SOCKS5 đã được triển khai trên VPS. Bạn có thể sử dụng các thông số (IP VPS, cổng, tên người dùng, mật khẩu) để kết nối từ thiết bị của mình.

-   **Trên máy tính**: Sử dụng phần mềm như  **Proxifier**  hoặc  **FoxyProxy**  (tìm trên Google để tải).
-   **Trên Android**: Tải ứng dụng  **SocksDroid**  từ Google Play (miễn phí).
-   **Trên iOS**: Sử dụng các ứng dụng như  **Shadowrocket**  (có thể cần trả phí).

**Lưu ý khi sử dụng SOCKS5**

-   SOCKS5 không mã hóa dữ liệu, nên hãy cân nhắc sử dụng thêm VPN hoặc các công cụ bảo mật nếu cần bảo vệ lưu lượng.
-   Đảm bảo thông tin đăng nhập (tên người dùng, mật khẩu) được lưu trữ an toàn.
-   Nếu gặp vấn đề kết nối, kiểm tra xem cổng trên VPS đã được mở trên tường lửa (firewall) hay chưa.

Source [dotrungquan.info](hhttps://dotrungquan.info/huong-dan-cai-dat-socks5-tren-vps/).

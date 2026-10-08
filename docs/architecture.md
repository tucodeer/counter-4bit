# Kiến trúc bộ đếm 4-bit

## 1. Tổng quan kiến trúc

Bộ đếm 4-bit là một mạch số đồng bộ với clock, có nhiệm vụ tăng giá trị đếm lên 1 sau mỗi cạnh lên (rising edge) của tín hiệu `clk`.

Bộ đếm có 4 bit nên có thể biểu diễn 16 trạng thái:

```text
0000 → 0001 → 0010 → ... → 1110 → 1111
 0       1       2              14      15
```

Sau giá trị 15, bộ đếm quay trở lại 0:

```text
15 → 0
```

Kiến trúc của bộ đếm gồm các thành phần chính:

* 4-bit State Register: lưu giá trị đếm hiện tại.
* Increment Logic: tạo giá trị đếm tiếp theo bằng cách cộng 1.
* Reset Logic: đưa bộ đếm về 0 khi `rst_n` được kích hoạt.
* Clock: quyết định thời điểm State Register cập nhật giá trị mới.

Kiến trúc tổng quát:

```text
                    +----------------------+
                    |                      |
       clk -------->|    4-bit State       |
                    |      Register        |-------> count[3:0]
      rst_n ------->|                      |
                    +----------+-----------+
                               |
                               | current count
                               v
                       +---------------+
                       | Increment +1  |
                       +-------+-------+
                               |
                               | next count
                               +------------------+
                                                  |
                                                  |
                                                  v
                                         4-bit State Register
```

---

## 2. State Register

### 2.1. Chức năng

State Register có nhiệm vụ lưu trạng thái hiện tại của counter.

Ví dụ:

```text
count = 5
```

thì register đang lưu:

```text
0101
```

Giá trị này được giữ nguyên cho đến khi có một cạnh lên của `clk` làm register cập nhật trạng thái mới.

Có thể hình dung:

```text
                +----------------+
next_count ---->|                |
                |  4-bit State   |----> count
       clk ---->|    Register    |
                |                |
                +----------------+
```

### 2.2. Tại sao cần Register?

Counter phải "nhớ" giá trị hiện tại.

Nếu không có register, mạch chỉ có thể tính toán giá trị từ input mà không có nơi lưu trạng thái trước đó.

Ví dụ:

```text
count hiện tại = 7
```

Counter phải giữ giá trị 7 cho đến clock edge tiếp theo.

Sau clock edge:

```text
7 → 8
```

Do đó, register chính là thành phần lưu trữ trạng thái của counter.

---

## 3. Increment Logic

Increment Logic có nhiệm vụ tạo ra giá trị đếm tiếp theo.

Quy tắc:

```text
next_count = count + 1
```

Ví dụ:

```text
count       next_count
----------------------
0000    →   0001
0001    →   0010
0010    →   0011
0011    →   0100
...
1110    →   1111
1111    →   0000
```

Về mặt khái niệm, Increment Logic có thể được xem như một bộ cộng:

```text
             +--------+
count ------>|        |
             | Adder  |----> next_count
       +1 -->|        |
             +--------+
```

Trong RTL, phép cộng này có thể được mô tả đơn giản bằng:

```verilog
count + 1'b1
```

Không cần tự thiết kế từng cổng logic hoặc từng Full Adder trong RTL.

---

## 4. Reset Logic

Counter sử dụng tín hiệu:

```text
rst_n
```

Đây là tín hiệu reset active-low.

Điều đó có nghĩa:

```text
rst_n = 0 → Reset được kích hoạt
rst_n = 1 → Reset không được kích hoạt
```

Khi reset được kích hoạt, State Register phải được đưa về:

```text
count = 0000
```

Hay:

```text
rst_n = 0
    ↓
count = 0
```

Khi reset được giải phóng:

```text
rst_n = 1
```

counter có thể tiếp tục hoạt động bình thường theo clock.

Trong kiến trúc, reset có thể được hiểu là một điều kiện đặc biệt có quyền đưa state về trạng thái ban đầu.

---

## 5. Clock Behavior

Counter hoạt động đồng bộ với tín hiệu `clk`.

State Register chỉ cập nhật trạng thái tại cạnh lên (rising edge) của clock.

Ví dụ:

```text
        ↑       ↑       ↑       ↑
clk  ___|‾‾‾‾‾|___|‾‾‾‾‾|___|‾‾‾‾‾|___

count    0       1       2       3
```

Tại mỗi rising edge:

```text
count → count + 1
```

Giữa hai rising edge, giá trị `count` được giữ nguyên.

Ví dụ:

```text
count = 5

       không có rising edge
              ↓
count = 5
```

Đến rising edge tiếp theo:

```text
count = 6
```

Do đó, clock quyết định thời điểm state của counter thay đổi.

---

## 6. Quan hệ giữa Current State và Next State

Có thể mô tả hoạt động của counter bằng hai khái niệm:

### Current State

Giá trị hiện tại của counter:

```text
count
```

### Next State

Giá trị counter sẽ nhận tại clock edge tiếp theo:

```text
next_count = count + 1
```

Kiến trúc khái niệm:

```text
                 Current State
                      |
                      v
               +-------------+
               | Increment   |
               |    +1       |
               +------+------+
                      |
                      v
                 Next State
                      |
                      v
               +-------------+
               |   Register  |
               +------+------+
                      |
                      v
                 Current State
```

Chu trình này lặp lại ở mỗi clock cycle.

---

## 7. Overflow và Modulo-16

Counter có độ rộng 4-bit:

```text
count[3:0]
```

Do đó chỉ có thể biểu diễn:

```text
0000 → 0
...
1111 → 15
```

Khi counter đang ở 15:

```text
1111
```

và thực hiện phép cộng 1:

```text
  1111
+ 0001
-------
 10000
```

Kết quả toán học là 5 bit:

```text
10000
```

Tuy nhiên State Register của counter chỉ có 4 bit.

Vì vậy chỉ 4 bit thấp được lưu lại:

```text
10000
 ↓
0000
```

Do đó:

```text
15 → 0
```

Đây chính là behavior modulo-16.

Chuỗi đếm hoàn chỉnh:

```text
0 → 1 → 2 → 3 → 4 → ... → 13 → 14 → 15 → 0 → 1 → ...
```

Không cần thêm một mạch phát hiện overflow riêng cho chức năng cơ bản này.

---

## 8. Kiến trúc phần cứng khái niệm

Toàn bộ kiến trúc có thể biểu diễn đơn giản như sau:

```text
                         +------------------+
                         |                  |
              clk ------>|  4-bit State    |
                         |    Register      |------> count[3:0]
             rst_n ----->|                  |
                         +--------+---------+
                                  |
                                  |
                                  | current count
                                  v
                         +------------------+
                         |                  |
                         |  Increment + 1   |
                         |                  |
                         +--------+---------+
                                  |
                                  |
                                  | next count
                                  |
                                  +----------------------+
                                                         |
                                                         |
                                                         v
                                                State Register
```

Trong đó:

* `clk`: xác định thời điểm State Register cập nhật.
* `rst_n`: đưa State Register về 0 khi reset được kích hoạt.
* `count`: giá trị state hiện tại của counter.
* Increment Logic: tạo giá trị tiếp theo bằng cách cộng 1.
* State Register: lưu giá trị counter giữa các clock cycle.

---

## 9. Mô hình hoạt động tổng quát

Khi reset:

```text
rst_n = 0
     ↓
count = 0
```

Sau khi reset được giải phóng:

```text
rst_n = 1
     ↓
Chờ rising edge của clk
     ↓
count = count + 1
```

Quá trình tiếp tục:

```text
         reset
           |
           v
          0
          |
       clk ↑
          |
          v
          1
          |
       clk ↑
          |
          v
          2
          |
         ...
          |
       clk ↑
          |
          v
         15
          |
       clk ↑
          |
          v
          0
          |
         ...
```

Vì counter có 4 bit nên chu kỳ của counter là 16 trạng thái.

---

## 10. Tóm tắt kiến trúc

Kiến trúc của 4-bit Counter được xây dựng từ một state register và logic tạo next state.

Quy tắc chính:

```text
Nếu reset được kích hoạt:
    count = 0

Nếu reset không được kích hoạt:
    tại rising edge của clk:
        count = count + 1
```

Với độ rộng 4-bit, phép cộng sẽ tự tạo behavior quay vòng:

```text
15 → 0
```

Kiến trúc này đơn giản, đồng bộ với clock và phù hợp với yêu cầu của project.

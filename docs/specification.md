# 4-bit Counter Specification

## 1. Project Overview

### English

This project implements a simple synchronous 4-bit binary counter using Verilog HDL.

The counter increments by 1 on each valid rising edge of the clock.
It counts from 0 to 15 and wraps around to 0 after reaching 15.

### Tiếng Việt

Project thiết kế một bộ đếm nhị phân 4-bit đồng bộ bằng Verilog HDL.

Counter tăng 1 sau mỗi cạnh lên hợp lệ của clock.
Giá trị đếm từ 0 đến 15 và quay về 0 sau khi đạt 15.


## 2. Functional Requirements

### English

- The counter width is 4 bits.
- The counter operates synchronously with the clock.
- The counter increments by 1 on each rising edge of `clk`.
- The counter counts from 0 to 15.
- After 15, the counter wraps around to 0.
- An active-low reset `rst_n` is provided.
- When reset is asserted, the counter is cleared to 0.
- The counter output is `count[3:0]`.

### Tiếng Việt

- Counter có độ rộng 4-bit.
- Counter hoạt động đồng bộ với clock.
- Counter tăng 1 tại mỗi cạnh lên của `clk`.
- Counter đếm từ 0 đến 15.
- Sau giá trị 15, counter quay về 0.
- Có tín hiệu reset active-low `rst_n`.
- Khi reset được kích hoạt, counter được đưa về 0.
- Output của counter là `count[3:0]`.


## 3. Interface

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `clk` | Input | 1 bit | Clock signal |
| `rst_n` | Input | 1 bit | Active-low reset |
| `count` | Output | 4 bits | Current counter value |


## 4. Counter Behavior

Under normal operation:

```text
0 → 1 → 2 → 3 → ... → 13 → 14 → 15 → 0 → 1 → ...
The counter increases by one for every rising edge of clk when reset is not asserted.

5. Reset Behavior

The reset signal is active-low.

rst_n = 0
    ↓
count = 0

When reset is asserted, the counter is cleared to zero.

When reset is released:

rst_n = 1

the counter resumes normal counting on subsequent rising clock edges.

6. Overflow Behavior

Because the counter has 4 bits, it can represent values from:

0000 = 0

to

1111 = 15

After reaching 15, the next increment produces:

1111 + 0001 = 0000

Therefore:

14 → 15 → 0 → 1

The counter therefore operates modulo 16.

7. Clock Behavior

The counter state changes only on the rising edge of clk.

Conceptually:

        ↑       ↑       ↑       ↑
clk  ___|‾‾‾‾‾|___|‾‾‾‾‾|___|‾‾‾‾‾|___

count    0       1       2       3

The counter does not continuously change between clock edges.

8. Expected Operation

After reset:

count = 0

After releasing reset, the expected sequence is:

Clock edge    Count
-----------   -----
Reset         0
1             1
2             2
3             3
...           ...
14            14
15            15
16            0
17            1

The expected behavior is therefore:

Reset:
    count = 0

Normal operation:
    0 → 1 → 2 → ... → 14 → 15 → 0 → 1 → ...

---

# 4. Bây giờ hiểu từng requirement

Đây là phần quan trọng hơn việc copy file.

### Requirement 1 — 4-bit

```text
count[3:0]

Có 4 bit nên có:

$$ 2^4 = 16 $$

giá trị khác nhau:

0000 → 0
0001 → 1
...
1111 → 15

Do đó counter có đúng 16 trạng thái.
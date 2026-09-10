# Antigravity Worker cho Codex

Plugin đóng gói bridge và quy trình cộng tác đã tối ưu:

- Codex giữ vai trò lead, BA, SA, chủ trì TDD và review cuối.
- Antigravity là implementation worker trong workspace cô lập.
- Task thông thường dùng `gemini-3.8-flash-high` với effort `medium`; chỉ dùng `high` cho phần phức tạp hoặc nhạy cảm về bảo mật.
- Các lần triển khai tiếp theo của cùng feature tái sử dụng `conversation_id` cũ.
- Mặc định một lần gọi implementation cho mỗi feature để giảm thời gian và quota.
- Không dùng `--dangerously-skip-permissions`.

## Yêu cầu

- Codex CLI có hỗ trợ plugin.
- Node.js 20 trở lên.
- Antigravity CLI (`agy`) đã được cài, đăng nhập và có trong `PATH`.

## Cài đặt

Clone repo bridge, mở PowerShell tại root repo rồi chạy:

```powershell
.\plugins\antigravity-worker\scripts\install.ps1
```

Sau khi cài, mở thread Codex mới để nạp skill và MCP mới.

## Build và kiểm thử

Source bridge chỉ nằm một nơi ở root repo. Runtime trong plugin là file được bundle từ source đó:

```powershell
.\plugins\antigravity-worker\scripts\build-runtime.ps1
.\plugins\antigravity-worker\scripts\test-plugin.ps1
```

Chỉ dùng kiểm thử live khi thực sự cần vì lệnh này gọi Google model và tiêu tốn quota:

```powershell
.\plugins\antigravity-worker\scripts\test-plugin.ps1 -Live
```

Kiểm thử mặc định không gọi model.

<p align="center">
  <picture>
    <source media="(prefers-reduced-motion: reduce) and (prefers-color-scheme: dark)" srcset="assets/logo-rai-white.png">
    <source media="(prefers-reduced-motion: reduce)" srcset="assets/logo-rai-dark.png">
    <source media="(prefers-color-scheme: dark)" type="image/webp" srcset="assets/logo-rai-animated-white.webp">
    <source type="image/webp" srcset="assets/logo-rai-animated-dark.webp">
    <img src="assets/logo-rai-animated.gif" alt="RAI Code" width="640">
  </picture>
</p>

<p align="center">
  <a href="README.md">English</a> · <strong>Tiếng Việt</strong> · <a href="https://code.reasonary.ai/docs">Tài liệu</a>
</p>

**Reasonary AI Code** — trợ lý lập trình AI chạy trong terminal, có công cụ đọc, sửa và thực thi code.

[![Phiên bản](https://img.shields.io/github/v/release/reasonaryai/rai-code?label=latest)](https://github.com/reasonaryai/rai-code/releases)
[![Giấy phép](https://img.shields.io/badge/license-Proprietary-blue)](LICENSE.md)

RAI hỗ trợ nhiều nhà cung cấp model, duy trì ngữ cảnh theo phiên làm việc và tích hợp LSP để phân tích code.

## Tính năng

- **Nhiều model:** chọn model trong danh mục hoặc thêm API tương thích OpenAI/Anthropic.
- **Chuyển model:** đổi model ngay trong phiên mà vẫn giữ ngữ cảnh.
- **Quản lý phiên:** lưu nhiều phiên làm việc cho từng project.
- **LSP:** cung cấp chẩn đoán lỗi, tham chiếu và thông tin code cho agent.
- **Mở rộng:** kết nối MCP (`http`, `stdio`, `sse`), skills, hooks và lệnh tùy chỉnh.
- **Terminal nền:** agent làm việc độc lập trong khi build/test chạy. Dùng `/bt` xem job và output, `/stop` dừng background jobs của phiên hiện tại. Chat nhận completion tự động; Reasonary Responses đọc kết quả bằng ID job.
- **Headless:** chạy không tương tác cho CI/CD, benchmark hoặc agent khác gọi qua CLI.
- **Điều chỉnh reasoning:** dùng **Ctrl+E** hoặc `--reasoning`, tùy khả năng của model.
- **Theo dõi chi phí:** kết quả headless có thống kê token và chi phí USD ước tính.
- **Đa nền tảng:** macOS, Linux, Windows (PowerShell và WSL), FreeBSD, OpenBSD, NetBSD.

## Cài đặt

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/reasonaryai/rai-code/main/install.sh | bash
```

### Windows — PowerShell

```powershell
irm https://raw.githubusercontent.com/reasonaryai/rai-code/main/install.ps1 | iex
```

### Windows — CMD

```cmd
powershell -c "irm https://raw.githubusercontent.com/reasonaryai/rai-code/main/install.ps1 | iex"
```

Script hỏi riêng có cài ripgrep cho tìm kiếm và browser runtime (Chromium,
FFmpeg), kèm danh sách thành phần và phiên bản được ghim. Có ba lựa chọn:
**Yes / No / Install later** (mặc định). No không hỏi lại tự động; Install later
hiện panel xin phép khi tool cần dependency còn thiếu. Chạy không tương tác sẽ
không tự tải runtime chưa được chấp thuận. Có thể cài sau bằng `rai ripgrep install` và `rai browser install`.
Để chạy tự động, dùng `--with-runtimes` / `--without-runtimes` với `install.sh`,
hoặc `-WithRuntimes` / `-WithoutRuntimes` với `install.ps1`.
Dùng `rai ripgrep path` để xem binary tìm kiếm đang dùng.

### Tải thủ công

Tải binary phù hợp tại [GitHub Releases](https://github.com/reasonaryai/rai-code/releases).
Mỗi bản phát hành có checksum SHA256; script cài đặt tự kiểm tra checksum.

## Bắt đầu nhanh

Chạy trong thư mục project:

```bash
# Mở giao diện tương tác
rai

# Chạy một yêu cầu không tương tác
rai run "Giải thích cấu trúc của project này"
```

Lần đầu mở RAI, làm theo hướng dẫn thiết lập provider và model. Dùng **Alt+M** để mở lại bảng chọn model bất cứ lúc nào.

## Reasonary AI: Auker và API key

**Tạo API key tại [Reasonary AI Keys](https://superagent.reasonary.ai/keys).**
Đăng nhập tài khoản RAI và API key dùng cho model là hai phần riêng biệt: gọi Auker cần API key này.

Hai model trong catalog phân biệt hai API, dùng chung API key:

| Model ID trong RAI | API | Vòng lặp agent |
|---|---|---|
| `auker` | Chat Completions | Vòng lặp tools local và các mode chuẩn của RAI |
| `auker-1.0` | Responses | Mode Reasonary Agent (RA), có hoạt động sub-agent trên server |

Với Chat Completions, alias `auker` được ánh xạ sang model ID `auker-1.0` khi gửi tới API.

### Thiết lập trong giao diện

1. Chạy `rai` và đăng nhập tài khoản nếu được yêu cầu.
2. Trong bảng chọn model, chọn **Reasonary AI → Auker 1.0**. Reasonary AI nằm đầu danh sách, kèm URL tạo key ngay dưới tên provider. Sau này có thể mở lại bằng **Alt+M** hoặc lệnh chọn model trong command palette.
3. Nếu chưa có API key, RAI tự mở [trang tạo key](https://superagent.reasonary.ai/keys) trong trình duyệt. Đăng nhập trên website, tạo key và sao chép.
4. Quay lại RAI, dán key vào ô nhập có che ký tự. Nhấn **Enter** để kiểm tra key, rồi nhấn **Enter** lần nữa để lưu và chọn model. Nếu trình duyệt không mở được, mở thủ công URL hiển thị trong bảng nhập key.

Key được lưu qua cấu hình toàn cục như các provider dùng API key khác và được dùng lại ở những lần mở sau.
Chọn `auker-1.0` sẽ kích hoạt và khóa mode **Reasonary Agent (RA)**. Muốn dùng mode khác, hãy chọn model hỗ trợ mode đó.

### Chạy headless command

Tạo key trên [trang Keys](https://superagent.reasonary.ai/keys), sau đó chạy trong thư mục project.
Cả UI và headless đều yêu cầu đăng nhập tài khoản RAI trước bằng `rai login`.
`REASONARY_AI_API_KEY` chỉ xác thực các request đến API model, không thay thế
đăng nhập RAI. Môi trường CI cần được thiết lập credential đăng nhập RAI hợp lệ.

```bash
# Đăng nhập tài khoản RAI trước (bắt buộc cho cả UI và headless)
rai login

# Bash / Zsh: chỉ truyền key cho lệnh này
REASONARY_AI_API_KEY='YOUR_API_KEY' rai run --model auker-1.0 \
  "Kiểm tra project, sửa các test đang fail và xác minh thay đổi."

# Chat Completions với vòng lặp agent chuẩn của RAI
REASONARY_AI_API_KEY='YOUR_API_KEY' rai run --model auker \
  "Kiểm tra project, sửa các test đang fail và xác minh thay đổi."

# Xuất JSONL dạng streaming để thu thập kết quả benchmark
REASONARY_AI_API_KEY='YOUR_API_KEY' rai run --model auker-1.0 \
  --output-format json "Giải thích kiến trúc của project này." > result.jsonl

# Hoặc export một lần để dùng cho nhiều lệnh
export REASONARY_AI_API_KEY='YOUR_API_KEY'
rai run --model auker-1.0 "Review project này mà không sửa file."
```

Nếu nhiều provider có cùng model ID, dùng `rai/auker-1.0` để chỉ rõ provider.
Cú pháp `KEY=value && rai run ...` không export biến mới cho tiến trình RAI; hãy dùng cách đặt biến ngay trước lệnh hoặc `export` như trên.
Biến cũ `REASONARY_API_KEY` thuộc chat proxy trước đây, không phải key cho Responses API.

```powershell
$env:REASONARY_AI_API_KEY = 'YOUR_API_KEY'
rai run --model auker-1.0 --output-format json "Giải thích project này."
```

Headless tự động phê duyệt quyền thực thi công cụ. Nếu dùng `RAI_CLIENT_SERVER=1`, cũng truyền key cho tiến trình **`rai serve`** vì tiến trình đó gửi request tới model.
Key không hợp lệ hoặc đã bị thu hồi sẽ bị API từ chối; đăng nhập tài khoản không thay thế API key.

### Theo dõi hoạt động streaming

Auker stream trạng thái sub-agent, hoạt động công cụ và nội dung trả lời. Mở rộng từng sub-agent để xem hoạt động được API báo về và kết quả công cụ local.
Thinking và thông tin model của từng worker chỉ hiển thị khi API cung cấp.

## Các provider và API key khác

Danh mục provider/model được cập nhật từ [models.dev](https://models.dev).
Mở **Alt+M** để xem danh sách có trong phiên bản đang cài. Bảng sau chỉ là ví dụ, **không phải toàn bộ provider được hỗ trợ**.

Chọn provider rồi dán API key trong giao diện hoặc đặt biến môi trường tương ứng:

| Provider | Biến môi trường |
|---|---|
| OpenAI | `OPENAI_API_KEY` |
| Anthropic | `ANTHROPIC_API_KEY` |
| Google Gemini | `GEMINI_API_KEY` |
| OpenRouter | `OPENROUTER_API_KEY` |

Endpoint ngoài danh mục có thể khai báo trong phần [provider tùy chỉnh](#custom-providers). RAI cũng hỗ trợ [model local](#local-models).
Tính năng có thể dùng phụ thuộc khả năng thực tế của model; có mặt trong danh mục không đồng nghĩa hỗ trợ mọi tính năng API.

## Agent Runner: chạy không tương tác

`rai run` phù hợp với CI/CD, script và super-agent gọi RAI như một công cụ.
Trong chế độ này, quyền thực thi được tự động phê duyệt và công cụ chỉ dành cho tương tác, như hỏi người dùng, bị tắt.

### Gửi yêu cầu và đọc stdin

```bash
rai run "Sửa các lỗi lint trong project này"
rai run "Giải thích đoạn code này" < code.go
rai run "Tạo tài liệu cho project" > project-guide.md
rai run --quiet "Tạo test cho các package"
rai run --verbose "Tìm nguyên nhân integration test đang fail"

git diff HEAD~1 | rai run --quiet "Review diff này để tìm lỗi và vấn đề bảo mật"
```

`--quiet` tắt spinner; `--verbose` hiển thị log nội bộ.

### Chọn model

`--model` nhận **model ID** hoặc `provider/model-id`, không phải tên hiển thị. Lấy ID từ danh mục model đã cấu hình.

```bash
rai run --model auker-1.0 "Review kiến trúc project này"

# Thay MODEL_ID và SMALL_MODEL_ID bằng ID thực tế
rai run --model "$MODEL_ID" --small-model "$SMALL_MODEL_ID" \
  "Refactor module này và kiểm tra lại"
```

`--small-model` chọn model nhỏ dùng cho các tác vụ phụ mà RAI định tuyến tới model đó.

### Điều chỉnh reasoning

```bash
rai run --reasoning high "Phân tích kiến trúc và các trade-off"
rai run --reasoning none "Trả lời câu hỏi đơn giản này"
rai run --reasoning on "Giải bài toán này từng bước"
```

RAI điều chỉnh mức effort về mức gần nhất mà model hỗ trợ. Ví dụ, yêu cầu `low` với model chỉ có `[high, max]` sẽ dùng `high` và báo lại trong kết quả.
Yêu cầu không tương thích, như bật thinking cho model chỉ nhận effort hoặc reasoning cho model không hỗ trợ, sẽ trả lỗi rõ ràng.
Trong giao diện, **Ctrl+E** chuyển mức effort hoặc bật/tắt thinking tùy model.

### Output JSONL dạng streaming

```bash
rai run --output-format json "Giải thích kiến trúc project" > result.jsonl
```

Mỗi dòng là một JSON object độc lập. Ví dụ minh họa cấu trúc sự kiện:

```jsonl
{"type":"thinking","text":"Đang phân tích code..."}
{"type":"text","text":"Cấu trúc project gồm..."}
{"type":"tool_use","id":"t1","name":"bash","input":{"command":"ls"}}
{"type":"tool_result","tool_use_id":"t1","tool_name":"bash","output":"...","is_error":false}
```

| Sự kiện | Ý nghĩa |
|---|---|
| `text` | Nội dung trả lời được gom từ các delta |
| `thinking` | Nội dung reasoning được model cung cấp |
| `tool_use` | Lời gọi công cụ với input JSON |
| `tool_result` | Kết quả thực thi công cụ |
| `error` | Lỗi |
| `result` | Sự kiện kết thúc, có ID phiên và kết quả tổng hợp |

`result` có `session_id`, `status`, `usage` (`input_tokens`, `output_tokens`), `cost_usd`, `model_id`, `provider_id`, `duration_ms` và `warning` khi có cảnh báo.
Chi phí là ước tính dựa trên giá trong danh mục. Chế độ text cũng hiển thị thống kê ở cuối output.
Các delta text/thinking được gom lại; từng lời gọi công cụ được giữ riêng.

### Ghi đè cấu hình và thêm instruction

`--settings` nhận JSON và có độ ưu tiên cao hơn cấu hình trong file:

```bash
rai run --settings '{"options":{"debug":true}}' "Debug test đang fail"

rai run --append-system-prompt \
  "Không sửa file *.env. Dùng conventional commits." \
  "Refactor phần authentication"
```

`--append-system-prompt` bổ sung instruction vào system prompt của model.

### Tiếp tục phiên làm việc

```bash
# Phiên mới
rai run "Bắt đầu refactor module authentication"

# Tiếp tục theo ID đã nhận
rai run --resume ses_abc123 "Tiếp tục refactor"

# Tiếp tục phiên gần nhất
rai run --continue "Tiếp tục công việc đang làm"
rai run -C "Kiểm tra lại kết quả vừa sửa"
```

`--resume` và `--continue` không dùng đồng thời. Headless in ID phiên ra **stderr** trước output của agent:

```text
# session: ses_abc123
```

Nội dung agent được stream ra **stdout**. Với JSONL, có thể lấy `session_id` từ sự kiện `result` để tiếp tục phiên sau.
Exit code **0** là agent hoàn thành; mã **lớn hơn 0** là lỗi, xem stderr để biết chi tiết.

### Quyền thực thi

Headless tự động phê duyệt mọi quyền. Trong giao diện tương tác, dùng **Ctrl+Y** để đổi chế độ quyền:

| Chế độ | Hành vi |
|---|---|
| `AcceptEdits` | Tự phê duyệt sửa/ghi file, hỏi với các hành động khác |
| `AcceptAll` | Tự phê duyệt mọi hành động |
| `Prompt` | Hỏi trước mỗi hành động |

Có thể cấu hình trong `rai.json`:

```json
{
  "options": {
    "permission_mode": "accept_edits"
  },
  "permissions": {
    "allowed_tools": ["view", "ls", "grep", "edit"]
  }
}
```

## Cấu hình

RAI có thể chạy mà không cần tạo file cấu hình. Khi cần tùy chỉnh, dùng JSON.
Thứ tự ưu tiên file, từ cao xuống thấp:

1. `.rai.json` trong project.
2. `rai.json` trong project.
3. `~/.rai/rai.json` cho cấu hình toàn cục.

Dữ liệu ứng dụng nằm tại `~/.local/share/rai/` trên Unix hoặc `%LOCALAPPDATA%\rai\` trên Windows.
Dùng `RAI_GLOBAL_CONFIG` và `RAI_GLOBAL_DATA` để đổi vị trí tương ứng.

### Instruction toàn cục

RAI tự đưa vào ngữ cảnh hai file dùng chung giữa các project:

- `~/.rai/RAI.md`: quy tắc riêng cho RAI.
- `~/.rai/AGENTS.md`: instruction dùng chung với các công cụ lập trình khác.

Tùy chỉnh đường dẫn:

```json
{
  "options": {
    "global_context_paths": ["~/path/to/instructions.md", "/path/to/context/"]
  }
}
```

### Bỏ qua file, tắt công cụ hoặc skill

RAI mặc định tôn trọng `.gitignore`. Tạo `.raiignore` với cùng cú pháp để bỏ qua thêm các file khi lấy ngữ cảnh.

```json
{
  "options": {
    "disabled_tools": ["bash", "sourcegraph"],
    "disabled_skills": ["rai-config"]
  }
}
```

## Tích hợp LSP

LSP cung cấp chẩn đoán lỗi, tham chiếu và gợi ý code:

```json
{
  "lsp": {
    "gopls": { "command": "gopls" },
    "rust-analyzer": { "command": "rust-analyzer" },
    "typescript": {
      "command": "typescript-language-server",
      "args": ["--stdio"]
    },
    "nix": { "command": "nil" }
  }
}
```

RAI tự tìm LSP theo dấu hiệu ở thư mục gốc project, ví dụ `go.mod` cho gopls và `Cargo.toml` cho rust-analyzer.

## MCP Servers

RAI hỗ trợ Model Context Protocol qua `stdio`, `http` và `sse`.
Các trường `command`, `args`, `env`, `headers`, `url` hỗ trợ mở rộng biến theo cú pháp shell: `$VAR`, `${VAR:-default}`, `$(command)`.

```json
{
  "mcp": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"],
      "timeout": 120
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "timeout": 120,
      "headers": { "Authorization": "Bearer $GH_PAT" },
      "disabled_tools": ["create_issue"]
    },
    "streaming": {
      "type": "sse",
      "url": "https://example.com/mcp/sse",
      "headers": { "API-Key": "$API_KEY" }
    }
  }
}
```

`rai.json` là cấu hình đáng tin cậy: `$(...)` được thực thi khi tải cấu hình với quyền của shell. Hãy kiểm tra cấu hình của thư mục trước khi chạy RAI trong đó.

## Hooks

Hooks chạy lệnh shell trước khi công cụ thực thi. Khai báo trong `rai.json`:

```json
{
  "hooks": {
    "write": [{ "command": "gofumpt -w {{.Path}}" }],
    "bash": [{ "command": "./scripts/guard.sh {{.Command}}", "timeout": "5s" }]
  }
}
```

## Agent Skills

RAI hỗ trợ chuẩn mở [Agent Skills](https://agentskills.io). Mỗi skill là một thư mục có file `SKILL.md`.

```bash
# Skills toàn cục
mkdir -p ~/.rai/skills

# Skills riêng cho project
mkdir -p .rai/skills
```

Các đường dẫn được phát hiện theo thứ tự ưu tiên sau:

| Phạm vi | Đường dẫn, từ ưu tiên cao đến thấp |
|---|---|
| Toàn cục | `~/.rai/skills/`, `~/.agents/skills/`, `~/.claude/skills/`, `~/.cursor/skills/`, `~/.codex/skills/` |
| Project | `.rai/skills/`, `.agents/skills/`, `.claude/skills/`, `.cursor/skills/`, `.codex/skills/` |

Thêm đường dẫn khác qua `options.skills_paths`.
Để skill xuất hiện trong command palette, thêm `user-invocable: true` vào YAML frontmatter của `SKILL.md`:

```yaml
---
name: review-pr
description: Review pull request để tìm các lỗi thường gặp
user-invocable: true
---
```

Có thể lấy các skill mẫu từ [anthropics/skills](https://github.com/anthropics/skills) và đặt từng thư mục skill vào một đường dẫn ở trên.

## Lệnh tùy chỉnh

Lệnh tùy chỉnh là các prompt dùng lại, được đọc từ `~/.rai/commands/` (toàn cục) và `.rai/commands/` (project).
Ví dụ, tạo một file Markdown trong thư mục này:

```markdown
# Review PR
Review diff để tìm bug, vấn đề bảo mật và code khó bảo trì.
Đề xuất thay đổi cụ thể và cách kiểm chứng.
```

Gọi lệnh từ command palette bằng **Ctrl+P**.

## Log

Log được lưu tại `.rai/logs/rai.log` trong project:

```bash
rai logs             # 1.000 dòng gần nhất
rai logs --tail 500   # 500 dòng gần nhất
rai logs --follow     # Theo dõi liên tục
```

Bật log debug trong cấu hình:

```json
{ "options": { "debug": true, "debug_lsp": true } }
```

<a id="custom-providers"></a>

## Provider tùy chỉnh

Khai báo endpoint và danh sách model trong `providers`. Ví dụ dưới đây dùng giá trị minh họa; thay URL, ID, giới hạn và giá bằng thông tin thực tế của provider.

### API tương thích OpenAI

```json
{
  "providers": {
    "custom-openai": {
      "type": "openai-compat",
      "base_url": "https://example.com/v1",
      "api_key": "$CUSTOM_API_KEY",
      "models": [{
        "id": "your-model-id",
        "name": "Your Model",
        "cost_per_1m_in": 1,
        "cost_per_1m_out": 3,
        "context_window": 64000,
        "default_max_tokens": 5000
      }]
    }
  }
}
```

### API tương thích Anthropic

```json
{
  "providers": {
    "custom-anthropic": {
      "type": "anthropic",
      "base_url": "https://example.com/v1",
      "api_key": "$CUSTOM_API_KEY",
      "models": [{
        "id": "your-model-id",
        "name": "Your Model",
        "context_window": 200000,
        "default_max_tokens": 50000,
        "can_reason": true,
        "supports_attachments": true
      }]
    }
  }
}
```

Chỉ khai báo capability như reasoning hoặc đính kèm ảnh nếu model thực sự hỗ trợ.

<a id="local-models"></a>

### Model local

RAI tự phát hiện model từ Ollama, llama.cpp, LM Studio, LiteLLM và OMLX.
Ví dụ cấu hình Ollama:

```json
{
  "providers": {
    "ollama": {
      "type": "ollama",
      "base_url": "http://localhost:11434/v1/"
    }
  }
}
```

## Cập nhật danh mục provider

Mặc định RAI cập nhật danh mục provider/model từ [models.dev](https://models.dev).
Tắt cập nhật tự động bằng cấu hình:

```json
{ "options": { "disable_provider_auto_update": true } }
```

Hoặc đặt biến môi trường và cập nhật thủ công:

```bash
export RAI_DISABLE_PROVIDER_AUTO_UPDATE=1
rai update-providers
rai update-providers /path/to/providers.json
```

File JSON tùy chỉnh phải theo định dạng tương thích models.dev.

## Metrics

RAI thu thập metrics sử dụng với mã băm thiết bị; không thu thập prompt hoặc nội dung trả lời.
Tắt bằng biến môi trường:

```bash
export RAI_DISABLE_METRICS=1
```

Hoặc dùng `{ "options": { "disable_metrics": true } }` trong cấu hình.
RAI cũng tôn trọng `DO_NOT_TRACK=1`.

## Tự hoàn thành lệnh shell

```bash
# Bash
source <(rai completion bash)

# Zsh
source <(rai completion zsh)

# Fish
rai completion fish | source
```

```powershell
rai completion powershell | Out-String | Invoke-Expression
```

## Ghi nhận RAI trong commit và PR

Mặc định RAI thêm thông tin ghi nhận vào commit Git và PR. Tùy chỉnh bằng:

```json
{
  "options": {
    "attribution": {
      "trailer_style": "co-authored-by",
      "generated_with": true
    }
  }
}
```

- `assisted-by`: thêm `Assisted-by: RAI:[ModelID]`.
- `co-authored-by`: thêm `Co-Authored-By: RAI <rai@reasonary.ai>`.
- `none`: không thêm trailer ghi nhận.
- `generated_with`: điều khiển dòng `Generated with RAI` trong commit/PR.

## Clipboard

| Hệ điều hành | Công cụ |
|---|---|
| Windows, macOS | Tích hợp sẵn |
| Linux + Wayland | `wl-copy`, `wl-paste` |
| Linux + X11 | `xclip` hoặc `xsel` |

## Giấy phép

[Giấy phép độc quyền](LICENSE.md). Bản quyền thuộc Reasonary AI Corp. Bảo lưu mọi quyền.

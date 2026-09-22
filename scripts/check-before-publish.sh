#!/usr/bin/env bash
#
# 发布前脱敏检查
#
# 用法：./scripts/check-before-publish.sh [目录]
#       不传参数则检查仓库根目录
#
# 用途：把 skill 复制进本仓库、或推送到公开仓库之前，先跑一遍这个脚本，
#       确认没有把密钥、内网地址、本地路径、垃圾文件一起带上去。
#
set -uo pipefail

TARGET="${1:-.}"
ISSUES=0

if [ ! -d "$TARGET" ]; then
  echo "目录不存在：$TARGET" >&2
  exit 1
fi

echo "=================================================="
echo " 发布前脱敏检查"
echo " 目标：$TARGET"
echo "=================================================="
echo

scan_text() {
  local title="$1"
  local pattern="$2"
  local result

  result=$(grep -rniE "$pattern" "$TARGET" \
    --include="*.md" --include="*.py" --include="*.yaml" --include="*.yml" \
    --include="*.json" --include="*.sh" --include="*.txt" --include="*.js" \
    --include="*.ts" --include="*.toml" --include="*.ini" --include="*.cfg" \
    --include="*.html" \
    --exclude-dir=".git" --exclude-dir="__pycache__" --exclude-dir="node_modules" \
    2>/dev/null)

  if [ -n "$result" ]; then
    echo "[命中] $title"
    printf '%s\n' "$result" | sed 's/^/       /'
    echo
    ISSUES=$((ISSUES + 1))
  else
    echo "[通过] $title"
  fi
}

echo "--- 文本敏感信息 ----------"
scan_text "API Key / Token / 密码" '(sk-|ak_)[a-zA-Z0-9_-]{16,}|(api[_-]?key|secret|token|password|passwd)[[:space:]]*[=:][[:space:]]*[^[:space:]]{8,}'
scan_text "内网 IP 地址" '10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|192\.168\.[0-9]{1,3}\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3}'
scan_text "内网域名" 'gitlab\.|intra\.|internal\.|corp\.|\.local'
scan_text "本地绝对路径" '/Users/[a-zA-Z0-9_.-]+/|/home/[a-zA-Z0-9_.-]+/|[A-Z]:\\'

echo
echo "--- 文件系统 --------------"

report_fs() {
  local title="$1"
  local output="$2"

  if [ -n "$output" ]; then
    echo "[命中] $title"
    printf '%s\n' "$output" | sed 's/^/       /'
    echo
    ISSUES=$((ISSUES + 1))
  else
    echo "[通过] $title"
  fi
}

report_fs "嵌套 git 仓库（会被识别成 submodule）" \
  "$(find "$TARGET" -mindepth 2 -name ".git" -type d 2>/dev/null)"

report_fs "缓存与系统垃圾文件" \
  "$(find "$TARGET" \( -name ".DS_Store" -o -name "__pycache__" -o -name "*.pyc" \) -not -path "*/.git/*" 2>/dev/null | head -20)"

report_fs "超过 5MB 的大文件（会让仓库臃肿）" \
  "$(find "$TARGET" -type f -size +5M -not -path "*/.git/*" 2>/dev/null)"

report_fs "市场/导入元数据文件（提示可能非原创）" \
  "$(find "$TARGET" -maxdepth 2 \( -name "_meta.json" -o -name "_skillhub_meta.json" -o -name "_user_meta.json" \) 2>/dev/null)"

echo
echo "=================================================="
if [ "$ISSUES" -eq 0 ]; then
  echo " 结果：未发现明显敏感信息"
  echo
  echo " 注意：自动扫描无法识别业务专有名词、真实人名、"
  echo "       公司产品名等，这些需要你人工再确认一遍。"
else
  echo " 结果：发现 $ISSUES 类问题，处理后再跑一次"
fi
echo "=================================================="

exit 0

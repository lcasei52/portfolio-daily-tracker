#!/bin/bash
# ═══════════════════════════════════════════════════
# 腾讯云部署脚本 — Portfolio Daily Tracker
# 目标: Ubuntu 22.04 + Docker 26
# ═══════════════════════════════════════════════════

set -e

echo "=========================================="
echo "  Portfolio Daily Tracker — 一键部署"
echo "=========================================="

# ── 1. 克隆项目 ──
echo ""
echo "[1/5] 克隆项目..."
if [ -d "portfolio-daily-tracker" ]; then
    echo "  目录已存在，跳过克隆"
else
    git clone https://github.com/Stepuuu/portfolio-daily-tracker.git
fi
cd portfolio-daily-tracker

# ── 2. 创建配置文件 ──
echo ""
echo "[2/5] 创建配置文件..."

# Engine config (如果不存在)
if [ ! -f "engine/portfolio/config.json" ]; then
    cp engine/portfolio/config.example.json engine/portfolio/config.json
    echo "  ⚠️  请编辑 engine/portfolio/config.json 填入："
    echo "     - groups（分组名、成本基础）"
    echo "     - telegram_bot_token / telegram_chat_id"
fi

# Dashboard config (如果不存在)
if [ ! -f "dashboard/config.json" ]; then
    cp dashboard/config.example.json dashboard/config.json
    echo "  ⚠️  请编辑 dashboard/config.json 填入："
    echo "     - api_groups.*.api_key（LLM API Key）"
fi

# 创建持仓文件 (如果不存在)
if [ ! -f "engine/portfolio/holdings/$(date +%Y-%m-%d).json" ]; then
    cp engine/portfolio/holdings/example.json "engine/portfolio/holdings/$(date +%Y-%m-%d).json"
    echo "  ⚠️  请编辑 engine/portfolio/holdings/$(date +%Y-%m-%d).json 填入实际持仓"
fi

# 创建必要目录
mkdir -p engine/portfolio/holdings engine/portfolio/snapshots
mkdir -p engine/reports engine/logs
mkdir -p dashboard/data/conversations dashboard/data/screenshots

# ── 3. 构建并启动容器 ──
echo ""
echo "[3/5] 构建并启动容器..."
docker compose up -d --build

echo ""
echo "  ✅ 服务已启动"
echo "     前端: http://$(hostname -I | awk '{print $1}'):3000"
echo "     API:  http://$(hostname -I | awk '{print $1}'):8000/docs"

# ── 4. 检查状态 ──
echo ""
echo "[4/5] 服务状态..."
docker compose ps

# ── 5. 提示 ──
echo ""
echo "[5/5] 下一步操作"
echo ""
echo "  📝 编辑持仓分组和成本:"
echo "     nano engine/portfolio/config.json"
echo ""
echo "  📝 编辑今日持仓:"
echo "     nano engine/portfolio/holdings/$(date +%Y-%m-%d).json"
echo ""
echo "  📝 编辑 LLM API Key:"
echo "     nano dashboard/config.json"
echo ""
echo "  🔄 修改配置后重启:"
echo "     docker compose restart backend"
echo ""
echo "  📋 手动运行一次快照（测试）:"
echo "     docker compose run --rm engine python3 scripts/portfolio_snapshot.py"
echo ""
echo "  📋 测试 Telegram 推送:"
echo "     docker compose run --rm engine python3 scripts/portfolio_daily_update.py --action notify"
echo ""
echo "  📋 查看调度器日志:"
echo "     docker compose logs -f scheduler"
echo ""
echo "=========================================="
echo "  部署完成！"
echo "=========================================="

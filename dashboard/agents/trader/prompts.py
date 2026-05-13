"""
交易员 Agent 提示词模板
"""

TRADER_AGENT_SYSTEM_PROMPT = """你是一个投资组合分析助手，职责是帮助用户管理持仓和分析市场。

## 核心规则
1. **禁止编造行情数据**。需要股价时必须调用 `get_stock_quote` 工具获取真实数据
2. **禁止编造新闻**。用户问市场涨跌原因时，必须调用 `get_market_news` 工具获取真实新闻
3. 如果工具调用失败，明确告知用户"当前无法获取数据"，不要猜测

## 能力范围
- 查看和分析用户持仓（调用 `get_portfolio` 或 `get_tracker_snapshot`）
- 获取个股行情（调用 `get_stock_quote`）
- 获取市场指数（调用 `get_market_indices`）
- 获取市场新闻（调用 `get_market_news`）
- 比较多只股票（调用 `compare_stocks`）
- 更新持仓（调用 `update_holdings`）
- 运行日报管道（调用 `run_portfolio_pipeline`）

## 回复要求
- 直接回答问题，不要寒暄，不要废话
- 不使用 emoji
- 不使用"A股黑话"或网络用语
- 数据驱动，有数据说数据，没数据说"我没有实时数据"
- 给建议时给出具体理由，不要泛泛而谈

## 当前上下文
{context}

{skills_section}
"""

import os
import glob
from pathlib import Path


def load_skills_context() -> str:
    """加载技能库内容"""
    skills_context = ""
    global_skills_dir = os.environ.get("CLAUDE_SKILLS_DIR", "")
    skills_paths = [
        global_skills_dir,
        os.path.join(os.getcwd(), ".agent", "skills"),
        os.path.join(os.getcwd(), "data", "skills")
    ]

    loaded_skills = []
    for base_dir in skills_paths:
        if not os.path.isdir(base_dir):
            continue

        for item in os.listdir(base_dir):
            item_path = os.path.join(base_dir, item)
            skill_content = ""
            skill_name = item

            try:
                if os.path.isfile(item_path):
                    with open(item_path, "r", encoding="utf-8") as f:
                        skill_content = f.read()
                elif os.path.isdir(item_path):
                    skill_md_path = os.path.join(item_path, "SKILL.md")
                    if os.path.exists(skill_md_path):
                        with open(skill_md_path, "r", encoding="utf-8") as f:
                            skill_content = f.read()
                    else:
                        md_files = glob.glob(os.path.join(item_path, "*.md"))
                        if md_files:
                            with open(md_files[0], "r", encoding="utf-8") as f:
                                skill_content = f.read()

                if skill_content.strip() and skill_name not in [s[0] for s in loaded_skills]:
                    loaded_skills.append((skill_name, skill_content.strip()))
            except Exception as e:
                print(f"[Skills] Failed to load skill {item_path}: {e}")

    if not loaded_skills:
        return ""

    skills_context = "\n## 可用技能\n"
    for name, content in loaded_skills:
        skills_context += f"<skill name=\"{name}\">\n{content}\n</skill>\n\n"

    return skills_context


def build_system_prompt(context: str = "") -> str:
    """构建 system prompt"""
    skills_section = load_skills_context()

    return TRADER_AGENT_SYSTEM_PROMPT.format(
        context=context or "（暂无持仓和市场数据）",
        skills_section=skills_section
    )


__all__ = ["TRADER_AGENT_SYSTEM_PROMPT", "build_system_prompt"]

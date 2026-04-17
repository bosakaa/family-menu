#!/bin/bash
# ────────────────────────────────────────────────
#  update-menu.sh — оновлення меню на GitHub Pages
#  Використання: ./update-menu.sh [шлях-до-файлу] ["Коментар до оновлення"]
#
#  Приклади:
#    ./update-menu.sh ~/Downloads/menu-7-dniv.html "Тиждень 3: більше риби"
#    ./update-menu.sh   (відкриє вибір файлу через діалог)
# ────────────────────────────────────────────────

set -e

# ── Кольори ──
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   🍽️  Оновлення меню на GitHub Pages    ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# ── Перевірка git ──
if ! command -v git &> /dev/null; then
  echo -e "${RED}❌ Git не знайдено. Встановіть git: https://git-scm.com${NC}"
  exit 1
fi

# ── Аргументи ──
SOURCE_FILE="$1"
COMMIT_MSG="$2"

# Якщо файл не вказано — шукаємо останній .html у Downloads
if [ -z "$SOURCE_FILE" ]; then
  DOWNLOADS_FILE=$(ls -t ~/Downloads/menu-*.html 2>/dev/null | head -1)
  if [ -n "$DOWNLOADS_FILE" ]; then
    echo -e "${YELLOW}🔍 Знайдено файл: $DOWNLOADS_FILE${NC}"
    read -p "   Використати цей файл? (Enter = так, або введіть шлях): " CUSTOM_PATH
    SOURCE_FILE="${CUSTOM_PATH:-$DOWNLOADS_FILE}"
  else
    read -p "📂 Вкажіть шлях до HTML файлу: " SOURCE_FILE
  fi
fi

# Перевірка файлу
if [ ! -f "$SOURCE_FILE" ]; then
  echo -e "${RED}❌ Файл не знайдено: $SOURCE_FILE${NC}"
  exit 1
fi

# Коментар до коміту
if [ -z "$COMMIT_MSG" ]; then
  WEEK_NUM=$(date +%V)
  YEAR=$(date +%Y)
  DATE_STR=$(date "+%d.%m.%Y")
  COMMIT_MSG="🍽️ Меню тиждень ${WEEK_NUM}/${YEAR} (${DATE_STR})"
  echo -e "${YELLOW}📝 Коментар: ${COMMIT_MSG}${NC}"
  read -p "   Змінити? (Enter = залишити, або введіть свій): " CUSTOM_MSG
  COMMIT_MSG="${CUSTOM_MSG:-$COMMIT_MSG}"
fi

# ── Копіюємо файл ──
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "\n${BLUE}📋 Копіюємо меню...${NC}"
cp "$SOURCE_FILE" "$SCRIPT_DIR/index.html"
echo -e "${GREEN}✅ index.html оновлено${NC}"

# ── Оновлюємо HISTORY.md ──
DATE_FULL=$(date "+%d.%m.%Y %H:%M")
echo "- **${DATE_FULL}** — ${COMMIT_MSG}" >> "$SCRIPT_DIR/HISTORY.md"
echo -e "${GREEN}✅ Історія оновлена${NC}"

# ── Git push ──
echo -e "\n${BLUE}🚀 Публікуємо на GitHub...${NC}"
cd "$SCRIPT_DIR"
git add index.html HISTORY.md
git commit -m "$COMMIT_MSG"
git push

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}   ✅ Готово! Меню опубліковано          ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Показуємо URL репо
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [[ "$REMOTE_URL" == *"github.com"* ]]; then
  # Перетворюємо git URL → Pages URL
  PAGES_URL=$(echo "$REMOTE_URL" \
    | sed 's/git@github.com:/https:\/\//' \
    | sed 's/https:\/\/github.com\///' \
    | sed 's/\.git$//')
  USER=$(echo "$PAGES_URL" | cut -d'/' -f1)
  REPO=$(echo "$PAGES_URL" | cut -d'/' -f2)
  echo -e "🌐 Сайт: ${BLUE}https://${USER}.github.io/${REPO}${NC}"
  echo -e "⏱️  Оновлення займе ~1-2 хвилини"
fi
echo ""

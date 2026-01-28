#!/usr/bin/env bash
# =========================================================
#  Cake — Modular System Monitor & Toolkit
# =========================================================

CONFIG_DIR="$HOME/.config/cake"
THEME_DIR="$(dirname "$0")/themes"
PLUGIN_DIR="$(dirname "$0")/plugins"
CONFIG_FILE="$HOME/config/cake.conf"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

mkdir -p "$CONFIG_DIR"

REFRESH_INTERVAL=1
THEME="dark"
RGB_MODE=0
ENABLE_PLUGINS=1

[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
[[ -f "$THEME_DIR/$THEME.conf" ]] && source "$THEME_DIR/$THEME.conf"

R="\033[0m"
DIM="\033[2m"
BOLD="\033[1m"

RGB_COLORS=(196 202 208 214 220 226 190 154 118 82 46)

BAR_WIDTH=26

### ---------- Utilities ----------
divider() {
  printf "%b%s%b\n" "$DIM" "────────────────────────────────────────────────────────────" "$R"
}

human() {
  awk -v b="$1" 'BEGIN{
    split("B KB MB GB TB",u);
    for(i=1;b>=1024&&i<5;i++) b/=1024;
    printf "%.1f %s", b, u[i];
  }'
}

draw_bar() {
  local pct=$1
  local fill=$(( pct * BAR_WIDTH / 100 ))

  for ((i=0;i<fill;i++)); do
    if [[ $RGB_MODE -eq 1 ]]; then
      c=${RGB_COLORS[$((i*${#RGB_COLORS[@]}/BAR_WIDTH))]}
      printf "\033[48;5;%sm \033[0m" "$c"
    else
      printf "\033[48;5;%sm \033[0m" "$BG_BAR_FILLED_BASE"
    fi
  done

  printf "\033[48;5;%sm%$((BAR_WIDTH-fill))s\033[0m" "$BG_BAR_EMPTY" ""
}

### ---------- Collectors ----------
cpu_total() {
  read cpu a b c idle rest < /proc/stat
  t1=$((a+b+c+idle+rest)); i1=$idle
  sleep 0.1
  read cpu a b c idle rest < /proc/stat
  t2=$((a+b+c+idle+rest)); i2=$idle
  echo $((100*((t2-t1)-(i2-i1))/(t2-t1)))
}

memory() {
  awk '/MemTotal|MemAvailable/{
    if($1=="MemTotal:") t=$2;
    if($1=="MemAvailable:") a=$2;
  } END{
    u=t-a;
    printf "%d %d %d\n", (u*100)/t, u*1024, t*1024
  }' /proc/meminfo
}

### ---------- UI ----------
header() {
  clear
  printf "%bCake%b  Host:%s  Time:%s\n" \
    "$FG_TITLE" "$R" "$(hostname)" "$(date +%H:%M:%S)"
  divider
}

row() {
  printf "%b%-10s%b %b%-18s%b " \
    "$FG_LABEL" "$1" "$R" "$FG_VALUE" "$2" "$R"
  draw_bar "$3"
  printf " %b%3d%%%b\n" "$DIM" "$3" "$R"
}

### ---------- Plugins ----------
load_plugins() {
  [[ $ENABLE_PLUGINS -eq 0 ]] && return
  for p in "$PLUGIN_DIR"/*.sh; do
    source "$p"
    plugin_draw 2>/dev/null
  done
}

### ---------- Apps ----------
network_scanner() {
  clear
  read -rp "Enter subnet (e.g. 192.168.1): " net
  echo "Scanning $net.0/24"
  for i in {1..254}; do
    ping -c1 -W1 "$net.$i" &>/dev/null && \
      printf " Host up: %s\n" "$net.$i"
  done
  read -rp "Press enter to return"
}

apps_menu() {
  clear
  echo "Cake — Apps"
  echo "1) Network Scanner"
  echo "2) Plugin Panels"
  echo "3) Back"
  read -rp "> " a
  case "$a" in
    1) network_scanner ;;
  esac
}

### ---------- Menu ----------
menu() {
  clear
  echo "Cake — Menu"
  echo "1) Resume"
  echo "2) Toggle RGB ($RGB_MODE)"
  echo "3) Change Theme ($THEME)"
  echo "4) Apps"
  echo "5) Save Config"
  echo "6) Exit"
  read -rp "> " c

  case "$c" in
    2) RGB_MODE=$((1-RGB_MODE)) ;;
    3) read -rp "Theme name: " THEME ;;
    4) apps_menu ;;
    5)
      cat > "$CONFIG_FILE" <<EOF
REFRESH_INTERVAL=$REFRESH_INTERVAL
THEME=$THEME
RGB_MODE=$RGB_MODE
ENABLE_PLUGINS=$ENABLE_PLUGINS
EOF
      ;;
    6) tput cnorm; exit 0 ;;
  esac
}

### ---------- Main ----------
trap 'tput cnorm; exit' INT
tput civis

while true; do
  header
  CPU=$(cpu_total)
  read MP MU MT <<<"$(memory)"

  row "CPU" "${CPU}%" "$CPU"
  row "Memory" "$(human $MU)/$(human $MT)" "$MP"

  divider
  load_plugins

  printf "%bPress [q] menu | [a] apps%b\n" "$DIM" "$R"

  read -rsn1 -t "$REFRESH_INTERVAL" k
  [[ $k == "q" ]] && menu
  [[ $k == "a" ]] && apps_menu
done

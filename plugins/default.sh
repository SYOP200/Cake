#!/usr/bin/env bash
# =========================================================
#  Cake Default Plugin — Core System Overview
#  Official Cake Panel
# =========================================================

plugin_name="Cake Core"

plugin_draw() {

  # ---- Local helpers (plugin-scoped) ----
  _cake_human() {
    awk -v b="$1" 'BEGIN{
      split("B KB MB GB TB",u);
      for(i=1;b>=1024&&i<5;i++) b/=1024;
      printf "%.1f %s", b, u[i];
    }'
  }

  _cake_divider() {
    printf "%b%s%b\n" "$DIM" "┌─────────────────── Cake Core ───────────────────┐" "$R"
  }

  # ---- Collect data ----
  HOST=$(hostname)
  KERNEL=$(uname -r)
  ARCH=$(uname -m)

  read UP_IDLE < /proc/uptime
  UPTIME=$(awk -v u="$UP_IDLE" 'BEGIN{
    d=int(u/86400); u%=86400;
    h=int(u/3600); u%=3600; m=int(u/60);
    printf "%dd %02dh %02dm", d,h,m
  }')

  LOAD=$(awk '{printf "%.2f %.2f %.2f", $1,$2,$3}' /proc/loadavg)

  read MP MU MT <<<"$(awk '
    /MemTotal|MemAvailable/{
      if($1=="MemTotal:") t=$2;
      if($1=="MemAvailable:") a=$2;
    } END{
      u=t-a;
      printf "%d %d %d\n", (u*100)/t, u*1024, t*1024
    }' /proc/meminfo)"

  PROCS_TOTAL=$(ps -e --no-headers | wc -l)
  PROCS_RUN=$(ps r --no-headers | wc -l)

  USER_COUNT=$(who | wc -l)

  # ---- Render ----
  _cake_divider
  printf "│ %b%-12s%b %b%s%b\n" \
    "$FG_LABEL" "Host" "$R" "$FG_VALUE" "$HOST" "$R"

  printf "│ %b%-12s%b %b%s%b\n" \
    "$FG_LABEL" "Kernel" "$R" "$FG_VALUE" "$KERNEL ($ARCH)" "$R"

  printf "│ %b%-12s%b %b%s%b\n" \
    "$FG_LABEL" "Uptime" "$R" "$FG_VALUE" "$UPTIME" "$R"

  printf "│ %b%-12s%b %b%s%b\n" \
    "$FG_LABEL" "Load Avg" "$R" "$FG_VALUE" "$LOAD" "$R"

  printf "│ %b%-12s%b %b%s / %s%b\n" \
    "$FG_LABEL" "Memory" "$R" "$FG_VALUE" \
    "$(_cake_human "$MU")" "$(_cake_human "$MT")" "$R"

  printf "│ %b%-12s%b %b%s%b\n" \
    "$FG_LABEL" "Processes" "$R" "$FG_VALUE" \
    "$PROCS_RUN running / $PROCS_TOTAL total" "$R"

  printf "│ %b%-12s%b %b%s%b\n" \
    "$FG_LABEL" "Users" "$R" "$FG_VALUE" \
    "$USER_COUNT logged in" "$R"

  printf "└─────────────────────────────────────────────────┘\n"
}

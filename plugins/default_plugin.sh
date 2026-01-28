#!/usr/bin/env bash
# =========================================================
#  Cake Core Plugin (Enhanced)
#  Official Default Plugin — Branded & Detailed
# =========================================================

plugin_name="Cake Core"
plugin_version="1.1.0"
plugin_author="Cake Project"
plugin_description="Branded core system overview panel"

plugin_draw() {

  # -------- Guards --------
  [[ ! -r /proc/uptime ]] && return

  # -------- Helpers --------
  _human() {
    awk -v b="$1" 'BEGIN{
      split("B KB MB GB TB",u);
      for(i=1;b>=1024&&i<5;i++) b/=1024;
      printf "%.1f %s", b, u[i];
    }'
  }

  _uptime() {
    awk '{u=$1;
      d=int(u/86400); u%=86400;
      h=int(u/3600); u%=3600;
      m=int(u/60);
      printf "%dd %02dh %02dm", d,h,m
    }' /proc/uptime
  }

  _box_top() {
    printf "%b┌──────────────────── Cake Core ────────────────────┐%b\n" "$DIM" "$R"
  }

  _box_bottom() {
    printf "%b└────────────────────────────────────────────────────┘%b\n" "$DIM" "$R"
  }

  _row() {
    printf "│ %b%-13s%b %b%-30s%b │\n" \
      "$FG_LABEL" "$1" "$R" "$FG_VALUE" "$2" "$R"
  }

  # -------- Data --------
  HOST=$(hostname)
  KERNEL=$(uname -r)
  ARCH=$(uname -m)

  LOAD=$(awk '{printf "%.2f %.2f %.2f", $1,$2,$3}' /proc/loadavg)
  UPTIME=$(_uptime)

  read MEM_P MEM_U MEM_T <<<"$(awk '
    /MemTotal|MemAvailable/{
      if($1=="MemTotal:") t=$2;
      if($1=="MemAvailable:") a=$2;
    } END{
      u=t-a;
      printf "%d %d %d\n", (u*100)/t, u*1024, t*1024
    }' /proc/meminfo)"

  read DISK_P DISK_U DISK_T <<<"$(df -P / | awk 'NR==2 {print $5+0,$3*1024,$2*1024}')"

  PROC_TOTAL=$(ps -e --no-headers | wc -l)
  PROC_RUN=$(ps r --no-headers | wc -l)

  USER_COUNT=$(who | wc -l)

  # -------- Render --------
  _box_top

  printf "│ %b      🎂  CAKE SYSTEM MONITOR  🎂             %b │\n" "$FG_TITLE" "$R"
  printf "│                                                    │\n"
  printf "│      ██████╗  █████╗ ██╗  ██╗███████╗              │\n"
  printf "│     ██╔════╝ ██╔══██╗██║ ██╔╝██╔════╝              │\n"
  printf "│     ██║      ███████║█████╔╝ █████╗                │\n"
  printf "│     ██║      ██╔══██║██╔═██╗ ██╔══╝                │\n"
  printf "│     ╚██████╗ ██║  ██║██║  ██╗███████╗              │\n"
  printf "│      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝              │\n"
  printf "│                                                    │\n"

  _row "Host" "$HOST"
  _row "Kernel" "$KERNEL ($ARCH)"
  _row "Uptime" "$UPTIME"
  _row "Load Avg" "$LOAD"
  _row "Memory" "$(_human "$MEM_U") / $(_human "$MEM_T")"
  _row "Disk /" "$(_human "$DISK_U") / $(_human "$DISK_T")"
  _row "Processes" "$PROC_RUN running / $PROC_TOTAL total"
  _row "Users" "$USER_COUNT logged in"

  printf "│                                                    │\n"
  printf "│ %bStatus%b        %bStable • Monitoring Active%b           │\n" \
    "$FG_LABEL" "$R" "$FG_VALUE" "$R"

  _box_bottom
}

#!/usr/bin/env bash

# ██    ██ ███    ██ ██ ██    ██ ███████ ██████  ███████  ██████  
# ██    ██ ████   ██ ██ ██    ██ ██      ██   ██ ██      ██    ██ 
# ██    ██ ██ ██  ██ ██ ██    ██ █████   ██████  ███████ ██    ██ 
# ██    ██ ██  ██ ██ ██  ██  ██  ██      ██   ██      ██ ██    ██ 
#  ██████  ██   ████ ██   ████   ███████ ██   ██ ███████  ██████  
#                                                                  
# ██   ██  █████   ██████ ██   ██ ██ ███    ██ ████████  ██████  ███████ ██   ██ 
# ██   ██ ██   ██ ██      ██  ██  ██ ████   ██    ██    ██    ██ ██      ██   ██ 
# ███████ ███████ ██      █████   ██ ██ ██  ██    ██    ██    ██ ███████ ███████ 
# ██   ██ ██   ██ ██      ██  ██  ██ ██  ██ ██    ██    ██    ██      ██ ██   ██ 
# ██   ██ ██   ██  ██████ ██   ██ ██ ██   ████    ██     ██████  ███████ ██   ██ 

# rp-core.sh - Universo Hackintosh
# - WiFi root patch (Sonoma/Sequoia/Tahoe): payloads/wifi/{14,15,26}
# - Audio root patch (Tahoe only): payloads/audio/26 + KDK merge + kmutil
# - Nice UI output with colors
# - Quiet by default for rsync/diskutil; show verbose output on screen with --verbose
# - Logs ONLY for mutating actions (--mode, --boot-snapshot, --rollback-stock). 
# - No logs for --help, no-args, --list-snapshots, --list-kdk.

# ==============================================================================
#
#  🇧🇷 PORTUGUÊS / BRASIL
# 
#  UNIVERSO HACKINTOSH — RP-CORE (rp-core.sh)
#
#  LICENÇA PROPRIETÁRIA RESTRITIVA — TODOS OS DIREITOS RESERVADOS
#
#  Copyright (c) 2026 Gabriel Luchina / Universo Hackintosh
#  Todos os direitos reservados.
#
#  AVISO IMPORTANTE:
#  Este software (incluindo, sem limitação, este script, seus módulos, rotinas,
#  lógica, estrutura, comentários, mensagens, nomes, e quaisquer arquivos
#  associados) é PROPRIETÁRIO, exceto Payloads do OpenCore Legacy Patcher.
#
#  1) PROIBIÇÕES (NENHUMA CÓPIA / DISTRIBUIÇÃO / DIVULGAÇÃO)
#  É EXPRESSAMENTE PROIBIDO, total ou parcialmente, sem autorização prévia e por
#  escrito do Licenciante:
#   - copiar, reproduzir, redistribuir, publicar, compartilhar, enviar, espelhar,
#     “re-upar”, disponibilizar para download, ou tornar acessível a terceiros;
#   - vender, revender, alugar, licenciar, sublicenciar, ceder, emprestar ou
#     explorar comercialmente (inclusive “como serviço”, consultoria, packs,
#     EFIs, repositórios, cursos, comunidades, drives, grupos, etc.);
#   - modificar, adaptar, traduzir, incorporar, criar obras derivadas, ou
#     mesclar este software com outros projetos;
#   - realizar engenharia reversa, descompilar, desmontar, tentar extrair lógica,
#     fluxos, métodos, chaves, segredos, ou contornar proteções;
#   - remover, alterar ou ocultar avisos de copyright, marcas, autoria, ou
#     quaisquer identificadores e marcações (visíveis ou ocultos);
#   - utilizar o conteúdo para treinar modelos de IA, mineração de código, ou
#     gerar material derivado para terceiros (inclusive por ferramentas de IA).
#
#  2) ISENÇÃO DE GARANTIAS / LIMITAÇÃO DE RESPONSABILIDADE
#  Este software é fornecido “NO ESTADO EM QUE SE ENCONTRA” (AS IS), sem
#  garantias de qualquer natureza. O usuário assume integralmente os riscos de
#  uso. Na máxima extensão permitida em lei, o Licenciante não será responsável
#  por danos diretos, indiretos, incidentais, especiais, punitivos ou
#  consequenciais.
#
#  AO UTILIZAR ESTE SOFTWARE, VOCÊ DECLARA QUE LEU, ENTENDEU E CONCORDA COM ESTES
#  TERMOS. SE VOCÊ NÃO CONCORDA, NÃO UTILIZE ESTE SOFTWARE.
# ==============================================================================

# ==============================================================================
#  UNIVERSO HACKINTOSH — RP-CORE (rp-core.sh)
#
#  🇺🇸 INGLÊS / GLOBAL
# 
#  RESTRICTIVE PROPRIETARY LICENSE — ALL RIGHTS RESERVED
#
#  Copyright (c) 2026 Gabriel Luchina / Universo Hackintosh
#  All rights reserved.
#
#  IMPORTANT NOTICE:
#  This software (including, without limitation, this script, its modules,
#  routines, logic, structure, comments, messages, names, and any associated
#  files) is PROPRIETARY, except payloads from OpenCore Legacy Patcher.
#
#  1) PROHIBITIONS (NO COPYING / DISTRIBUTION / DISCLOSURE)
#  It is EXPRESSLY PROHIBITED, in whole or in part, without Licensor’s prior
#  written authorization, to:
#   - copy, reproduce, redistribute, publish, share, transmit, mirror, re-upload,
#     make available for download, or otherwise provide access to any third party;
#   - sell, resell, rent, license, sublicense, assign, lend, or commercially
#     exploit (including “as-a-service”, consulting, packs, EFIs, repositories,
#     courses, communities, drives, groups, etc.);
#   - modify, adapt, translate, incorporate, create derivative works from, or
#     merge this software with other projects;
#   - reverse engineer, decompile, disassemble, attempt to extract logic, flows,
#     methods, keys, secrets, or bypass protections;
#   - remove, alter, or conceal copyright notices, trademarks, authorship, or any
#     identifiers and markings (visible or hidden);
#   - use the content to train AI models, perform code mining, or generate
#     derivative material for third parties (including via AI tools).
#
#  2) DISCLAIMER OF WARRANTIES / LIMITATION OF LIABILITY
#  This software is provided “AS IS”, without warranties of any kind. User
#  assumes all risks arising from use. To the maximum extent permitted by law,
#  Licensor shall not be liable for any direct, indirect, incidental, special,
#  punitive, or consequential damages.
#
#  BY USING THIS SOFTWARE, YOU ACKNOWLEDGE THAT YOU HAVE READ, UNDERSTOOD, AND
#  AGREE TO THESE TERMS. IF YOU DO NOT AGREE, DO NOT USE THIS SOFTWARE.
# ==============================================================================

set -Eeuo pipefail

RPVERSION=1.0.2

# -------- Terminal resize (UI) --------
# Resize the Terminal window (rows x cols) for a consistent UI experience.
# Uses xterm window manipulation escape sequence: ESC[8;{rows};{cols}t
resize_terminal() {
  [[ -t 1 ]] || return 0
  # rows=30, cols=125
  printf '\033[8;32;130t' 2>/dev/null || true
}

resize_terminal
clear

MNT="/System/Volumes/Update/mnt1"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Require sudo ALWAYS (any execution)
if [[ "${EUID}" -ne 0 ]]; then
  echo "[!] This script must be run with sudo."
  echo "    Use: sudo ${ROOT_DIR}/rp-core.sh <options>"
  exit 1
fi

DRY_RUN=false
VERBOSE=false

# Log config (lazy init)
TS="$(/bin/date +%Y%m%d%H%M%S)"
LOG_DIR="${ROOT_DIR}/logs"
LOG_FILE="${LOG_DIR}/logexec-${TS}.log"
LOG_ENABLED=false

init_log_if_needed() {
  if $LOG_ENABLED && [[ ! -f "$LOG_FILE" ]]; then
    mkdir -p "$LOG_DIR"
    : > "$LOG_FILE"
    {
      echo "============================================================"
      echo "rp-core.sh execution log"
      echo "Timestamp: ${TS}"
      echo "Script dir: ${ROOT_DIR}"
      echo "Log file  : ${LOG_FILE}"
      echo "Verbose   : ${VERBOSE}"
      echo "Dry-run   : ${DRY_RUN}"
      echo "============================================================"
    } >>"$LOG_FILE"
  fi
}

# -------- Pretty UI (colors) --------
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_DIM=$'\033[2m'
  C_BOLD=$'\033[1m'
  C_RED=$'\033[31m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'
  C_MAGENTA=$'\033[35m'
  C_CYAN=$'\033[36m'
else
  C_RESET=""; C_DIM=""; C_BOLD=""; C_RED=""; C_GREEN=""; C_YELLOW=""
  C_BLUE=""; C_MAGENTA=""; C_CYAN=""
fi

_screen() { echo -e "$*"; }
_log() {
  if $LOG_ENABLED; then
    init_log_if_needed
    echo "$*" >>"$LOG_FILE"
  fi
}

info() { _screen "${C_CYAN}${C_BOLD}[INFO]${C_RESET} $*"; _log "[INFO] $*"; }
ok()   { _screen "${C_GREEN}${C_BOLD}[ OK ]${C_RESET} $*"; _log "[ OK ] $*"; }
warn() { _screen "${C_YELLOW}${C_BOLD}[WARN]${C_RESET} $*"; _log "[WARN] $*"; }
step() { _screen "${C_BLUE}${C_BOLD}==>${C_RESET} $*"; _log "==> $*"; }
dry()  { _screen "${C_MAGENTA}${C_BOLD}[DRY]${C_RESET} $*"; _log "[DRY] $*"; }
fail() { _screen "${C_RED}${C_BOLD}[ERR ]${C_RESET} $*"; _log "[ERR ] $*"; exit 1; }

# ---------- Global error handler (friendly) ----------
LAST_CMD=""
LAST_RC=0

on_err() {
  LAST_RC=$?
  LAST_CMD="${BASH_COMMAND:-"(unknown)"}"

  _screen "${C_RED}${C_BOLD}[ERR ]${C_RESET} The script was interrupted because a command failed."
  
  if $LOG_ENABLED; then
    init_log_if_needed
    _log "[ERR ] Script interrupted due to a command failure."
    _screen "${C_YELLOW}${C_BOLD}[INFO]${C_RESET} See details in the log: ${C_DIM}${LOG_FILE}${C_RESET}"
  else
    _screen "${C_YELLOW}${C_BOLD}[INFO]${C_RESET} (No log: this run was in read-only mode (no changes were made).)"
  fi

  exit "$LAST_RC"
}

trap on_err ERR

# -------- Banner/Header --------
banner() {
  _screen "${C_BOLD}${C_MAGENTA}=================================================================================================================================${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}  Universo Hackintosh - RP CORE (WiFi/Audio)${C_RESET}"
  _screen "${C_DIM}  Script   : ${ROOT_DIR}/rp-core.sh${C_RESET}"
  if $LOG_ENABLED; then
    _screen "${C_DIM}  Log      : ${LOG_FILE}${C_RESET}"
  else
    _screen "${C_DIM}  Log      : (disabled - read-only mode)${C_RESET}"
  fi
  _screen "${C_DIM}  Version  : ${RPVERSION}${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}=================================================================================================================================${C_RESET}"
}

# -------- Splash (branding) --------
show_splash() {
  # Disable splash (power users / automation)
  [[ "${NO_SPLASH:-0}" == "1" ]] && return 0

  # Show only once per session/run
  [[ "${_SPLASH_SHOWN:-0}" == "1" ]] && return 0
  _SPLASH_SHOWN=1

  # Only when stdout is a TTY (avoid piping)
  [[ -t 1 ]] || return 0

  clear 2>/dev/null || true

  _screen "${C_BOLD}${C_MAGENTA}=================================================================================================================================${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}  Universo Hackintosh - RP CORE (WiFi/Audio)${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}=================================================================================================================================${C_RESET}"
  _screen ""
  _screen "${C_BOLD}${C_MAGENTA}██    ██ ███    ██ ██ ██    ██ ███████ ██████  ███████  ██████  ${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}██    ██ ████   ██ ██ ██    ██ ██      ██   ██ ██      ██    ██ ${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}██    ██ ██ ██  ██ ██ ██    ██ █████   ██████  ███████ ██    ██ ${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}██    ██ ██  ██ ██ ██  ██  ██  ██      ██   ██      ██ ██    ██ ${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA} ██████  ██   ████ ██   ████   ███████ ██   ██ ███████  ██████  ${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}                                                                  ${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}██   ██  █████   ██████ ██   ██ ██ ███    ██ ████████  ██████  ███████ ██   ██ ${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}██   ██ ██   ██ ██      ██  ██  ██ ████   ██    ██    ██    ██ ██      ██   ██ ${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}███████ ███████ ██      █████   ██ ██ ██  ██    ██    ██    ██ ███████ ███████ ${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}██   ██ ██   ██ ██      ██  ██  ██ ██  ██ ██    ██    ██    ██      ██ ██   ██ ${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}██   ██ ██   ██  ██████ ██   ██ ██ ██   ████    ██     ██████  ███████ ██   ██ ${C_RESET}"
  _screen ""
  _screen "${C_BOLD}Autor   :${C_RESET} Gabriel Luchina"
  _screen "${C_BOLD}YouTube :${C_RESET} https://hackintosh.one/s/yt"
  _screen "${C_BOLD}Curso   :${C_RESET} https://www.hackintoshprofissional.com.br"
  _screen "${C_BOLD}RP CORE :${C_RESET} https://github.com/luchina-gabriel/RP-CORE"
  _screen ""
  _screen "${C_DIM}Credits: The network/audio patches/binaries used here originate from the OpenCore Legacy Patcher (OCLP) project.${C_RESET}"
  _screen "${C_DIM}Thanks to the OCLP team and all contributors for their tremendous work in the community.${C_RESET}"
  _screen ""
  _screen "${C_DIM}Se isso te ajudou, apoiar o canal/curso mantém o projeto vivo. ❤️${C_RESET}"
  _screen ""
  _screen "${C_YELLOW}${C_BOLD}Warning #1: ${C_RESET} No copying and/or redistribution, in whole or in part, of the contents of this script/package is permitted."
  _screen "${C_YELLOW}${C_BOLD}Warning #2: ${C_RESET} Does not come with any warranty, use at your own risk."
  _screen "${C_BOLD}${C_MAGENTA}=================================================================================================================================${C_RESET}"
  echo

  read -r -p "Press ENTER to continue..." _ || true
  echo
}
have_cmd() { command -v "$1" >/dev/null 2>&1; }


# ---------- SIP guard (mutating actions require SIP disabled) ----------
# Exit codes used only when called from the interactive menu wrapper.
SIP_GUARD_RC_MENU_RETURN=112
SIP_GUARD_RC_QUIT=113

sip_is_enabled() {
  /usr/bin/csrutil status 2>&1 | /usr/bin/grep -q "System Integrity Protection status: enabled"
}

sip_prompt_return_or_quit() {
  local ans=""
  echo
  read -r -p "Press ENTER to return to the main menu, or Q to quit: " ans || true
  ans="${ans:-}"
  if [[ "$ans" == "Q" || "$ans" == "q" ]]; then
    ok "Bye!"
    exit "${SIP_GUARD_RC_QUIT}"
  fi

  # If this execution was started from the interactive menu, return a special code so
  # the parent can immediately resume the menu without printing extra prompts.
  if [[ "${RP_CORE_PARENT_MENU:-0}" == "1" ]]; then
    exit "${SIP_GUARD_RC_MENU_RETURN}"
  fi

  # Non-interactive CLI: there is no menu to return to.
  exit 1
}

sip_abort_mutation_due_to_sip() {
  local action="${1:-"(unknown action)"}"
  local csr_out=""
  csr_out="$(/usr/bin/csrutil status 2>&1 || true)"

  # Force log creation (mutating actions are expected to have logs).
  LOG_ENABLED=true
  init_log_if_needed

  _log "[ERR ] SIP guard: System Integrity Protection is ENABLED."
  _log "[INFO] Aborting: ${action}"
  _log "[INFO] csrutil status:"
  while IFS= read -r line; do
    _log "       ${line}"
  done <<< "${csr_out}"

  _screen "${C_RED}${C_BOLD}[ERR ]${C_RESET} System Integrity Protection (SIP) is ENABLED. Aborting..."
  echo
  _screen "${C_YELLOW}${C_BOLD}[INFO]${C_RESET} A log has been created: ${C_DIM}${LOG_FILE}${C_RESET}"
  
  sip_prompt_return_or_quit
}




# ---------- FileVault guard (mutating actions require FileVault OFF) ----------
# Exit codes used only when called from the interactive menu wrapper.
FILEVAULT_GUARD_RC_MENU_RETURN=114
FILEVAULT_GUARD_RC_QUIT=115

filevault_is_off() {
  /usr/bin/fdesetup status 2>&1 | /usr/bin/grep -q "FileVault is Off\."
}

filevault_prompt_return_or_quit() {
  local ans=""
  echo
  read -r -p "Press ENTER to return to the main menu, or Q to quit (FileVault guard): " ans || true
  ans="${ans:-}"
  if [[ "$ans" == "Q" || "$ans" == "q" ]]; then
    ok "Bye!"
    exit "${FILEVAULT_GUARD_RC_QUIT}"
  fi

  # If this execution was started from the interactive menu, return a special code so
  # the parent can immediately resume the menu without printing extra prompts.
  if [[ "${RP_CORE_PARENT_MENU:-0}" == "1" ]]; then
    exit "${FILEVAULT_GUARD_RC_MENU_RETURN}"
  fi

  # Non-interactive CLI: there is no menu to return to.
  exit 1
}

filevault_abort_mutation_due_to_filevault() {
  local action="${1:-"(unknown action)"}"
  local fv_out=""
  fv_out="$(/usr/bin/fdesetup status 2>&1 || true)"

  # Force log creation (mutating actions are expected to have logs).
  LOG_ENABLED=true
  init_log_if_needed

  _log "[ERR ] FileVault guard: FileVault is NOT OFF."
  _log "[INFO] Aborting: ${action}"
  _log "[INFO] fdesetup status:"
  while IFS= read -r line; do
    _log "       ${line}"
  done <<< "${fv_out}"

  _screen "${C_RED}${C_BOLD}[ERR ]${C_RESET} FileVault is ENABLED (or status is not 'Off'). Aborting..."
  echo
  _screen "${C_YELLOW}${C_BOLD}[INFO]${C_RESET} A log has been created: ${C_DIM}${LOG_FILE}${C_RESET}"

  filevault_prompt_return_or_quit
}

# ---------- Hash helpers (global) ----------
sha256_file() { /usr/bin/shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'; }

# Compare payload file vs SSV file (by absolute system path). Returns 0 if match.
cmp_payload_vs_ssv() {
  local payload_file="$1" ssv_path="$2"
  [[ -e "$ssv_path" ]] || return 1
  local ph sh
  ph="$(sha256_file "$payload_file")"
  sh="$(sha256_file "$ssv_path")"
  [[ -n "$ph" && "$ph" == "$sh" ]]
}

# Check an item (file/dir) using internal markers to avoid merge false positives.
# Returns 0 only if ALL comparable markers match payload.
check_item_markers_quiet() {
  local payload_root="$1" item="$2"      # item starts with /
  local src="${payload_root}${item}"

  # file
  if [[ -f "$src" || -L "$src" ]]; then
    cmp_payload_vs_ssv "$src" "$item"
    return $?
  fi

  # directory: compare markers
  if [[ -d "$src" ]]; then
    # Store only the marker DIRECTORY (no trailing glob) so it can be quoted.
    # The '/*' glob is expanded on the quoted dir below, which keeps paths with
    # spaces intact (an unquoted glob string would be word-split by IFS).
    local marker_dir=""
    if [[ "$item" == *.framework ]]; then
      marker_dir="${src}/Versions/A"
    elif [[ "$item" == *.kext ]]; then
      marker_dir="${src}/Contents/MacOS"
    elif [[ "$item" == *.app ]]; then
      marker_dir="${src}/Contents/MacOS"
    fi

    local found=0
    local mf rel
    if [[ -n "$marker_dir" ]]; then
      for mf in "$marker_dir"/*; do
        [[ -e "$mf" ]] || continue
        [[ -d "$mf" ]] && continue
        found=1
        rel="${mf#${payload_root}}"
        cmp_payload_vs_ssv "$mf" "$rel" || return 1
      done
    fi

    # If it is an .app and no executable markers were found, compare Info.plist as a fallback
    if [[ "$found" -eq 0 && "$item" == *.app ]]; then
      if [[ -f "${src}/Contents/Info.plist" ]]; then
        cmp_payload_vs_ssv "${src}/Contents/Info.plist" "${item}/Contents/Info.plist" && found=1
      fi
    fi

    # No markers found => inconclusive => treat as NOT applied
    [[ "$found" -eq 1 ]]
    return $?
  fi

  return 1
}

wifi_already_applied() {
  local major="$1"
  local pr="${ROOT_DIR}/payloads/wifi/${major}"
  [[ -d "$pr" ]] || return 1

  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    [[ -e "${pr}${item}" ]] || return 1
    check_item_markers_quiet "$pr" "$item" || return 1
  done < <(wifi_items_for_major "$major")

  return 0
}

audio_already_applied() {
  local major="$1"
  local pr="${ROOT_DIR}/payloads/audio/${major}"
  [[ -d "$pr" ]] || return 1

  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    [[ -e "${pr}${item}" ]] || return 1
    check_item_markers_quiet "$pr" "$item" || return 1
  done < <(audio_items_for_major "$major")

  return 0
}

# Runners:
run_show() {
  local cmd="$*"
  if $DRY_RUN; then
    dry "$cmd"; _log "[CMD] $cmd"; return 0
  fi
  _log "[CMD] $cmd"
  if $LOG_ENABLED; then
    init_log_if_needed
    bash -c "$cmd" 2>&1 | tee -a "$LOG_FILE"
  else
    bash -c "$cmd" 2>&1
  fi
}

run_quiet() {
  local cmd="$*"
  if $DRY_RUN; then
    dry "$cmd"; _log "[CMD] $cmd"; return 0
  fi
  _log "[CMD] $cmd"
  if $LOG_ENABLED; then
    init_log_if_needed
    bash -c "$cmd" >>"$LOG_FILE" 2>&1
  else
    bash -c "$cmd" >/dev/null 2>&1
  fi
}

run() { if $VERBOSE; then run_show "$@"; else run_quiet "$@"; fi; }

usage() {
  banner
  cat <<'EOF'

Usage:
  sudo ./rp-core.sh --status                       (validate WiFi/Audio in the current SSV)
  sudo ./rp-core.sh --mode wifi                    (macOS Tahoe, Sequoia or Sonoma)
  sudo ./rp-core.sh --mode audio --kdk-auto        (macOS Tahoe Only)
  sudo ./rp-core.sh --mode both  --kdk-auto        (macOS Tahoe Only)

Snapshots:
  sudo ./rp-core.sh --list-snapshots               (list snapshots from /)
  sudo ./rp-core.sh --boot-snapshot <UUID>         (Change BOOT)
  sudo ./rp-core.sh --rollback-stock               (Change BOOT)

Miscellaneous:
  sudo ./rp-core.sh --list-kdk                     (list installed KDKs)
  sudo ./rp-core.sh --check-efi [config.plist]     (validate OpenCore EFI config requirements)

Options:
  --mode wifi|audio|both
  --kdk <path_to_.kdk>        (only audio/both on macOS Tahoe)
  --kdk-auto                  (only audio/both on macOS Tahoe) Choose the latest KDK from /Library/Developer/KDKs
  --no-kdk-merge              (only audio/both on macOS Tahoe) Doesn't MERGE of the KDK on mnt1 (less robust)
  --verbose                   shows detailed output (rsync/diskutil/kmutil) on the screen
  --dry-run                   It doesn't change anything, it just shows the commands
  --interactive               Open an interactive menu (for .command / double-click)
  --check-efi [config.plist]  Validate OpenCore config requirements
  --oc-config <config.plist>  Path to OpenCore config.plist (used by --check-efi)
  --list-kdk                  List installed KDKs
  -h, --help

Logs:
  Generated ONLY for actions that alter the environment: --mode, --boot-snapshot, --rollback-stock
  Path: ./logs/logexec-AAAAMMDDHHMMSS.log

EOF
}

check_tools() {
  for c in rsync kmutil bless diskutil mount umount cp chmod chown awk grep sw_vers date bash tee uname csrutil fdesetup tr sed head wc ls find xargs stat sort cut shasum; do
    have_cmd "$c" || fail "Required command not found: $c"
  done
}

# ---- Hard-coded WiFi items per macOS major (aligned with payload structure) ----
wifi_items_for_major() {
  local major="$1"
  case "$major" in
    14) cat <<'EOF'
/System/Library/Frameworks/CoreWLAN.framework
/System/Library/PrivateFrameworks/CoreWiFi.framework
/System/Library/PrivateFrameworks/IO80211.framework
/System/Library/PrivateFrameworks/WiFiPeerToPeer.framework
/usr/libexec/airportd
/usr/libexec/wifip2pd
EOF
      ;;
    15) cat <<'EOF'
/System/Library/Frameworks/CoreWLAN.framework
/System/Library/PrivateFrameworks/CoreWiFi.framework
/System/Library/PrivateFrameworks/IO80211.framework
/System/Library/PrivateFrameworks/WiFiPeerToPeer.framework
/System/Library/CoreServices/WiFiAgent.app
/usr/libexec/airportd
/usr/libexec/wifip2pd
EOF
      ;;
    26) cat <<'EOF'
/System/Library/PrivateFrameworks/IO80211.framework
/System/Library/PrivateFrameworks/WiFiPeerToPeer.framework
/usr/libexec/wifip2pd
EOF
      ;;
    *) return 1 ;;
  esac
}

audio_items_for_major() {
  local major="$1"
  case "$major" in
    26) cat <<'EOF'
/System/Library/Extensions/AppleHDA.kext
EOF
      ;;
    *) return 1 ;;
  esac
}

# Copy a single payload item (file or directory) into mnt1 preserving full path.
# rel must be an absolute path starting with / (eg: /System/Library/PrivateFrameworks/IO80211.framework)
copy_payload_item() {
  local payload_root="$1"
  local rel="$2"
  local src="${payload_root}${rel}"
  local dst="${MNT}${rel}"
  local dst_parent
  dst_parent="$(dirname "$dst")"

  [[ -e "$src" ]] || fail "Item not found in payload: ${src}"
  run "mkdir -p '$dst_parent'"

  if [[ -d "$src" ]]; then
    # Copy directory preserving name into its parent
    if $VERBOSE; then
      run_show "/usr/bin/rsync -r -i -a '$src' '$dst_parent/'"
    else
      run_quiet "/usr/bin/rsync -r -i -a '$src' '$dst_parent/'"
    fi
    fix_perms_tree "$dst"
  else
    run "/bin/cp -a '$src' '$dst'"
    fix_perms_file "$dst"
  fi
}


get_os_version() { /usr/bin/sw_vers -productVersion; }
get_build_version(){ /usr/bin/sw_vers -buildVersion; }
get_major() { echo "${1%%.*}"; }

get_root_device() {
  local dev
  dev="$(/usr/sbin/diskutil info / | awk -F': *' '/Device Node/ {print $2}' | tr -d ' ')"
  [[ -n "$dev" ]] || fail "Unable to detect the device node for /"
  echo "$dev"
}

strip_snapshot_suffix() {
  local dev="$1"
  if [[ "$dev" =~ ^/dev/(disk[0-9]+s[0-9]+)s1$ ]]; then
    echo "/dev/${BASH_REMATCH[1]}"
  else
    echo "$dev"
  fi
}

mount_mnt1_rw() {
  local sysdev="$1"
  run "mkdir -p '$MNT'"

  if mount | grep -q " on ${MNT} "; then
    ok "mnt1 is already mounted: ${MNT}"
    return 0
  fi

  step "Mounting the System volume (R/W) at ${MNT}"
  run "/sbin/mount -t apfs -o nobrowse '$sysdev' '$MNT'"
}

fix_perms_file() { local p="$1"; run "/usr/sbin/chown root:wheel '$p'"; run "/bin/chmod 755 '$p'"; }
fix_perms_tree() { local p="$1"; run "/usr/sbin/chown -R root:wheel '$p'"; run "/bin/chmod -R 755 '$p'"; }

check_wifi_payload() {
  local p="$1"
  local major="$2"
  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    [[ -e "${p}${item}" ]] || fail "WiFi payload missing: ${p}${item}"
  done < <(wifi_items_for_major "$major")
}

check_audio_payload_tahoe() {
  local p="$1"
  local major="$2"
  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    [[ -e "${p}${item}" ]] || fail "Audio payload missing: ${p}${item}"
  done < <(audio_items_for_major "$major")
}

copy_wifi_payload() {
  local p="$1"
  local major="$2"
  step "Applying Wi-Fi payload: $p"

  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    info "Applying: ${item}"
    copy_payload_item "$p" "$item"
  done < <(wifi_items_for_major "$major")

  ok "Wi-Fi payload applied"
}

copy_audio_payload_tahoe() {
  local p="$1"
  local major="$2"
  step "Applying Audio (Tahoe) payload: $p"

  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    info "Applying: ${item}"
    copy_payload_item "$p" "$item"
  done < <(audio_items_for_major "$major")

  ok "Audio payload applied"
}

# ---- KDK (robust) ----
kdk_preflight_or_die() {
  local base="/Library/Developer/KDKs"
  [[ -d "$base" ]] || fail "KDK not found: directory missing '${base}'."

  local any="" p
  while IFS= read -r -d '' p; do
    if [[ -d "$p/System/Library/Extensions" ]]; then
      any="$p"
      break
    fi
  done < <(/usr/bin/find "$base" -maxdepth 1 -type d -name "*.kdk" -print0 2>/dev/null)

  [[ -n "$any" ]] || fail "KDK not found: no valid '*.kdk' directory in '${base}' (must contain System/Library/Extensions)."
}

kdk_version_from_basename() {
  local bn="$1"
  local ver=""

  if [[ "$bn" =~ ^KDK_([0-9]+(\.[0-9]+)*)_.+\.kdk$ ]]; then
    ver="${BASH_REMATCH[1]}"
  fi

  echo "$ver"
}

kdk_version_key() {
  local ver="$1"
  local key=""
  local part=""
  local count=0
  local IFS='.'

  [[ -n "$ver" ]] || return 1

  for part in $ver; do
    [[ "$part" =~ ^[0-9]+$ ]] || return 1
    key+="$(printf '%06d' "$part")"
    count=$((count + 1))
  done

  # Normalize key length so 26.3 < 26.3.1 < 26.3.1.1, etc.
  while (( count < 6 )); do
    key+="000000"
    count=$((count + 1))
  done

  echo "$key"
}

kdk_pick_auto() {
  local base="/Library/Developer/KDKs"
  [[ -d "$base" ]] || fail "KDKs folder does not exist: $base"

  local picked="" best_key="" best_m=0 m p bn ver key

  # Prefer the NEWEST KDK by full dotted version in the folder name
  # (e.g. 26.3 < 26.3.1 < 26.3.1.1).
  # If multiple have the same version, pick the newest by mtime.
  # If the version cannot be parsed, fall back to mtime.
  while IFS= read -r -d '' p; do
    [[ -d "$p/System/Library/Extensions" ]] || continue

    bn="$(/usr/bin/basename "$p" 2>/dev/null || echo "")"
    ver="$(kdk_version_from_basename "$bn")"
    key="$(kdk_version_key "$ver" 2>/dev/null || true)"
    m="$(/usr/bin/stat -f "%m" "$p" 2>/dev/null || true)"
    [[ "$m" =~ ^[0-9]+$ ]] || m=0

    if [[ -n "$key" ]]; then
      if [[ -z "$best_key" || "$key" > "$best_key" ]]; then
        best_key="$key"
        best_m="$m"
        picked="$p"
      elif [[ "$key" == "$best_key" ]] && (( m > best_m )); then
        best_m="$m"
        picked="$p"
      fi
    elif [[ -z "$picked" || ( -z "$best_key" && m -gt best_m ) ]]; then
      best_m="$m"
      picked="$p"
    fi
  done < <(/usr/bin/find "$base" -maxdepth 1 -type d -name "*.kdk" -print0 2>/dev/null)

  [[ -n "$picked" ]] || fail "No valid '*.kdk' directory found in $base."
  [[ -d "$picked/System/Library/Extensions" ]] || fail "Invalid KDK (missing System/Library/Extensions): $picked"

  echo "$picked"
}

kdk_list_sorted() {
  local base="${1:-/Library/Developer/KDKs}"
  [[ -d "$base" ]] || return 0

  local p="" bn="" ver="" key="" m=0
  while IFS= read -r -d '' p; do
    [[ -d "$p/System/Library/Extensions" ]] || continue

    bn="$(/usr/bin/basename "$p" 2>/dev/null || echo "")"
    ver="$(kdk_version_from_basename "$bn")"
    key="$(kdk_version_key "$ver" 2>/dev/null || true)"
    [[ -n "$key" ]] || key="000000000000000000000000000000000000"
    m="$(/usr/bin/stat -f "%m" "$p" 2>/dev/null || true)"
    [[ "$m" =~ ^[0-9]+$ ]] || m=0

    /usr/bin/printf '%s %s  %s  %s
' "$key" "$(printf '%012d' "$m")" "$bn" "$p"
  done < <(/usr/bin/find "$base" -maxdepth 1 -type d -name "*.kdk" -print0 2>/dev/null) |     /usr/bin/sort -t $' ' -k1,1r -k2,2r -k3,3 |     /usr/bin/awk -F ' ' '{print $4}'
}

kdk_validate() {
  local kdk="$1"
  [[ -d "$kdk" ]] || fail "Invalid KDK (does not exist): $kdk"
  [[ -d "$kdk/System/Library/Extensions" ]] || fail "Invalid KDK (missing System/Library/Extensions): $kdk"
}

kdk_merge_sle() {
  local kdk="$1"
  kdk_validate "$kdk"
  step "Merging KDK into mnt1 (rsync)"
  info "KDK: $kdk"
  if $VERBOSE; then
    run_show "/usr/bin/rsync -r -i -a '$kdk/System/Library/Extensions/' '${MNT}/System/Library/Extensions/'"
  else
    run_quiet "/usr/bin/rsync -r -i -a '$kdk/System/Library/Extensions/' '${MNT}/System/Library/Extensions/'"
  fi
}

run_kmutil_release() {
  step "Rebuild KernelCollections (kmutil) - release"
  run "/usr/bin/kmutil create --allow-missing-kdk --volume-root '${MNT}' --update-all --variant-suffix release"
  ok "kmutil completed"
}

# Sonoma/Sequoia WiFi: build Auxiliary Kernel Collection (AuxKC) instead of full --update-all
run_kmutil_aux_modern_wireless() {
  step "Building new Auxiliary Kernel Collection (kmutil) - Modern Wireless"
  run "/usr/bin/kmutil create --allow-missing-kdk --new aux --boot-path '${MNT}/System/Library/KernelCollections/BootKernelExtensions.kc' --system-path '${MNT}/System/Library/KernelCollections/SystemKernelExtensions.kc'"
  step "Forcing Auxiliary Kernel Collection usage"
  run "killall -9 syspolicyd kernelmanagerd 2>/dev/null || true"
  run "rm -f /private/var/db/SystemPolicyConfiguration/KextPolicy* 2>/dev/null || true"
  ok "AuxKC prepared"
}

create_snapshot() {
  step "Creating a bootable snapshot (bless --create-snapshot)"
  run "/usr/sbin/bless --folder '${MNT}/System/Library/CoreServices' --bootefi --create-snapshot"
  ok "Snapshot created"
}

# Snapshots:
list_snapshots_readonly_screen_only() {
  step "Snapshots (diskutil apfs listSnapshots /)"
  echo
  /usr/sbin/diskutil apfs listSnapshots / 2>&1
}

list_snapshots_audit() {
  if $VERBOSE; then run_show "/usr/sbin/diskutil apfs listSnapshots /"
  else run_quiet "/usr/sbin/diskutil apfs listSnapshots /"
  fi
}

has_nonsealed_snapshots() {
  # Returns 0 (true) if there is ANY non-sealed snapshot (i.e., beyond the original sealed SSV snapshots).
  # This typically indicates that custom snapshots were created (e.g., by bless --create-snapshot).
  /usr/sbin/diskutil apfs listSnapshots / 2>/dev/null | /usr/bin/grep -qiE 'Sealed:[[:space:]]*No'
}


# KDKs:
list_kdks_readonly_screen_only() {
  step "KDKs (installed in /Library/Developer/KDKs)"
  local kdk_dir="/Library/Developer/KDKs"

  if [[ ! -d "$kdk_dir" ]]; then
    echo
    warn "Directory not found: $kdk_dir"
    return 0
  fi

  local kdks auto_kdk
  kdks="$(kdk_list_sorted "$kdk_dir" || true)"
  auto_kdk="$(kdk_pick_auto 2>/dev/null || true)"

  if [[ -z "$kdks" ]]; then
    warn "No valid KDKs found (*.kdk with System/Library/Extensions) in: $kdk_dir"
    _screen "  ${C_DIM}Tip:${C_RESET} install a KDK and place it under ${C_BOLD}${kdk_dir}${C_RESET}"
    return 0
  fi

  echo
  _screen "==> Installed KDKs (newest first):"
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    local bn meta ver auto_tag
    bn="$(/usr/bin/basename "$p")"
    ver="$(kdk_version_from_basename "$bn")"
    meta="$(/bin/ls -ld "$p" 2>/dev/null | /usr/bin/awk '{print $6" "$7" "$8"  "$5}')"
    auto_tag=""
    [[ -n "$auto_kdk" && "$p" == "$auto_kdk" ]] && auto_tag=" ${C_BOLD}${C_CYAN}[AUTO]${C_RESET}"
    if [[ -n "$ver" ]]; then
      _screen "  ${C_GREEN}•${C_RESET}${auto_tag} ${C_BOLD}${bn}${C_RESET}  ${C_DIM}(version ${ver}) ${meta}${C_RESET}"
    else
      _screen "  ${C_GREEN}•${C_RESET}${auto_tag} ${C_BOLD}${bn}${C_RESET}  ${C_DIM}${meta}${C_RESET}"
    fi
  done <<< "$kdks"
}


rollback_stock() {
  local rootdev sysdev
  rootdev="$(get_root_device)"
  sysdev="$(strip_snapshot_suffix "$rootdev")"
  mount_mnt1_rw "$sysdev"

  step "Revert to the latest SEALED snapshot (Apple stock)"
  run "/usr/sbin/bless --mount '${MNT}' --bootefi --last-sealed-snapshot"
  ok "Rollback prepared"
  ok "Reboot to apply"
}

boot_snapshot_uuid() {
  local uuid="$1"
  [[ -n "$uuid" ]] || fail "Empty UUID in --boot-snapshot"
  local rootdev sysdev
  rootdev="$(get_root_device)"
  sysdev="$(strip_snapshot_suffix "$rootdev")"
  mount_mnt1_rw "$sysdev"

  step "Pointing boot to snapshot UUID"
  info "UUID: $uuid"
  run "/usr/sbin/bless --mount '${MNT}' --bootefi --snapshot '$uuid'"
  ok "Boot snapshot defined"
  ok "Reboot to boot into it"
}

# -------- READ-ONLY: Status (validate payloads on current SSV) --------
do_status() {
  banner
  local os_ver build_ver major
  os_ver="$(get_os_version)"
  build_ver="$(get_build_version)"
  major="$(get_major "$os_ver")"

  step "Status of Root Patch (current SSV)"
  echo
  info "macOS: ${os_ver} (Build ${build_ver}, Major ${major})"
  echo

  local wifi_p="${ROOT_DIR}/payloads/wifi/${major}"
  local audio_p="${ROOT_DIR}/payloads/audio/${major}"

  # helpers (read-only)
  _sha256() { /usr/bin/shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'; }
  _cmp_file_with_payload() {
    # args: payload_file system_file label
    local pf="$1" sf="$2" label="$3"
    if [[ ! -e "$sf" ]]; then
      _screen "  ${C_YELLOW}⚠️ ${C_RESET} ${C_DIM}${label}${C_RESET} (missing from the SSV)"
      return 1
    fi
    local ph sh
    ph="$(_sha256 "$pf")"
    sh="$(_sha256 "$sf")"
    if [[ -n "$ph" && "$ph" == "$sh" ]]; then
      _screen "  ${C_GREEN}✅${C_RESET} ${C_DIM}${label}${C_RESET} (match payload)"
      return 0
    fi
    _screen "  ${C_YELLOW}⚠️ ${C_RESET} ${C_DIM}${label}${C_RESET} (exists, but DIFFERS from the payload)"
    return 1
  }

  _check_item_markers() {
    # args: payload_root item_relpath (starting with /)
    local pr="$1" item="$2"
    local src="${pr}${item}"
    local ok_local=0

    if [[ -f "$src" || -L "$src" ]]; then
      _cmp_file_with_payload "$src" "$item" "$item" || ok_local=1
      return $ok_local
    fi

    if [[ -d "$src" ]]; then
      # Store only the marker DIRECTORY (no trailing glob) so it can be quoted.
      # The '/*' glob is expanded on the quoted dir below, which keeps paths with
      # spaces intact (an unquoted glob string would be word-split by IFS).
      local marker_dir=""
      if [[ "$item" == *.framework ]]; then
        marker_dir="${src}/Versions/A"
      elif [[ "$item" == *.kext ]]; then
        marker_dir="${src}/Contents/MacOS"
      fi

      local found_marker=0
      if [[ -n "$marker_dir" ]]; then
        local mf
        for mf in "$marker_dir"/*; do
          [[ -e "$mf" ]] || continue
          [[ -d "$mf" ]] && continue
          found_marker=1
          local rel="${mf#${pr}}"
          _cmp_file_with_payload "$mf" "$rel" "$rel" || ok_local=1
        done
      fi

      if [[ "$found_marker" -eq 0 && "$item" == *.app ]]; then
        # .app fallback: compare Info.plist
        if [[ -f "${src}/Contents/Info.plist" ]]; then
          local rel="${item}/Contents/Info.plist"
          _cmp_file_with_payload "${src}/Contents/Info.plist" "$rel" "$rel" || ok_local=1
          found_marker=1
        fi
      fi

      if [[ "$found_marker" -eq 0 ]]; then
        # fallback: avoid false positives by only checking existence of directory and warning it's inconclusive
        if [[ -e "$item" ]]; then
          _screen "  ${C_YELLOW}⚠️ ${C_RESET} ${C_DIM}${item}${C_RESET} (only the directory exists; no markers to compare)"
        else
          _screen "  ${C_YELLOW}⚠️ ${C_RESET} ${C_DIM}${item}${C_RESET} (directory missing from the SSV)"
          ok_local=1
        fi
      fi

      return $ok_local
    fi

    _screen "  ${C_YELLOW}⚠️ ${C_RESET} ${C_DIM}${item}${C_RESET} (invalid item in the payload)"
    return 1
  }

  step "WiFi (BCM94360) - HASH-based validation (internal markers) based on the payload"
  local w_ok=0
  if [[ -d "$wifi_p" ]]; then
    while IFS= read -r item; do
      [[ -z "$item" ]] && continue
      if [[ -e "${wifi_p}${item}" ]]; then
        _check_item_markers "$wifi_p" "$item" || w_ok=1
      else
        _screen "  ${C_YELLOW}⚠️ ${C_RESET} ${C_DIM}${item}${C_RESET} (missing from the payload)"
        w_ok=1
      fi
    done < <(wifi_items_for_major "$major" 2>/dev/null || true)
  else
    warn "Wi-Fi payload not found: ${wifi_p}"
    w_ok=1
  fi

  echo
  step "Audio (AppleHDA) - HASH validation based on the payload (Tahoe/26 only)"
  local a_ok=0
  if [[ "$major" == "26" && -d "$audio_p" ]]; then
    while IFS= read -r item; do
      [[ -z "$item" ]] && continue
      if [[ -e "${audio_p}${item}" ]]; then
        _check_item_markers "$audio_p" "$item" || a_ok=1
      else
        _screen "  ${C_YELLOW}⚠️ ${C_RESET} ${C_DIM}${item}${C_RESET} (missing from the payload)"
        a_ok=1
      fi
    done < <(audio_items_for_major "$major" 2>/dev/null || true)
  else
    _screen "  ${C_DIM}(not applicable on this version / no audio payload available)${C_RESET}"
  fi

  echo
  _screen "${C_BOLD}${C_MAGENTA}==================== STATUS SUMMARY ===================${C_RESET}"
  if [[ "$w_ok" -eq 0 ]]; then
    _screen "${C_BOLD}WiFi: ${C_RESET} ${C_GREEN}✅ applied (hash matches payload)${C_RESET}"
  else
    _screen "${C_BOLD}WiFi: ${C_RESET} ${C_YELLOW}⚠️  not applied or differs from the payload${C_RESET}"
  fi

  if [[ "$major" == "26" ]]; then
    if [[ "$a_ok" -eq 0 ]]; then
      _screen "${C_BOLD}Audio:${C_RESET} ${C_GREEN}✅ applied (hash matches payload)${C_RESET}"
    else
      _screen "${C_BOLD}Audio:${C_RESET} ${C_YELLOW}⚠️  not applied or differs from the payload${C_RESET}"
    fi
  else
    _screen "${C_BOLD}Audio:${C_RESET} ${C_DIM}(not applicable)${C_RESET}"
  fi
  _screen "${C_BOLD}${C_MAGENTA}=======================================================${C_RESET}"
  echo
}

# -------- READ-ONLY: Check EFI config.plist (OpenCore) --------
do_check_efi() {
  banner
  step "EFI checker (OpenCore config.plist)"

  local cfg="${1:-}"

  if [[ -z "${cfg}" ]]; then
    echo
    _screen "${C_BOLD}Drag & drop your OpenCore config.plist here and press ENTER (or type the full path):${C_RESET}"
    read -r -p "Path: " cfg || true
    cfg="${cfg:-}"
  fi

  # sanitize drag&drop paths (quotes / backslash escapes)
  _resolve_cfg_path() {
    local in="$1"
    # trim whitespace
    in="$(/usr/bin/printf '%s' "$in" | /usr/bin/sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    # strip surrounding quotes (single/double)
    in="$(/usr/bin/printf '%s' "$in" | /usr/bin/sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")"

    # 1) as-is (CLI already resolves escapes)
    if [[ -f "$in" ]]; then
      /usr/bin/printf '%s' "$in"
      return 0
    fi

    # 2) unescape Finder drag&drop form (e.g. spaces as '\ ')
    local unesc
    unesc="$(/usr/bin/printf '%b' "$in")"
    if [[ -f "$unesc" ]]; then
      /usr/bin/printf '%s' "$unesc"
      return 0
    fi

    # 3) extra fallback: replace '\ ' -> ' ' (in case printf '%b' doesn't change it)
    unesc="${in//\\ / }"
    if [[ -f "$unesc" ]]; then
      /usr/bin/printf '%s' "$unesc"
      return 0
    fi

    /usr/bin/printf '%s' "$unesc"
    return 1
  }

  # In the interactive menu, do NOT terminate the whole program on input errors.
  # Instead, print the error and return so the menu can prompt the user (ENTER=menu / Q=quit).
  if [[ -z "${cfg}" ]]; then
    if [[ "${RP_CORE_PARENT_MENU:-0}" == "1" ]]; then
      echo
      _screen "${C_RED}${C_BOLD}[ERR ]${C_RESET} Empty config.plist path."
      return 0
    fi
    fail "Empty config.plist path."
  fi

  local resolved_cfg=""
  # NOTE: _resolve_cfg_path may return 1 when the file doesn't exist. In Bash 3.2,
  # that can still trigger the global ERR trap (and print the generic interruption
  # banner), even though we're handling this case. So we swallow the exit status
  # and validate existence explicitly below.
  resolved_cfg="$(_resolve_cfg_path "$cfg" || true)"

  if [[ -z "${resolved_cfg}" || ! -f "${resolved_cfg}" ]]; then
    if [[ "${RP_CORE_PARENT_MENU:-0}" == "1" ]]; then
      echo
      _screen "${C_RED}${C_BOLD}[ERR ]${C_RESET} config.plist not found: ${resolved_cfg:-$cfg}"
      return 0
    fi
    fail "config.plist not found: ${resolved_cfg:-$cfg}"
  fi

  cfg="${resolved_cfg}"

  echo 
  info "config.plist: ${cfg}"
  echo

  if ! have_cmd python3; then
    if [[ "${RP_CORE_PARENT_MENU:-0}" == "1" ]]; then
      echo
      _screen "${C_RED}${C_BOLD}[ERR ]${C_RESET} python3 is required for --check-efi (not found)."
      return 0
    fi
    fail "python3 is required for --check-efi (not found)."
  fi

  # Bash 3.2 safe: write python to a temp file, then execute it
  local py_tmp
  py_tmp="$(/usr/bin/mktemp -t rootpatch-efi.XXXXXX.py)"
  /bin/cat > "$py_tmp" <<'PY'
import sys, plistlib, base64, binascii

path = sys.argv[1]

def emit(cid, ok, detail):
    print("CHECK|%s|%d|%s" % (cid, 1 if ok else 0, detail))

def load_plist(p):
    with open(p, "rb") as f:
        return plistlib.load(f)

pl = load_plist(path)

kernel = pl.get("Kernel", {})
k_add = kernel.get("Add", []) or []
k_block = kernel.get("Block", []) or []

def kext_hits(name_substr):
    hits = []
    for e in k_add:
        bp = str(e.get("BundlePath", ""))
        if name_substr in bp or bp.endswith(name_substr):
            hits.append((bp, bool(e.get("Enabled", False))))
    return hits

def kext_enabled(name_substr):
    hits = kext_hits(name_substr)
    any_enabled = any(en for _, en in hits)
    return any_enabled, hits


def _norm_kernel(v):
    if v is None:
        return ""
    if isinstance(v, (bytes, bytearray)):
        try:
            return v.decode("utf-8", "ignore")
        except Exception:
            return str(v)
    return str(v)

def kext_hits_minmax(name_substr):
    hits = []
    for e in k_add:
        bp = str(e.get("BundlePath", ""))
        if name_substr in bp or bp.endswith(name_substr):
            hits.append((bp, bool(e.get("Enabled", False)),
                         _norm_kernel(e.get("MinKernel", "")),
                         _norm_kernel(e.get("MaxKernel", ""))))
    return hits

def kext_minmax_blank(name_substr):
    hits = kext_hits_minmax(name_substr)
    if not hits:
        return True, []
    ok = True
    for _, _, mink, maxk in hits:
        if str(mink).strip() or str(maxk).strip():
            ok = False
    return ok, hits

def find_block(identifier):
    hits = []
    for e in k_block:
        if str(e.get("Identifier", "")) == identifier:
            hits.append(e)
    return hits

# WiFi kext checks
for cid, needle in [
    ("WIFI_AMFIPASS", "AMFIPass.kext"),
    ("WIFI_IO80211FAMILYLEGACY", "IO80211FamilyLegacy.kext"),
    ("WIFI_IOSKYWALKFAMILY", "IOSkywalkFamily.kext"),
]:
    ok, hits = kext_enabled(needle)
    if not hits:
        emit(cid, False, "%s : NOT FOUND in Kernel->Add" % needle)
    else:
        paths = ", ".join(["%s (Enabled=%s)" % (bp, en) for bp, en in hits])
        emit(cid, ok, paths)

# AirPortBrcmNIC (plugin)
ok, hits = kext_enabled("AirPortBrcmNIC.kext")
if not hits:
    emit("WIFI_AIRPORTBRCMNIC", False, "AirPortBrcmNIC.kext : NOT FOUND in Kernel->Add")
else:
    where = []
    for bp, en in hits:
        parent = "unknown"
        if "IOSkywalkFamily.kext" in bp:
            parent = "IOSkywalkFamily.kext/PlugIns"
        elif "IO80211FamilyLegacy.kext" in bp:
            parent = "IO80211FamilyLegacy.kext/PlugIns"
        where.append("%s [%s] (Enabled=%s)" % (bp, parent, en))
    emit("WIFI_AIRPORTBRCMNIC", ok, "; ".join(where))

# WiFi: MinKernel/MaxKernel must be EMPTY for BCM-related kexts/plugins
for cid, needle in [
    ("WIFI_MINMAX_AMFIPASS", "AMFIPass.kext"),
    ("WIFI_MINMAX_IO80211FAMILYLEGACY", "IO80211FamilyLegacy.kext"),
    ("WIFI_MINMAX_IOSKYWALKFAMILY", "IOSkywalkFamily.kext"),
    ("WIFI_MINMAX_AIRPORTBRCMNIC", "AirPortBrcmNIC.kext"),
]:
    ok_mm, hits_mm = kext_minmax_blank(needle)
    if not hits_mm:
        emit(cid, True, "%s : NOT FOUND in Kernel->Add (skip MinKernel/MaxKernel check)" % needle)
    else:
        desc = []
        for bp, en, mink, maxk in hits_mm:
            mk = str(mink).strip()
            xk = str(maxk).strip()
            if mk == "":
                mk = "<empty>"
            if xk == "":
                xk = "<empty>"
            desc.append("%s (Enabled=%s MinKernel=%s MaxKernel=%s)" % (bp, en, mk, xk))
        extra = "" if ok_mm else " (MinKernel/MaxKernel must be empty)"
        emit(cid, ok_mm, ", ".join(desc) + extra)

# Kernel->Block entry
ident = "com.apple.iokit.IOSkywalkFamily"
bhits = find_block(ident)
if not bhits:
    emit("WIFI_BLOCK_IOSKYWALKFAMILY", False, "Kernel->Block entry not found for Identifier='%s'" % ident)
else:
    def parse_ver(s):
        try:
            parts = [int(x) for x in str(s).split(".") if x.strip() != ""]
            while len(parts) < 3:
                parts.append(0)
            return tuple(parts[:3])
        except Exception:
            return None

    ok_any = False
    details = []
    for e in bhits:
        en = bool(e.get("Enabled", False))
        mink = e.get("MinKernel", "")
        maxk = e.get("MaxKernel", "")
        pv = parse_ver(maxk)
        max_ok = False
        if pv is not None:
            max_ok = pv[0] >= 25
        ok_this = en and max_ok
        ok_any = ok_any or ok_this
        details.append("Enabled=%s, MinKernel=%s, MaxKernel=%s (major>=25:%s)" % (en, mink, maxk, max_ok))
    emit("WIFI_BLOCK_IOSKYWALKFAMILY", ok_any, " | ".join(details))

# SecureBootModel
sbm = ((pl.get("Misc", {}) or {}).get("Security", {}) or {}).get("SecureBootModel", None)
sbm_s = "" if sbm is None else str(sbm)
emit("WIFI_SECUREBOOTMODEL", sbm_s.lower() == "disabled", "SecureBootModel=%s" % sbm_s)

# NVRAM vars
guid = "7C436110-AB2A-4BBB-A880-FE41995C9F82"
nvram_add = (pl.get("NVRAM", {}) or {}).get("Add", {}) or {}
nv = nvram_add.get(guid, {}) or {}

# csr-active-config
csr = nv.get("csr-active-config", None)
target = bytes.fromhex("03080000")

ok_csr = False
detail_csr = "csr-active-config not found"
if csr is not None:
    if isinstance(csr, (bytes, bytearray)):
        ok_csr = bytes(csr) == target
        detail_csr = "hex=%s" % binascii.hexlify(bytes(csr)).decode()
    else:
        val = str(csr).strip()
        try:
            raw = base64.b64decode(val)
            ok_csr = raw == target
            detail_csr = "base64=%s hex=%s" % (val, binascii.hexlify(raw).decode())
        except Exception:
            try:
                raw = bytes.fromhex(val.replace("0x", "").replace(" ", "").replace("<", "").replace(">", ""))
                ok_csr = raw == target
                detail_csr = "hex=%s" % binascii.hexlify(raw).decode()
            except Exception:
                detail_csr = "value=%s (unparsed)" % val
emit("WIFI_CSR_ACTIVE_CONFIG", ok_csr, detail_csr + " (expected hex=03080000 / base64=AwgAAA==)")

# boot-args contains -amfipassbeta
boot_args = nv.get("boot-args", "")
if isinstance(boot_args, (bytes, bytearray)):
    try:
        boot_s = boot_args.decode("utf-8", "ignore")
    except Exception:
        boot_s = str(boot_args)
else:
    boot_s = str(boot_args)
emit("WIFI_BOOTARGS_AMFIPASSBETA", ("-amfipassbeta" in boot_s), "boot-args='%s'" % boot_s)

# Audio: AppleALC.kext enabled
ok, hits = kext_enabled("AppleALC.kext")
if not hits:
    emit("AUDIO_APPLEALC", False, "AppleALC.kext : NOT FOUND in Kernel->Add")
else:
    paths = ", ".join(["%s (Enabled=%s)" % (bp, en) for bp, en in hits])
    emit("AUDIO_APPLEALC", ok, paths)
PY

  local py_out
  local py_rc=0
  py_out="$(/usr/bin/python3 "$py_tmp" "$cfg" 2>&1)" || py_rc=$?
  if [[ "$py_rc" -ne 0 ]]; then
    /bin/rm -f "$py_tmp" 2>/dev/null || true
    if [[ "${RP_CORE_PARENT_MENU:-0}" == "1" ]]; then
      _screen "${C_RED}${C_BOLD}[ERR ]${C_RESET} EFI checker failed to parse the config.plist."
      echo
      _screen "${C_DIM}${py_out}${C_RESET}"
      return 0
    fi
    fail "EFI checker failed to parse the config.plist: ${py_out}"
  fi
  /bin/rm -f "$py_tmp" 2>/dev/null || true

  local wifi_ok=1 audio_ok=1
  local tag cid okflag details

  step "WiFi patch requirements"
  while IFS='|' read -r tag cid okflag details; do
    [[ "$tag" == "CHECK" ]] || continue
    case "$cid" in
      WIFI_*)
        if [[ "$okflag" == "1" ]]; then
          _screen "  ${C_GREEN}✅${C_RESET} ${C_BOLD}${cid}${C_RESET}"
          # _screen "  ${C_GREEN}✅${C_RESET} ${C_BOLD}${cid}${C_RESET} ${C_DIM}${details}${C_RESET}"
        else
          _screen "  ${C_YELLOW}⚠️ ${C_RESET} ${C_BOLD}${cid}${C_RESET}"
          #_screen "  ${C_YELLOW}⚠️ ${C_RESET} ${C_BOLD}${cid}${C_RESET} ${C_DIM}${details}${C_RESET}"
          wifi_ok=0
        fi
        ;;
    esac
  done <<<"$py_out"

  echo
  step "Audio patch requirements"
  while IFS='|' read -r tag cid okflag details; do
    [[ "$tag" == "CHECK" ]] || continue
    case "$cid" in
      AUDIO_*)
        if [[ "$okflag" == "1" ]]; then
          _screen "  ${C_GREEN}✅${C_RESET} ${C_BOLD}${cid}${C_RESET}"
          # _screen "  ${C_GREEN}✅${C_RESET} ${C_BOLD}${cid}${C_RESET} ${C_DIM}${details}${C_RESET}"
        else
          _screen "  ${C_YELLOW}⚠️ ${C_RESET} ${C_BOLD}${cid}${C_RESET}"
          #_screen "  ${C_YELLOW}⚠️ ${C_RESET} ${C_BOLD}${cid}${C_RESET} ${C_DIM}${details}${C_RESET}"
          audio_ok=0
        fi
        ;;
    esac
  done <<<"$py_out"

  echo
  _screen "${C_BOLD}${C_MAGENTA}==================== EFI SUMMARY ======================${C_RESET}"
  if [[ "$wifi_ok" -eq 1 ]]; then
    _screen "${C_BOLD}WiFi prerequisites:${C_RESET} ${C_GREEN}✅ OK${C_RESET}"
  else
    _screen "${C_BOLD}WiFi prerequisites:${C_RESET} ${C_YELLOW}⚠️  NOT OK${C_RESET}"
  fi

  if [[ "$audio_ok" -eq 1 ]]; then
    _screen "${C_BOLD}Audio prerequisites:${C_RESET} ${C_GREEN}✅ OK${C_RESET}"
  else
    _screen "${C_BOLD}Audio prerequisites:${C_RESET} ${C_YELLOW}⚠️  NOT OK${C_RESET}"
  fi

  if [[ "$wifi_ok" -eq 1 && "$audio_ok" -eq 1 ]]; then
    _screen "${C_BOLD}Overall:${C_RESET} ${C_GREEN}✅ Patch-ready (WiFi + Audio)${C_RESET}"
  elif [[ "$wifi_ok" -eq 1 ]]; then
    _screen "${C_BOLD}Overall:${C_RESET} ${C_GREEN}✅ Patch-ready (WiFi)${C_RESET} ${C_DIM}(audio may require extra setup)${C_RESET}"
  else
    _screen "${C_BOLD}Overall:${C_RESET} ${C_YELLOW}⚠️  Not ready - fix EFI config first${C_RESET}"
  fi

  _screen "${C_BOLD}${C_MAGENTA}=======================================================${C_RESET}"
  echo
}

# Audit environment (screen_mode: show|hide)
audit_environment() {
  local os_ver="$1" build_ver="$2" major="$3"
  local screen_mode="${4:-show}"

  if $LOG_ENABLED; then _log "==> Environment audit"; fi

  if [[ "$screen_mode" == "show" ]]; then
    step "Environment audit"
  fi

  if [[ "$screen_mode" == "show" ]]; then
    info "ProductVersion: ${os_ver}"
    info "BuildVersion  : ${build_ver}"
    info "Major         : ${major}"
  fi
  if $LOG_ENABLED; then
    _log "ProductVersion: ${os_ver}"
    _log "BuildVersion  : ${build_ver}"
    _log "Major         : ${major}"
  fi

  local outc outa
  outc="$(/usr/bin/csrutil status 2>&1 || true)"
  outa="$(/usr/bin/csrutil authenticated-root status 2>&1 || true)"

  if [[ "$screen_mode" == "show" ]]; then
    info "uname -a"
    /usr/bin/uname -a 2>&1 | while IFS= read -r line; do _screen "${C_DIM}│${C_RESET} $line"; done

    info "csrutil status"
    if $VERBOSE; then
      echo "$outc" | while IFS= read -r line; do _screen "${C_DIM}│${C_RESET} $line"; done
    else
      echo "$outc" | head -n 2 | while IFS= read -r line; do _screen "${C_DIM}│${C_RESET} $line"; done
      if [[ "$(echo "$outc" | wc -l | tr -d ' ')" -gt 2 ]]; then _screen "${C_DIM}│${C_RESET} (Full details are in the log, if enabled)"; fi
    fi

    info "csrutil authenticated-root status"
    if $VERBOSE; then
      echo "$outa" | while IFS= read -r line; do _screen "${C_DIM}│${C_RESET} $line"; done
    else
      echo "$outa" | head -n 2 | while IFS= read -r line; do _screen "${C_DIM}│${C_RESET} $line"; done
      if [[ "$(echo "$outa" | wc -l | tr -d ' ')" -gt 2 ]]; then _screen "${C_DIM}│${C_RESET} (Full details are in the log, if enabled)"; fi
    fi
    ok "Audit completed"
  fi

  if $LOG_ENABLED; then
    /usr/bin/uname -a >>"$LOG_FILE" 2>&1 || true
    echo "$outc" >>"$LOG_FILE"
    echo "$outa" >>"$LOG_FILE"
    _log "[ OK ] Audit completed"
  fi
}

# ---- Summary helpers ----
SUMMARY_MODE="(none)"
SUMMARY_OS_VER="(unknown)"
SUMMARY_BUILD="(unknown)"
SUMMARY_MAJOR="(unknown)"
SUMMARY_WIFI_PAYLOAD="(none)"
SUMMARY_AUDIO_PAYLOAD="(none)"
SUMMARY_KDK="(none)"
SUMMARY_STATUS_WIFI="⚠️  not applied"
SUMMARY_STATUS_AUDIO="⚠️  not applied"
SUMMARY_STATUS_SNAPSHOT="⚠️  not created"
SUMMARY_LOG_LINE="(without log)"

print_summary() {
  echo
  _screen "${C_BOLD}${C_MAGENTA}==================== FINAL SUMMARY ====================${C_RESET}"
  _screen "${C_BOLD}Mode:${C_RESET} ${SUMMARY_MODE}"
  _screen "${C_BOLD}macOS:${C_RESET} ${SUMMARY_OS_VER}  (Build ${SUMMARY_BUILD}, Major ${SUMMARY_MAJOR})"
  _screen "${C_BOLD}WiFi:${C_RESET} ${SUMMARY_STATUS_WIFI}"
  _screen "  ${C_DIM}Payload:${C_RESET} ${SUMMARY_WIFI_PAYLOAD}"
  _screen "${C_BOLD}Audio:${C_RESET} ${SUMMARY_STATUS_AUDIO}"
  _screen "  ${C_DIM}Payload:${C_RESET} ${SUMMARY_AUDIO_PAYLOAD}"
  _screen "  ${C_DIM}KDK:${C_RESET} ${SUMMARY_KDK}"
  _screen "${C_BOLD}Snapshot:${C_RESET} ${SUMMARY_STATUS_SNAPSHOT}"
  # _screen "  ${C_DIM}${SUMMARY_LOG_LINE}${C_RESET}"
  _screen "${C_BOLD}${C_MAGENTA}=======================================================${C_RESET}"
  echo
}

prompt_reboot() {
  if $DRY_RUN; then
    ok "Dry-run: reboot will not be performed."
    return 0
  fi
  read -r -p "Reboot now? (y/N) " ans || true
  echo
  ans="$(echo "${ans:-}" | tr '[:upper:]' '[:lower:]')"
  case "$ans" in
    y|yes|s|sim) info "Rebooting..."; /sbin/reboot ;;
    *) warn "Reboot pending (you chose not to reboot now)." ;;
  esac
}

# -------------------------
# Interactive menu (for .command double-click usage)
# -------------------------
interactive_menu() {

# In interactive menu, show the splash only once (at entry).
# Prevent nested CLI re-invocations (menu actions) from showing the splash again.
export NO_SPLASH=1

_pause_or_quit() {
  local prompt="${1:-Press ENTER to return to menu, or Q to quit: }"
  local ans=""
  echo
  read -r -p "$prompt" ans || true
  ans="${ans:-}"
  if [[ "$ans" == "Q" || "$ans" == "q" ]]; then
    ok "Bye!"
    return 1
  fi
  return 0
}

local opt="" ans=""
local vflag="$VERBOSE"
local dflag="$DRY_RUN"

while true; do
  # Keep the screen clean (avoid scroll / history spam)
  clear

  banner
  echo 
  info "Interactive mode: type the option number and press Enter."
  echo

  local os_ver build_ver major
  os_ver="$(get_os_version)"
  build_ver="$(get_build_version)"
  major="$(get_major "$os_ver")"

  _screen "${C_BOLD}${C_MAGENTA}--------------------------- MENU ----------------------------${C_RESET}"
  _screen "  ${C_BOLD}macOS:${C_RESET} ${os_ver} (Build ${build_ver}, Major ${major})"
  _screen "  ${C_BOLD}Verbose:${C_RESET} ${vflag}   ${C_BOLD}Dry-run:${C_RESET} ${dflag}"
  _screen "${C_BOLD}${C_MAGENTA}------------------------------------------------------------${C_RESET}"
  _screen " 1) Status (validate WiFi/Audio in the current SSV)"
  _screen " 2) Apply WiFi patch"
  _screen " 3) Apply Audio patch (Tahoe only)"
  _screen " 4) Apply WiFi + Audio (Tahoe only)"
  _screen " 5) List snapshots"
  _screen " 6) Boot snapshot by UUID"
  _screen " 7) Rollback to Apple sealed snapshot (stock)"
  _screen " 8) Check EFI (validate OpenCore config.plist requirements)"  
  _screen " 9) List installed KDKs"
  _screen " Q) Exit"
  echo
  read -r -p "Select: " opt || true
  opt="${opt:-}"

  case "$opt" in
    1)
      clear
      ( VERBOSE="$vflag"; DRY_RUN="$dflag"; do_status )
      _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
      ;;
    2)
      local args=(--mode wifi)
      [[ "$vflag" == true ]] && args+=(--verbose)
      [[ "$dflag" == true ]] && args+=(--dry-run)
      local rc=0

      RP_CORE_PARENT_MENU=1 "${ROOT_DIR}/rp-core.sh" "${args[@]}" || rc=$?

      if [[ "$rc" -eq "${SIP_GUARD_RC_QUIT}" || "$rc" -eq "${FILEVAULT_GUARD_RC_QUIT}" ]]; then ok "Bye!"; break; fi

      if [[ "$rc" -eq "${SIP_GUARD_RC_MENU_RETURN}" || "$rc" -eq "${FILEVAULT_GUARD_RC_MENU_RETURN}" ]]; then continue; fi
      # If user chose not to reboot, offer clean return to menu or quit
      _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
      ;;
    3)
      if [[ "$major" != "26" ]]; then
        echo
        warn "Audio (AppleHDA) applies ONLY to Tahoe (major 26)."
        _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
        continue
      fi
      echo
      _screen "${C_BOLD}Audio requires a KDK.${C_RESET}"
      _screen "  a) --kdk-auto (recommended)"
      _screen "  p) --kdk <path_to_.kdk>"
      _screen "  n) --no-kdk-merge (less robust)"
      local kdk_opt="" kdk_path=""
      echo
      read -r -p "Choose (a/p/n) [a]: " kdk_opt || true
      kdk_opt="${kdk_opt:-a}"

      local args=(--mode audio)
      [[ "$vflag" == true ]] && args+=(--verbose)
      [[ "$dflag" == true ]] && args+=(--dry-run)

      case "$kdk_opt" in
        a|A)
          # Show the auto-selected KDK and ask for confirmation before proceeding.
          local auto_kdk=""
          auto_kdk="$( (kdk_pick_auto) 2>/dev/null || true )"
          if [[ -z "${auto_kdk}" ]] || [[ "${auto_kdk}" != *.kdk ]] || [[ ! -d "${auto_kdk}/System/Library/Extensions" ]]; then
            echo
            warn "Unable to auto-select a valid KDK. Please install a KDK under /Library/Developer/KDKs or choose option 'p'."
            _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
            continue
          fi

          echo
          info "Auto-selected KDK: ${auto_kdk}"
          echo
          local confirm=""
          read -r -p "Continue with this KDK? (y/N) " confirm || true
          confirm="$(echo "${confirm:-}" | tr '[:upper:]' '[:lower:]')"
          case "$confirm" in
            y|yes)
              args+=(--kdk "${auto_kdk}")
              ;;
            *)
              warn "Aborted by user. Returning to the main menu."
              continue
              ;;
          esac
          ;;
        p|P)
          read -r -p "Enter full path to .kdk: " kdk_path || true
          [[ -z "${kdk_path:-}" ]] && { warn "Empty KDK path. Aborting."; _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break; continue; }
          args+=(--kdk "$kdk_path")
          ;;
        n|N) args+=(--no-kdk-merge) ;;
        *) warn "Invalid selection. Aborting."; _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break; continue ;;
      esac

      local rc=0


      RP_CORE_PARENT_MENU=1 "${ROOT_DIR}/rp-core.sh" "${args[@]}" || rc=$?


      if [[ "$rc" -eq "${SIP_GUARD_RC_QUIT}" || "$rc" -eq "${FILEVAULT_GUARD_RC_QUIT}" ]]; then ok "Bye!"; break; fi


      if [[ "$rc" -eq "${SIP_GUARD_RC_MENU_RETURN}" || "$rc" -eq "${FILEVAULT_GUARD_RC_MENU_RETURN}" ]]; then continue; fi
      _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
      ;;
    4)
      if [[ "$major" != "26" ]]; then
        echo
        warn "WiFi+Audio: audio is only for Tahoe (major 26). Use WiFi-only on 14/15."
        _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
        continue
      fi
      echo
      _screen "${C_BOLD}Audio requires a KDK.${C_RESET}"
      _screen "  a) --kdk-auto (recommended)"
      _screen "  p) --kdk <path_to_.kdk>"
      _screen "  n) --no-kdk-merge (less robust)"
      local kdk_opt="" kdk_path=""
      echo
      read -r -p "Choose (a/p/n) [a]: " kdk_opt || true
      kdk_opt="${kdk_opt:-a}"

      local args=(--mode both)
      [[ "$vflag" == true ]] && args+=(--verbose)
      [[ "$dflag" == true ]] && args+=(--dry-run)

      case "$kdk_opt" in
        a|A)
          # Show the auto-selected KDK and ask for confirmation before proceeding.
          local auto_kdk=""
          auto_kdk="$( (kdk_pick_auto) 2>/dev/null || true )"
          if [[ -z "${auto_kdk}" ]] || [[ "${auto_kdk}" != *.kdk ]] || [[ ! -d "${auto_kdk}/System/Library/Extensions" ]]; then
            echo
            warn "Unable to auto-select a valid KDK. Please install a KDK under /Library/Developer/KDKs or choose option 'p'."
            _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
            continue
          fi

          echo
          info "Auto-selected KDK: ${auto_kdk}"
          echo
          local confirm=""
          read -r -p "Continue with this KDK? (y/N) " confirm || true
          confirm="$(echo "${confirm:-}" | tr '[:upper:]' '[:lower:]')"
          case "$confirm" in
            y|yes)
              args+=(--kdk "${auto_kdk}")
              ;;
            *)
              warn "Aborted by user. Returning to the main menu."
              continue
              ;;
          esac
          ;;
        p|P)
          read -r -p "Enter full path to .kdk: " kdk_path || true
          [[ -z "${kdk_path:-}" ]] && { warn "Empty KDK path. Aborting."; _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break; continue; }
          args+=(--kdk "$kdk_path")
          ;;
        n|N) args+=(--no-kdk-merge) ;;
        *) warn "Invalid selection. Aborting."; _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break; continue ;;
      esac

      local rc=0


      RP_CORE_PARENT_MENU=1 "${ROOT_DIR}/rp-core.sh" "${args[@]}" || rc=$?


      if [[ "$rc" -eq "${SIP_GUARD_RC_QUIT}" || "$rc" -eq "${FILEVAULT_GUARD_RC_QUIT}" ]]; then ok "Bye!"; break; fi


      if [[ "$rc" -eq "${SIP_GUARD_RC_MENU_RETURN}" || "$rc" -eq "${FILEVAULT_GUARD_RC_MENU_RETURN}" ]]; then continue; fi
      _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
      ;;
    5)
      clear
      banner
      "${ROOT_DIR}/rp-core.sh" --list-snapshots
      _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
      ;;
    6)
      clear
      banner
      echo
      info "Available boot snapshots:"
      echo
      list_snapshots_readonly_screen_only
      echo
      local uuid=""
      read -r -p "Enter snapshot UUID (or press ENTER to return to the main menu): " uuid || true
      uuid="${uuid:-}"
      if [[ -z "$uuid" ]]; then
        info "No UUID provided. Returning to the main menu."
        continue
      fi

      echo
      info "Selected UUID: $uuid"
      local confirm=""
      echo
      read -r -p "Proceed with this UUID? (y/N) " confirm || true
      confirm="$(echo "${confirm:-}" | tr '[:upper:]' '[:lower:]')"
      if [[ "$confirm" != "y" && "$confirm" != "yes" ]]; then
        warn "Aborted by user. Returning to the main menu."
        continue
      fi

      local args=(--boot-snapshot "$uuid")
      [[ "$vflag" == true ]] && args+=(--verbose)
      [[ "$dflag" == true ]] && args+=(--dry-run)
      local rc=0

      RP_CORE_PARENT_MENU=1 "${ROOT_DIR}/rp-core.sh" "${args[@]}" || rc=$?

      if [[ "$rc" -eq "${SIP_GUARD_RC_QUIT}" || "$rc" -eq "${FILEVAULT_GUARD_RC_QUIT}" ]]; then ok "Bye!"; break; fi

      if [[ "$rc" -eq "${SIP_GUARD_RC_MENU_RETURN}" || "$rc" -eq "${FILEVAULT_GUARD_RC_MENU_RETURN}" ]]; then continue; fi
      _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
      ;;
    7)

      echo
      warn "WARNING: Rolling back to STOCK will disable ALL previously applied patches (WiFi/Audio) and any other SSV modifications."
      warn "This action sets the boot snapshot to Apple's latest SEALED snapshot."
      echo
      read -r -p "Type Y to proceed, or press ENTER to return to the main menu: " ans || true
      ans="$(echo "${ans:-}" | tr '[:upper:]' '[:lower:]')"
      if [[ "$ans" != "y" && "$ans" != "yes" ]]; then
        info "Rollback cancelled. Returning to the main menu."
        continue
      fi

      local args=(--rollback-stock)
      [[ "$vflag" == true ]] && args+=(--verbose)
      [[ "$dflag" == true ]] && args+=(--dry-run)
      local rc=0

      RP_CORE_PARENT_MENU=1 "${ROOT_DIR}/rp-core.sh" "${args[@]}" || rc=$?

      if [[ "$rc" -eq "${SIP_GUARD_RC_QUIT}" || "$rc" -eq "${FILEVAULT_GUARD_RC_QUIT}" ]]; then ok "Bye!"; break; fi

      if [[ "$rc" -eq "${SIP_GUARD_RC_MENU_RETURN}" || "$rc" -eq "${FILEVAULT_GUARD_RC_MENU_RETURN}" ]]; then continue; fi
      _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
      ;;
    8)
      clear
      RP_CORE_PARENT_MENU=1 do_check_efi
      _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
      ;;
    9)
      clear
      banner
      "${ROOT_DIR}/rp-core.sh" --list-kdk
      _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
      ;;
    "q"|"Q")
      ok "Bye!"
      break
      ;;
    "")
      warn "Invalid option."
      _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
      ;;
    *)
      warn "Invalid option."
      _pause_or_quit "Press ENTER to return to menu, or Q to quit: " || break
      ;;
  esac
done
}

# -------------------------
# Args
# -------------------------
MODE=""
KDK_PATH=""
KDK_AUTO=false
NO_KDK_MERGE=false
DO_ROLLBACK=false
BOOT_UUID=""
LIST_SNAPSHOTS=false
LIST_KDKS=false
DO_STATUS=false
DO_CHECK_EFI=false
EFI_CONFIG_PATH=\"\"
INTERACTIVE=false

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --status) DO_STATUS=true; shift ;;
    --check-efi)
      DO_CHECK_EFI=true
      # allow: --check-efi <path_to_config.plist>
      if [[ -n "${2:-}" && "${2:0:1}" != "-" ]]; then EFI_CONFIG_PATH="${2}"; shift 2; else shift; fi
      ;;
    --oc-config) EFI_CONFIG_PATH="${2:-}"; shift 2 ;;
    --interactive) INTERACTIVE=true; shift ;;
    --mode) MODE="${2:-}"; shift 2 ;;
    --kdk) KDK_PATH="${2:-}"; shift 2 ;;
    --kdk-auto) KDK_AUTO=true; shift ;;
    --no-kdk-merge) NO_KDK_MERGE=true; shift ;;
    --rollback-stock) DO_ROLLBACK=true; shift ;;
    --boot-snapshot) BOOT_UUID="${2:-}"; shift 2 ;;
    --list-snapshots) LIST_SNAPSHOTS=true; shift ;;
    --list-kdk) LIST_KDKS=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown argument: $1 (use --help)" ;;
  esac
done

# --status is READ-ONLY and should not create logs

# Splash only for interactive or mutating actions
if [[ "$INTERACTIVE" == true || -n "${MODE:-}" || -n "${BOOT_UUID:-}" || "${DO_ROLLBACK}" == true ]]; then
  show_splash
fi

if [[ "$INTERACTIVE" == true ]]; then
  interactive_menu
  exit 0
fi
if [[ "$DO_STATUS" == true ]]; then
  do_status
  exit 0
fi
if [[ "$DO_CHECK_EFI" == true ]]; then
  do_check_efi "${EFI_CONFIG_PATH:-}"
  exit 0
fi

# Enable logs ONLY for mutating actions:
if [[ -n "${MODE:-}" ]] || [[ -n "${BOOT_UUID:-}" ]] || [[ "${DO_ROLLBACK}" == true ]]; then
  LOG_ENABLED=true
fi

banner
check_tools

OS_VER="$(get_os_version)"
BUILD_VER="$(get_build_version)"
MAJOR="$(get_major "$OS_VER")"

SUMMARY_OS_VER="$OS_VER"
SUMMARY_BUILD="$BUILD_VER"
SUMMARY_MAJOR="$MAJOR"

if $LOG_ENABLED; then
  SUMMARY_LOG_LINE="Audit/log: ${LOG_FILE}"
else
  SUMMARY_LOG_LINE="Audit/log: (disabled - read-only mode)"
fi

# Supported majors
case "$MAJOR" in
  14|15|26) ;;
  *) fail "Unsupported version ${MAJOR}. Only 14 (Sonoma), 15 (Sequoia), and 26 (Tahoe) are supported." ;;
esac

# --list-snapshots: banner + snapshots only (no summary)
if [[ "$LIST_SNAPSHOTS" == true ]]; then
  audit_environment "$OS_VER" "$BUILD_VER" "$MAJOR" "hide"
  list_snapshots_readonly_screen_only
  exit 0
fi

# --list-kdk: banner + KDK list only (no summary)
if [[ "$LIST_KDKS" == true ]]; then
  audit_environment "$OS_VER" "$BUILD_VER" "$MAJOR" "hide"
  list_kdks_readonly_screen_only
  exit 0
fi


# SIP guard: block ANY mutating action when SIP is enabled.
# Applies to: --mode wifi|audio|both, --rollback-stock, --boot-snapshot <UUID>
if sip_is_enabled; then
  if [[ "$DO_ROLLBACK" == true ]] || [[ -n "$BOOT_UUID" ]] || [[ -n "${MODE:-}" ]]; then
    local_action="(unknown)"
    if [[ "$DO_ROLLBACK" == true ]]; then
      local_action="rollback-stock"
    elif [[ -n "$BOOT_UUID" ]]; then
      local_action="boot-snapshot (UUID: ${BOOT_UUID})"
    else
      local_action="mode '${MODE}'"
    fi

    # Add a silent environment audit to the log (useful for support).
    audit_environment "$OS_VER" "$BUILD_VER" "$MAJOR" "hide"

    sip_abort_mutation_due_to_sip "$local_action"
  fi
fi



# FileVault guard: block ANY mutating action when FileVault is enabled.
# Applies to: --mode wifi|audio|both, --rollback-stock, --boot-snapshot <UUID>
if ! filevault_is_off; then
  if [[ "$DO_ROLLBACK" == true ]] || [[ -n "$BOOT_UUID" ]] || [[ -n "${MODE:-}" ]]; then
    local_action="(unknown)"
    if [[ "$DO_ROLLBACK" == true ]]; then
      local_action="rollback-stock"
    elif [[ -n "$BOOT_UUID" ]]; then
      local_action="boot-snapshot (UUID: ${BOOT_UUID})"
    else
      local_action="mode '${MODE}'"
    fi

    # Add a silent environment audit to the log (useful for support).
    audit_environment "$OS_VER" "$BUILD_VER" "$MAJOR" "hide"

    filevault_abort_mutation_due_to_filevault "$local_action"
  fi
fi

# Mutating flows
if [[ "$DO_ROLLBACK" == true ]]; then
  SUMMARY_MODE="rollback-stock"
  audit_environment "$OS_VER" "$BUILD_VER" "$MAJOR" "show"
  step "Mode: rollback-stock"
  list_snapshots_audit
  rollback_stock
  list_snapshots_audit
  SUMMARY_STATUS_SNAPSHOT="✅ rollback prepared (reboot)"

  if $LOG_ENABLED; then ok "Log saved to: ${LOG_FILE}"; fi
  print_summary
  prompt_reboot
  exit 0
fi

if [[ -n "$BOOT_UUID" ]]; then
  SUMMARY_MODE="boot-snapshot"
  audit_environment "$OS_VER" "$BUILD_VER" "$MAJOR" "show"
  step "Mode: boot-snapshot"
  list_snapshots_audit
  boot_snapshot_uuid "$BOOT_UUID"
  list_snapshots_audit
  SUMMARY_STATUS_SNAPSHOT="✅ boot snapshot set (reboot)"

  if $LOG_ENABLED; then ok "Log saved to: ${LOG_FILE}"; fi
  print_summary
  prompt_reboot
  exit 0
fi

case "${MODE}" in wifi|audio|both) ;; *) fail "--mode invalid: '${MODE}'";; esac
SUMMARY_MODE="${MODE}"

audit_environment "$OS_VER" "$BUILD_VER" "$MAJOR" "show"

info "Mode selected   : ${MODE}"
info "Verbose         : ${VERBOSE}"
info "Dry-run         : ${DRY_RUN}"

# Enforce: audio only on Tahoe
if [[ "$MODE" == "audio" || "$MODE" == "both" ]]; then
  if [[ "$MAJOR" != "26" ]]; then
    fail "Audio (AppleHDA) applies ONLY to Tahoe (major 26). Current OS: ${OS_VER} (major ${MAJOR}). Use --mode wifi."
  fi
fi

# Automatic KDK preflight/error for audio/both when KDK merge is required
if [[ "$MODE" == "audio" || "$MODE" == "both" ]]; then
  if [[ "$NO_KDK_MERGE" != true ]]; then
    if [[ -z "${KDK_PATH:-}" && "${KDK_AUTO}" != true ]]; then
      fail "Mode '${MODE}' requires a KDK to merge on Tahoe.\n\nUse one of these options:\n 1) --kdk-auto (recommended)\n 2) --kdk /path/to/Something.kdk\n\nOr, at your own risk:\n 3) --no-kdk-merge"
    fi
    if [[ "${KDK_AUTO}" == true ]]; then
      kdk_preflight_or_die
    fi
  fi
fi

WIFI_P="${ROOT_DIR}/payloads/wifi/${MAJOR}"
AUDIO_P="${ROOT_DIR}/payloads/audio/${MAJOR}"

SUMMARY_WIFI_PAYLOAD="$WIFI_P"
SUMMARY_AUDIO_PAYLOAD="$AUDIO_P"

info "WiFi payload : ${WIFI_P}"
info "Audio payload: ${AUDIO_P}"

# Validate payloads
if [[ "$MODE" == "wifi" || "$MODE" == "both" ]]; then
  check_wifi_payload "$WIFI_P" "$MAJOR"
  ok "WiFi payload OK"
fi
if [[ "$MODE" == "audio" || "$MODE" == "both" ]]; then
  [[ -d "$AUDIO_P" ]] || fail "No audio payload exists for Tahoe (26): expected at ${AUDIO_P}"
  check_audio_payload_tahoe "$AUDIO_P" "$MAJOR"
  ok "Audio payload OK"
fi

# Pre-check: avoid re-applying patches already present (hash match vs payload)
APPLY_WIFI=false
APPLY_AUDIO=false

if [[ "$MODE" == "wifi" || "$MODE" == "both" ]]; then
  if wifi_already_applied "$MAJOR"; then
    warn "Wi-Fi is already applied (hash matches payload). No action will be performed for Wi-Fi."
    SUMMARY_STATUS_WIFI="✅ already applied (skip)"
  else
    APPLY_WIFI=true
  fi
else
  SUMMARY_STATUS_WIFI="⚠️  not applied"
fi

if [[ "$MODE" == "audio" || "$MODE" == "both" ]]; then
  if audio_already_applied "$MAJOR"; then
    warn "Audio (AppleHDA) is already applied (hash matches payload). No action will be performed for Audio."
    SUMMARY_STATUS_AUDIO="✅ already applied (skip)"
    SUMMARY_KDK="(none)"
  else
    APPLY_AUDIO=true
  fi
else
  SUMMARY_STATUS_AUDIO="⚠️  not applied"
  SUMMARY_KDK="(none)"
fi

# If nothing to do, exit cleanly (avoid creating new snapshots)
if [[ "$APPLY_WIFI" == false && "$APPLY_AUDIO" == false ]]; then
  ok "Nothing to do: the requested patches are already applied."
  SUMMARY_STATUS_SNAPSHOT="⚠️  not created"
  print_summary
  exit 0
fi

# Tahoe special-case (WiFi-only):
# If Audio payload is already applied OR there are non-sealed snapshots (beyond the original sealed SSV),
# proceed with the WiFi patch BUT skip AuxKC to avoid side-effects on an already customized snapshot chain.
SKIP_AUXKC=false
SKIP_AUXKC_REASON=""

if [[ "$MAJOR" == "26" && "$MODE" == "wifi" && "$APPLY_WIFI" == true ]]; then
  if audio_already_applied "$MAJOR"; then
    SKIP_AUXKC=true
    SKIP_AUXKC_REASON+="audio payload detected; "
  fi

  if has_nonsealed_snapshots; then
    SKIP_AUXKC=true
    SKIP_AUXKC_REASON+="non-sealed snapshot(s) detected; "
  fi

  if [[ "$SKIP_AUXKC" == true ]]; then
    warn "Tahoe WiFi-only: AuxKC will be skipped (${SKIP_AUXKC_REASON% ;})."
  fi
fi


# Mount system RW
ROOTDEV="$(get_root_device)"
SYSDEV="$(strip_snapshot_suffix "$ROOTDEV")"
info "Root device  : ${ROOTDEV}"
info "System device: ${SYSDEV}"

# Snapshot audit BEFORE
list_snapshots_audit

mount_mnt1_rw "$SYSDEV"

# Apply WiFi
if [[ "$APPLY_WIFI" == true ]]; then
  copy_wifi_payload "$WIFI_P" "$MAJOR"
  SUMMARY_STATUS_WIFI="✅ applied"
elif [[ "$MODE" == "wifi" || "$MODE" == "both" ]]; then
  : # already applied; SUMMARY_STATUS_WIFI set in pre-check
else
  SUMMARY_STATUS_WIFI="⚠️  not applied"
fi

# Apply Audio
KDK_USED="(none)"
if [[ "$APPLY_AUDIO" == true ]]; then
  copy_audio_payload_tahoe "$AUDIO_P" "$MAJOR"
  SUMMARY_STATUS_AUDIO="✅ applied"

  if [[ "$NO_KDK_MERGE" == true ]]; then
    warn "You selected --no-kdk-merge. This may fail on Tahoe with newer builds."
    KDK_USED="(no-kdk-merge)"
  else
    if [[ -n "$KDK_PATH" ]]; then
      KDK_USED="$KDK_PATH"
    else
      KDK_USED="$(kdk_pick_auto)"
    fi
    info "Selected KDK: ${KDK_USED}"
    kdk_merge_sle "$KDK_USED"
  fi

  SUMMARY_KDK="$KDK_USED"
  run_kmutil_release
elif [[ "$MODE" == "audio" || "$MODE" == "both" ]]; then
  : # already applied; SUMMARY_STATUS_AUDIO set in pre-check
  SUMMARY_KDK="(none)"
else
  SUMMARY_STATUS_AUDIO="⚠️  not applied"
  SUMMARY_KDK="(none)"
fi

# If only WiFi is being applied, apply kmutil (AuxKC)
if [[ "$APPLY_AUDIO" == false ]]; then
  if [[ "$APPLY_WIFI" == true && ( "$MAJOR" == "14" || "$MAJOR" == "15" || "$MAJOR" == "26" ) ]]; then
    if [[ "$MAJOR" == "26" && "$MODE" == "wifi" && "$SKIP_AUXKC" == true ]]; then
      ok "Tahoe WiFi-only: skipping AuxKC (audio payload already present and/or non-sealed snapshots detected)."
    else
      run_kmutil_aux_modern_wireless
    fi
  else
    ok "Wi-Fi only: kmutil is not required."
  fi
fi

create_snapshot
SUMMARY_STATUS_SNAPSHOT="✅ created"

# Snapshot audit AFTER
list_snapshots_audit

ok "Completed"
if $LOG_ENABLED; then ok "Log saved to: ${LOG_FILE}"; fi

print_summary

if $DRY_RUN; then
  ok "Dry-run: no changes were made."
  exit 0
fi

prompt_reboot

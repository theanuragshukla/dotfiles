#!/usr/bin/env bash
# =============================================================================
# Dotfiles Installer — interactive symlink-based config installer
# Usage: bash install.sh [--dry-run]
# =============================================================================

set -uo pipefail
# NOTE: -e intentionally omitted — arithmetic (( n++ )) exits 1 when n==0

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'

# ── Config ────────────────────────────────────────────────────────────────────
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# ── Source → Destination mapping ─────────────────────────────────────────────
# source_name : path relative to this script's directory
# destination : absolute path where the symlink will be created
# Only entries whose source actually exists on disk will appear in the menu.
declare -A CONFIG_MAP=(
    ["nvim"]="$HOME/.config/nvim"
    ["tmux"]="$HOME/.config/tmux"
    ["fish"]="$HOME/.config/fish"
    ["i3"]="$HOME/.config/i3"
    ["i3status"]="$HOME/.config/i3status"
    ["alacritty"]="$HOME/.config/alacritty"
    ["kitty"]="$HOME/.config/kitty"
    ["rofi"]="$HOME/.config/rofi"
    ["dunst"]="$HOME/.config/dunst"
    ["polybar"]="$HOME/.config/polybar"
    ["starship.toml"]="$HOME/.config/starship.toml"
    ["zsh"]="$HOME/.config/zsh"
    [".zshrc"]="$HOME/.zshrc"
    [".bashrc"]="$HOME/.bashrc"
    [".bash_profile"]="$HOME/.bash_profile"
    [".profile"]="$HOME/.profile"
    [".gitconfig"]="$HOME/.gitconfig"
    [".gitignore_global"]="$HOME/.gitignore_global"
    [".inputrc"]="$HOME/.inputrc"
    [".tmux.conf"]="$HOME/.tmux.conf"
    [".vimrc"]="$HOME/.vimrc"
    ["vim"]="$HOME/.vim"
    ["ssh/config"]="$HOME/.ssh/config"
    ["scripts"]="$HOME/.local/bin/scripts"
    ["bin"]="$HOME/.local/bin/dotbin"
)

# ── TTY-safe read ─────────────────────────────────────────────────────────────
# Reads from /dev/tty when available (works even if stdout is piped).
# Falls back to normal stdin (e.g. CI / automated tests).
TTY_FD=0   # will be overridden to the /dev/tty fd if available
_open_tty() {
    if [[ -c /dev/tty ]]; then
        exec {TTY_FD}</dev/tty 2>/dev/null || TTY_FD=0
    else
        TTY_FD=0
    fi
}

# Reads one line from the terminal into global REPLY_INPUT.
# Avoids namerefs, which cannot reach into a caller's local scope in bash.
REPLY_INPUT=""
tty_read() {
    local prompt="$1"
    REPLY_INPUT=""
    IFS= read -r -u "$TTY_FD" -p "$prompt" REPLY_INPUT || true
}

# ── Helpers ───────────────────────────────────────────────────────────────────
print_header() {
    echo
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}║          Dotfiles Installer v1.0                 ║${RESET}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════╝${RESET}"
    echo -e "  ${DIM}Dotfiles dir : $DOTFILES_DIR${RESET}"
    if $DRY_RUN; then echo -e "  ${YELLOW}⚠  DRY-RUN mode — no changes will be made${RESET}"; fi
    echo
}

info() { echo -e "  ${CYAN}ℹ${RESET}  $*"; }
ok()   { echo -e "  ${GREEN}✔${RESET}  $*"; }
warn() { echo -e "  ${YELLOW}⚠${RESET}  $*"; }
err()  { echo -e "  ${RED}✖${RESET}  $*"; }

run() {
    if $DRY_RUN; then
        echo -e "    ${DIM}[dry-run] $*${RESET}"
    else
        eval "$@"
    fi
}

# ── Build sorted list of entries that exist on disk → global AVAILABLE ────────
build_available() {
    AVAILABLE=()
    for key in "${!CONFIG_MAP[@]}"; do
        [[ -e "$DOTFILES_DIR/$key" ]] && AVAILABLE+=("$key")
    done
    mapfile -t AVAILABLE < <(printf '%s\n' "${AVAILABLE[@]}" | sort)
}

# ── Coloured destination status ───────────────────────────────────────────────
dest_status_color() {
    local dest="$1"
    if   [[ -L "$dest" ]]; then echo -e "${YELLOW}symlink${RESET} → $(readlink "$dest")"
    elif [[ -d "$dest" ]]; then echo -e "${RED}directory${RESET}"
    elif [[ -f "$dest" ]]; then echo -e "${RED}file${RESET}"
    else                        echo -e "${GREEN}absent${RESET}"
    fi
}

# ── Print table (reads globals AVAILABLE + SELECTED) ─────────────────────────
print_table() {
    local idx=1
    printf '\n  %-4s %-5s %-24s %-30s %s\n' \
        "#" "Sel" "Source" "Destination" "Status"
    printf '  %-4s %-5s %-24s %-30s %s\n' \
        "──" "───" "────────────────────────" \
        "──────────────────────────────" "──────────────"
    for key in "${AVAILABLE[@]}"; do
        local dest="${CONFIG_MAP[$key]}"
        local status check=" "
        status="$(dest_status_color "$dest")"
        [[ "${SELECTED[$key]:-0}" == "1" ]] && check="${GREEN}✔${RESET}"
        printf "  %-4s [%b] %-24s %-30s %b\n" \
            "$idx" "$check" "$key" "$dest" "$status"
        (( idx++ )) || true
    done
    echo
}

# ── Interactive selection loop (reads/writes globals AVAILABLE + SELECTED) ────
interactive_select() {
    for key in "${AVAILABLE[@]}"; do SELECTED["$key"]="1"; done   # pre-select all

    local input
    while true; do
        clear
        print_header
        print_table

        echo -e "  ${BOLD}Commands:${RESET}"
        echo -e "    ${CYAN}[number]${RESET}   toggle on/off (e.g. 3)"
        echo -e "    ${CYAN}a${RESET}          select all"
        echo -e "    ${CYAN}n${RESET}          deselect all"
        echo -e "    ${CYAN}i${RESET}          invert selection"
        echo -e "    ${CYAN}Enter${RESET}      confirm and continue"
        echo -e "    ${CYAN}q${RESET}          quit"
        echo

        tty_read "  › "
        input="$REPLY_INPUT"

        case "$input" in
            q|Q) echo; exit 0 ;;
            a|A) for key in "${AVAILABLE[@]}"; do SELECTED["$key"]="1"; done ;;
            n|N) for key in "${AVAILABLE[@]}"; do SELECTED["$key"]="0"; done ;;
            i|I)
                for key in "${AVAILABLE[@]}"; do
                    [[ "${SELECTED[$key]:-0}" == "1" ]] \
                        && SELECTED["$key"]="0" || SELECTED["$key"]="1"
                done ;;
            "")
                local any=0
                for key in "${AVAILABLE[@]}"; do
                    [[ "${SELECTED[$key]:-0}" == "1" ]] && { any=1; break; }
                done
                if (( any )); then
                    break
                else
                    warn "Nothing selected — pick at least one entry."
                    sleep 1
                fi ;;
            *)
                if [[ "$input" =~ ^[0-9]+$ ]] \
                   && (( input >= 1 && input <= ${#AVAILABLE[@]} )); then
                    local k="${AVAILABLE[$((input - 1))]}"
                    [[ "${SELECTED[$k]:-0}" == "1" ]] \
                        && SELECTED["$k"]="0" || SELECTED["$k"]="1"
                else
                    warn "Unknown command: '$input'"; sleep 0.5
                fi ;;
        esac
    done
}

# ── Backup preference — writes global DO_BACKUP (never runs in a subshell) ───
ask_backup() {
    echo
    echo -e "  ${BOLD}Backup existing configs?${RESET}"
    echo -e "  ${DIM}Existing files/dirs at destinations will be moved to:${RESET}"
    echo -e "  ${DIM}$BACKUP_DIR${RESET}"
    echo
    echo -e "  ${CYAN}1)${RESET} Yes — backup, then symlink"
    echo -e "  ${CYAN}2)${RESET} No  — replace without backup"
    echo -e "  ${CYAN}q)${RESET} Quit"
    echo
    local choice
    while true; do
        tty_read "  › "
        choice="$REPLY_INPUT"
        case "$choice" in
            1) DO_BACKUP="yes"; return ;;
            2) DO_BACKUP="no";  return ;;
            q|Q) exit 0 ;;
            *) warn "Enter 1, 2 or q" ;;
        esac
    done
}

# ── Confirmation screen ───────────────────────────────────────────────────────
confirm_plan() {
    echo
    echo -e "  ${BOLD}Install plan${RESET}"
    echo -e "  ─────────────────────────────────────────────────────"
    for key in "${AVAILABLE[@]}"; do
        [[ "${SELECTED[$key]:-0}" == "1" ]] || continue
        echo -e "    ${GREEN}✔${RESET}  ${BOLD}$key${RESET}  ${DIM}→  ${CONFIG_MAP[$key]}${RESET}"
    done
    echo -e "  ─────────────────────────────────────────────────────"
    echo -e "  Backup : ${BOLD}$DO_BACKUP${RESET}"
    if $DRY_RUN; then echo -e "  ${YELLOW}DRY-RUN — no changes will be made${RESET}"; fi
    echo
    tty_read "  Proceed? [Y/n] › "
    local confirm="$REPLY_INPUT"
    # Enter (empty) or y/Y proceeds; anything else aborts
    if [[ -n "$confirm" && ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "  Aborted."; exit 0
    fi
}

# ── Install one entry ─────────────────────────────────────────────────────────
install_entry() {
    local key="$1"
    local src="$DOTFILES_DIR/$key"
    local dest="${CONFIG_MAP[$key]}"

    echo -e "\n  ${BOLD}$key${RESET}  ${DIM}→  $dest${RESET}"

    local parent
    parent="$(dirname "$dest")"
    if [[ ! -d "$parent" ]]; then
        info "Creating parent directory: $parent"
        run "mkdir -p '$parent'"
    fi

    if [[ -L "$dest" ]]; then
        local existing_target
        existing_target="$(readlink "$dest")"
        if [[ "$existing_target" == "$src" ]]; then
            ok "Already linked correctly — skipping"; return 0
        fi
        warn "Existing symlink points elsewhere ($existing_target)"
        if [[ "$DO_BACKUP" == "yes" ]]; then
            run "mkdir -p '$BACKUP_DIR' && mv '$dest' '$BACKUP_DIR/'"
            info "Backed up"
        else
            run "rm '$dest'"
        fi
    elif [[ -e "$dest" ]]; then
        warn "Existing $( [[ -d "$dest" ]] && echo "directory" || echo "file" ) at $dest"
        if [[ "$DO_BACKUP" == "yes" ]]; then
            run "mkdir -p '$BACKUP_DIR' && mv '$dest' '$BACKUP_DIR/'"
            info "Backed up"
        else
            run "rm -rf '$dest'"
        fi
    fi

    run "ln -s '$src' '$dest'"
    ok "Linked: $dest  →  $src"
    return 0
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    _open_tty                  # set up TTY_FD once, up front

    declare -ga AVAILABLE      # global sorted list of present dotfile names
    declare -gA SELECTED       # global assoc: name → "1" | "0"
    DO_BACKUP="yes"            # global written by ask_backup()

    build_available

    if (( ${#AVAILABLE[@]} == 0 )); then
        print_header
        err "No recognised dotfiles found in: $DOTFILES_DIR"
        echo -e "  ${DIM}Add entries to CONFIG_MAP in this script to extend the mapping.${RESET}"
        exit 1
    fi

    interactive_select          # 1. pick entries

    clear; print_header
    ask_backup                  # 2. backup preference  →  $DO_BACKUP

    clear; print_header
    confirm_plan                # 3. show plan + confirm

    echo
    echo -e "  ${BOLD}Installing…${RESET}"
    local ok_count=0 skip_count=0

    for key in "${AVAILABLE[@]}"; do
        [[ "${SELECTED[$key]:-0}" == "1" ]] || continue
        if install_entry "$key"; then
            ok_count=$(( ok_count + 1 ))
        else
            skip_count=$(( skip_count + 1 ))
        fi
    done

    echo
    echo -e "  ${BOLD}${GREEN}Done!${RESET}  $ok_count linked, $skip_count skipped"
    if [[ "$DO_BACKUP" == "yes" ]] && [[ -d "$BACKUP_DIR" ]]; then
        echo -e "  ${DIM}Backups saved to: $BACKUP_DIR${RESET}"
    fi
    echo
}

main

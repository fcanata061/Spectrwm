#!/bin/bash

# Separador Powerline
SEP=""

# Escolha do tema:
# Opções: nord | dracula | gruvbox | solarized-dark | solarized-light
THEME="solarized-dark"

# ====== Paletas ======
set_theme() {
    case "$THEME" in
        nord)
            C_BASE=0       # preto
            C_FG=7         # branco
            C_CPU_BG=6     # azul claro
            C_MEM_BG=4     # azul escuro
            C_NET_BG=5     # magenta
            C_DATE_BG=2    # verde
            ;;
        dracula)
            C_BASE=0
            C_FG=7
            C_CPU_BG=5     # roxo
            C_MEM_BG=1     # vermelho
            C_NET_BG=4     # azul
            C_DATE_BG=6    # cyan
            ;;
        gruvbox)
            C_BASE=0
            C_FG=7
            C_CPU_BG=3     # amarelo
            C_MEM_BG=2     # verde
            C_NET_BG=4     # azul
            C_DATE_BG=1    # vermelho
            ;;
        solarized-dark)
            C_BASE=0       # preto
            C_FG=7         # branco
            C_CPU_BG=4     # azul
            C_MEM_BG=2     # verde
            C_NET_BG=3     # amarelo
            C_DATE_BG=6    # cyan
            ;;
        solarized-light)
            C_BASE=7       # fundo claro
            C_FG=0         # texto escuro
            C_CPU_BG=6     # cyan
            C_MEM_BG=2     # verde
            C_NET_BG=4     # azul
            C_DATE_BG=1    # vermelho
            ;;
        *)
            echo "Tema inválido, usando padrão (dracula)" >&2
            THEME="dracula"
            set_theme
            ;;
    esac
}

set_theme

# ====== Funções de status ======
cpu() {
    usage=$(grep 'cpu ' /proc/stat | awk '{u=($2+$4)*100/($2+$4+$5)} END {printf "%.1f",u}')
    echo " ${usage}%"
}

mem() {
    free_mem=$(free -m | awk '/Mem:/ { printf("%d/%dMB", $3, $2) }')
    echo " $free_mem"
}

net() {
    dev=$(ip route | awk '/^default/ {print $5; exit}')
    if [ -n "$dev" ]; then
        ip=$(ip addr show "$dev" | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
        echo " $dev:$ip"
    else
        echo " Offline"
    fi
}

clock() {
    date '+ %d/%m/%Y  %H:%M'
}

# ====== Helpers ======
fg() { tput setaf $1; }
bg() { tput setab $1; }
reset() { tput sgr0; }

block() {
    local bgcol=$1
    local text=$2
    local nextbg=$3

    echo -n "$(bg $bgcol)$(fg $C_FG) $text "

    if [ -n "$nextbg" ]; then
        echo -n "$(bg $nextbg)$(fg $bgcol)$SEP"
    else
        echo -n "$(bg $C_BASE)$(fg $bgcol)$SEP"
    fi
}

# ====== Loop ======
while true; do
    out=""
    out+="$(block $C_CPU_BG "$(cpu)" $C_MEM_BG)"
    out+="$(block $C_MEM_BG "$(mem)" $C_NET_BG)"
    out+="$(block $C_NET_BG "$(net)" $C_DATE_BG)"
    out+="$(block $C_DATE_BG "$(clock)")"
    out+="$(reset)"
    echo -e "$out"
    sleep 2
done

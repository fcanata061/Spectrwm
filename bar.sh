#!/bin/bash

# Ícones Powerline (Necessário Nerd Fonts ou Powerline fonts)
SEP_LEFT=""
SEP_RIGHT=""

# Cores ANSI simples (pode ajustar conforme paleta)
RESET="\033[0m"
BOLD="\033[1m"

# Função CPU
cpu() {
    usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
    printf " %.1f%%" "$usage"
}

# Função Memória
mem() {
    free_mem=$(free -m | awk '/Mem:/ { printf("%d/%dMB", $3, $2) }')
    echo " $free_mem"
}

# Função Internet (verifica interface ativa)
net() {
    dev=$(ip route | grep '^default' | awk '{print $5}')
    if [ -n "$dev" ]; then
        ip=$(ip addr show "$dev" | awk '/inet / {print $2}' | cut -d/ -f1)
        echo " $dev:$ip"
    else
        echo " Offline"
    fi
}

# Função Data/Hora
clock() {
    date '+ %d/%m/%Y  %H:%M'
}

while true; do
    echo -e "$(cpu) | $(mem) | $(net) | $(clock)"
    sleep 2
done

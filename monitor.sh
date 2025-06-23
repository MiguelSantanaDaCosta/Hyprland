#!/bin/bash

# Função para barra de progresso
progress_bar() {
    local value=$1
    local max=$2
    local size=20
    local percent=$((value * 100 / max))
    local filled=$((value * size / max))
    local empty=$((size - filled))
    
    printf "["
    for ((i=0; i<filled; i++)); do printf "▓"; done
    for ((i=0; i<empty; i++)); do printf " "; done
    printf "] %3d°C" "$value"
}

# Obter dados
CPU_TEMP=$(sensors | grep 'Package id 0:' | awk '{print $4}' | sed "s/+//;s/°C//")
MAX_TEMP=100

# Exibir
echo -e "\033[1;34m┌──────────────────────────────┐"
echo -e "│  \033[1;33m🖥️  MONITORAMENTO DO SISTEMA \033[1;34m│"
echo -e "├──────────────────────────────┤"
echo -e "│ \033[0;32mCPU Temperature:\033[0m $(progress_bar $CPU_TEMP $MAX_TEMP) \033[1;34m│"
echo -e "└──────────────────────────────┘\033[0m"

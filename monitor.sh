#!/usr/bin/env bash

# Verifica se sensors está instalado
if ! command -v sensors &> /dev/null; then
    echo -e "\033[1;31mErro: pacote 'lm_sensors' não está instalado.\033[0m"
    echo "Instale com: sudo pacman -S lm_sensors"
    echo "Depois execute: sudo sensors-detect"
    exit 1
fi

# Cores (ANSI)
NC='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'

# Função para colorir temperaturas
colorize_temp() {
    local temp=$(echo "$1" | grep -oP '[+-]?\d+\.?\d*')
    if (( $(echo "$temp > 80" | bc -l 2>/dev/null) )); then
        echo -e "${RED}$1${NC}"
    elif (( $(echo "$temp > 60" | bc -l 2>/dev/null) )); then
        echo -e "${YELLOW}$1${NC}"
    else
        echo -e "${GREEN}$1${NC}"
    fi
}

# Processador de saída
process_output() {
    while IFS= read -r line; do
        # Pular linhas de adaptador e vazias
        [[ $line =~ Adapter: ]] && continue
        [[ -z $line ]] && continue

        # Colorir cabeçalhos
        if [[ $line =~ ^[[:alpha:]] && $line =~ :$ ]]; then
            echo -e "${PURPLE}${line}${NC}"
            continue
        fi

        # Processar diferentes padrões
        case "$line" in
            *RPM*)
                echo "$line" | sed -E "s/([0-9]+ RPM)/${BLUE}\1${NC}/" ;;
            *V|*mV*)
                echo "$line" | sed -E "s/([0-9]+\.[0-9]+ [Vm]V)/${YELLOW}\1${NC}/" ;;
            *W*)
                echo "$line" | sed -E "s/([0-9]+\.[0-9]+ W)/${PURPLE}\1${NC}/" ;;
            *MHz*|*GHz*)
                echo "$line" | sed -E "s/([0-9]+ [MG]Hz)/${GREEN}\1${NC}/" ;;
            *°C*)
                # Processa cada temperatura na linha
                temp_line="$line"
                while read -r temp; do
                    colored_temp=$(colorize_temp "$temp")
                    temp_line=$(echo "$temp_line" | sed "s|${temp}|${colored_temp}|")
                done < <(echo "$line" | grep -oP '[+-]?\d+\.?\d*°C')
                echo -e "$temp_line" ;;
            *)
                echo "$line" ;;
        esac
    done
}

# Cabeçalho estilizado
echo -e "${BLUE}┌──────────────────────────────────────────────────────┐"
echo -e "│   ${YELLOW}  MONITOR DE SENSORES - ARCH LINUX ${BLUE}       │"
echo -e "├──────────────────────────────────────────────────────┤"

# Obter e processar dados
sensors -A | process_output | while IFS= read -r line; do
    # Calcular padding corretamente (remover códigos de cor)
    clean_line=$(echo -e "$line" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g')
    line_length=${#clean_line}
    padding=$((58 - line_length))
    [ $padding -lt 0 ] && padding=0
    printf "│  %s%*s│\n" "$line" $padding ""
done

# Rodapé
echo -e "└──────────────────────────────────────────────────────┘${NC}"

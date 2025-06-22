#!/usr/bin/env bash

# Configurações ajustáveis
WAYBAR_HEIGHT=36        # Altura da sua Waybar (ajuste no seu config.json)
HOVER_AREA=50           # Área sensível no topo (em pixels)
REFRESH_RATE=0.1        # Tempo de verificação (segundos)
WAYBAR_CMD="waybar"     # Comando para iniciar a Waybar

# Verifica dependências essenciais
if ! command -v hyprctl &> /dev/null; then
    echo "Erro: hyprctl não encontrado!"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Erro: jq não instalado. Instale com: sudo pacman -S jq (Arch) ou sudo apt install jq (Debian)"
    exit 1
fi

# Função para mostrar/esconder a Waybar
function toggle_waybar {
    local cursor_y=$(hyprctl cursorpos -j | jq '.y')
    
    if (( $(echo "$cursor_y <= $HOVER_AREA" | bc -l) )); then
        if ! pgrep -x "waybar" > /dev/null; then
            $WAYBAR_CMD &
        fi
    else
        if pgrep -x "waybar" > /dev/null; then
            pkill -x "waybar"
        fi
    fi
}

# Loop principal com tratamento de erro
while true; do
    if ! toggle_waybar; then
        echo "Erro na execução, tentando novamente em 1 segundo..."
        sleep 1
    fi
    sleep $REFRESH_RATE
done

#!/usr/bin/env bash
# ./master.sh
# Script para ser rodado como Root no WSL 
# Permanece inalterado
# Aqui removi a solicitação e adicionei a variável exportada

SCRIPT_DIR="./base-config"

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "É executado apenas como root aqui..."
        exit 1
    fi
}

run_root_script() {
    echo "Rodando root.sh como root..."
    bash "$SCRIPT_DIR/root.sh"
}

# Função para rodar o script user.sh
run_user_script() {
    echo "Rodando user.sh..."
    su - "$1" -c "bash $SCRIPT_DIR/user.sh"
}

check_root  
run_root_script 

echo "Root finalizado. Agora irei configurar o ambiente do user..."

# Aqui removi a solicitação e uso a variável exportada
run_user_script "$user_name"

# Remove a variável user_name após rodar
unset user_name

echo "Configuração geral concluída!"
    
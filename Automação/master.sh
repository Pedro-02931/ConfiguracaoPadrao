#!/usr/bin/env bash
# ./master.sh
# Script para ser rodado como Root no WSL 
# Permanece inalterado
# Aqui removi a solicitação e adicionei a variável exportada

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Este script deve ser executado como root."
        exit 1
    fi
}

run_root_script() {
    echo "Baixando e rodando root.sh como root..."
    curl -sSL "https://raw.githubusercontent.com/Pedro-02931/ConfiguracaoPadrao/refs/heads/main/Automa%C3%A7%C3%A3o/.base-config/root.sh" -o /tmp/root.sh
    chmod +x /tmp/root.sh
    bash /tmp/root.sh
}

# Função para rodar o script user.sh
run_user_script() {
    echo "Baixando e rodando user.sh..."
    curl -sSL "https://raw.githubusercontent.com/Pedro-02931/ConfiguracaoPadrao/refs/heads/main/Automa%C3%A7%C3%A3o/.base-config/user.sh" -o /tmp/user.sh
    chmod +x /tmp/user.sh
    su - "$1" -c "bash /tmp/user.sh"
}

check_root  
run_root_script 

echo "Root finalizado. Agora irei configurar o ambiente do user..."

# Aqui removi a solicitação e uso a variável exportada
if [[ -z "$user_name" ]]; then
    echo "Variável 'user_name' não está definida. Por favor, exporte o valor antes de executar este script."
    exit 1
fi

run_user_script "$user_name"

# Remove a variável user_name após rodar
unset user_name

echo "Configuração geral concluída!"

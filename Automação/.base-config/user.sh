#!/usr/bin/env bash
# ./.base-config/user.sh

UserConfig() {

    local VAR_NAME="USER_CONFIGURED"
    
    if [[ -n "${!VAR_NAME}" ]]; then
        echo "Já configurado para este usuário, caralho."
        return 0
    fi
    
    # Podemos compilar e instalar do AUR, pois o Arch odeia root nessas horas.*
    
    # 1. Compila e instala o yay (AUR helper)
    cd /tmp/yay-git && makepkg -si --noconfirm
    
    # 2. Usa o yay pra instalar temas e outras coisas que vivem na AUR
    yay -S --noconfirm \
       zsh zsh-theme-powerlevel10k-git asdf-vm
    
    # 3. Ajusta o .zshrc
    # Remove aspas e duplicações. 
    # Cria aliases distintos pra exa e bat.
    {
      echo "source \$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
      echo "source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme"
      echo "export PATH=\$HOME/.cargo/bin:\$HOME/.local/bin:\$PATH"
      echo "alias ls='exa --icons'"
      echo "alias cat='bat --style=auto'"
      echo "source /opt/asdf-vm/asdf.sh"
    } >> "$HOME/.zshrc"
    
    # Marca a variável pra não repetir, velho
    export USER_CONFIGURED=true
    
    echo "Configurações de usuário concluídas com sucesso! (Executadas como user normal)."
    
    echo "SUCCESS:UserPack; WARN:SudoAvoided; INFO:YayAUR+ASDF+AliasesOK"
}

# Executa a função
UserConfig

#!/usr/bin/env bash
# ./.base-config/root.sh
# Permanece inalterável
# Adicionei essa linha apenas, para mandar ao bash acima. Quero que todas as variáveis sejam permanentes no sistema, incluindo a de verificação. Só quero que remova o user_name após rodar o master.sh

RootUser() {
    local VAR_NAME="Root_CONFIGURED"
    echo "Senha root:"
    passwd

    # Cria o grupo e configura permissões sudo
    read -p "Grupo: " group_name
    groupadd "$group_name"
    echo "%$group_name ALL=(ALL) ALL" > /etc/sudoers.d/"$group_name"

    # Cria o usuário e adiciona ao grupo
    read -p "Nome do usuário a ser criado: " user_name
    useradd -m -G "$group_name" -s /bin/bash "$user_name"
    echo "Defina a senha para o usuário $user_name:"
    passwd "$user_name"
    echo "Usuário e grupo configurados com sucesso"
    
    # Exporta as variáveis corretamente
    export Root_CONFIGURED=true
    export user_name
}

SOconfig() {
    local FILE="/etc/pacman.conf"
    local VAR_NAME="PARALLEL_DOWNLOADS_CONFIGURADO" # Variável de verificação

    # Verifica se já foi feito, pra debug
    if [[ -n ${!VAR_NAME} ]]; então
        echo "Já feito!"
        return
    fi

    # Verifica se a linha já está criada
    if grep -q "^ParallelDownloads" "$FILE"; então
        read -p "Deseja mudar? " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; então
            read -p "Quantos downloads paralelos? " num
            sed -i "s/^ParallelDownloads.*/ParallelDownloads = $num/" "$FILE"
            echo "ParallelDownloads atualizado para $num"
        else
            echo "Nada feito."
        fi
    else
        # Adiciona a linha se não existir
        read -p "Quantos downloads paralelos? " num
        echo "ParallelDownloads = $num" >> "$FILE"
        echo "ParallelDownloads setado pra $num em $FILE."
    fi

    # Cria a variável de teste
    export PARALLEL_DOWNLOADS_CONFIGURADO=true

    # Cria as chaves, atualiza o banco de dados e as dependências
    echo "Inicializando chaves do pacman e atualizando o sistema..."
    pacman-key --init
    pacman-key --populate archlinux
    pacman -Sy archlinux-keyring
    pacman -Syyuu --noconfirm
}

DevSystemConfig() {

    local VAR_NAME="Dev_INSTALLED"
    
    # Verifica se já foi rodado pra evitar loop infinito de sinapses, porra
    if [[ -n "${!VAR_NAME}" ]]; then
        echo "Já realizado. Nada a fazer, mano."
        return 0
    fi
    
    # O Arch é paranóico, não permite que você faça certas builds como root.
    # Por isso, primeiro instalo o básico e configuro o núcleo do sistema como root.*
    
    pacman -S --noconfirm \
      git base-devel cargo neovim \
      yarn npm python python-pip go \
      docker
    
    cargo install bat exa
    
    # 3. Cria diretório para plugins do zsh no /usr/share.
    mkdir -p /usr/share/.zsh
    
    # 4. Instala lunarvim (Editor configurado)
    bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) --noconfirm
    
    # 5. Clona o repositório de auto-sugestões do zsh (autossugestões)
    git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/.zsh/zsh-autosuggestions
    
    # 6. Prepara para instalar “yay” via AUR
    cd /tmp/ && git clone https://aur.archlinux.org/yay-git.git
    chown -R "$user_name":"$user_name" /tmp/yay-git  # Ajusta dono pro usuario, pra compilar fora do modo root
    
    # 7. Compila e instala o yay
    cd /tmp/yay-git
    sudo -u "$user_name" makepkg -si --noconfirm
    
    # 8. Define shell padrão como zsh (permanência do estado “zsh” no cérebro do sistema)
    chsh -s /usr/bin/zsh "$user_name"
    
    # Cria a variável de teste pra evitar reexecução
    export Dev_INSTALLED=true
    
    echo "Configurações de sistema concluídas com sucesso! (Executadas como root)."
    echo "SUCCESS:SystemPack; WARN:NoRootBuild; INFO:LunarVim+ZshReady"
}

RootUser
SOconfig
DevSystemConfig

# Configuração Arch - Backup e Dump mental

O Objetivo desse projeto é funcionar como um caderno em que crio funções e modelos de SO's que gosto de configurar. No caso, o meu padrão é Arch, mais especificamente pelo Pacman e o AUR. ~~Bom, a prova cabal do meu autismo é ver o meu computador como extenção do meu cerebro~~.

## Por que Arch?

Pacman, assim como Apt ou DNF é um gerenciador e instalador de pacotes. E os repositórios do Arch costumam ter mais pacotes do que os equivalente de Ubuntu ou Fedora ~~dado que é mais voltado para pessoas mais fodidas da cabeça~~. E o que não tem, não precisamos fazer toda a burocracia de procurar um repositório de terceiros, instalar chaves e bla bla como fizemos no caso do Docker. A comunidade mantém um repositório de usuários que é o AUR. A gente pode baixar um script de lá, que serve pra construir um pacote do zero e usamos pacman pra instalar. 

No caso, esse repositório é mais voltado para o Arch já configurado, incluindo com a partição boot criada. 

## Configuração windows

A primeira coisa que se faz ao instalar o Windows é rodar um script de debloating, que desabilita inutilidades como telemetria que consome recursos para empacontamento de dados e envio para servidores da microsoft, por exemplo ~~(e pelo amor de Deus, desabilita a porra da cortana!!! Essa porra serve para nada, como se fosse um crypto miner escondidinho na guia anonima~~).

O Windows por padrão vem cheio de entulho, principalmente com~~ a porra~~ da Cortana, que é um keylogger disfarçado~~(Tenho um ódio especial por isso, já que essa porra é tão safada que pode atuar como um backdoor pronto para capturar até minha voz)~~ 

Um dos mais conhecidos é o [LeDragoX](https://github.com/LeDragoX/Win-Debloat-Tools). Basta rodar o PowerShell como admin seguindo as instruções.

### Instalação

Dado que eu sou tão preguiçoso que prefiro trabalhar do que fazer faculdade, decidi usar o próprio [ArchWSL](https://wsldl-pg.github.io/ArchW-docs/How-to-Setup/).

No caso, primeiro instale o WSL2 pelo PowerShell, dado que é bem mais prático do que configurar dualboot. ~~Mano, tmnc, um saco ter que configurar manualmente a chave de fuso ao alternar de SO, fora o trabaçho de alocação de partição quando vc é obrigado a usar um computador fodido, mas fazer o que, quando quero algo, faço com 0, isso se chama talento nato~.~~

```ps1
wsl --install
```

Agora dentro do diretório que você extraiu os arquivos do [ArchWSL](https://wsldl-pg.github.io/ArchW-docs/How-to-Setup/)(Um executavel que configura o kernel e boot do arch e um hd virtual com os arquivos de SO), execute a lista de comandos na pagina do hyperlink.

Bom, fiz aqui o meu equivalente a um 'Hello World!'

### Porque o WSL2 ao invés de dualboot?
Bom, é que é basicamente como se o computador tivesse dupla personalidade, onde posso chamar um sem ter que mudar de ambiente, além disso é um ~~fio terra surpresa~~ saco ter que ficar editando tabelas de partição, ainda mais quando você roda modelos de linguagem num microondas com teclado embutido.

Tecnicamente, o WSL2 funciona como um kernel do Linux completo rodando em cima de uma maquina virtual leve baseada no Hyper-V, como se fosse o Venom no Eddie, em que um é o parasita(Eddie) e o outro é o sistema nervoso principal(Venom). Através dessa camada, é possível fazer syscalls, ler e gravar arquivos, compilar pacotes, gerenciar processos, tudo isso enquanto o Windows roda principal.

Bom, dado que ele é rodado em um VHD, a parte de tabela de disco é automatizada.

## Configuração inicial - Porque o ArchWSL
Bom, é um projeto open-source já que a microsoft não oferece suporte oficial, mas dado que ~~sou fodido da cabeça~~ o pacman, o AUR e toda aquela vibe de rodar PKGBUILDs para compilar pacote do zero, acaba valendo o esforço, fora que o executavel é inteligente o suficiente ara fazer a parte chata de instalar os bin basico do arch e montar o ponto de boot.

Bom, configurando a estrutura do Arch, a execução de chamadas de sistemas ode ser feita através do kernel WSL. Essa ponte permite que o ArchWSL faça queries pro hardware e interaja com as syscalls sem sair do ecossistema Windows.

Aqui o diagrama para melhor compreenção:
```mermaid
classDiagram
    direction LR
    class Windows {
        <<System>>
        + Kernel32.dll()
        + ntdll.dll()
        + Sysmon()
        + EventViewer()
    }

    class WSL {
        <<VirtualizationLayer>>
        + init(kernel: string, distro: string)
        + executeSyscall(call: string): string
        + mountDrive(driveLetter: string, path: string): boolean
        + listProcesses(): string[]
        + fetchEventLogs(): string[]
    }

    class Arch {
        <<DistroInstance>>
        + init(username: string, hostname: string, packages: list)
        + installPackage(package: string): boolean
        + executeCommand(command: string): string
        + configureService(service: string, state: string): boolean
        + buildFromAUR(pkgbuild: string): string
    }

    class SyscallLayer {
        <<InteractionLayer>>
        + mapSyscalls(winCall: string): string
        + handleFileAccess(path: string, mode: string): string
        + logSyscallEvents(): string
    }

    class VirtualDisk {
        <<StorageLayer>>
        + allocateSpace(size: string): boolean
        + writeData(offset: int, data: string): boolean
        + readData(offset: int, length: int): string
        + encryptVolume(key: string): boolean
        + decryptVolume(key: string): boolean
    }

    Windows --|> WSL : "Manages virtualization"
    WSL --> SyscallLayer : "Syscall proxying"
    WSL --> VirtualDisk : "Manages VHD"
    Arch --|> WSL : "Runs inside"
    SyscallLayer --> Windows : "Maps syscalls"
    SyscallLayer --> Arch : "Translates to Linux"
    VirtualDisk --> Windows : "Exposes via Hyper-V"

    class Monitoring {
        <<EventTracing>>
        + monitorFileAccess()
        + logEventSource()
        + trackSyscallActivity()
        + reportTelemetry()
    }

    Windows --> Monitoring : "Feeds data"
    Monitoring --> WSL : "Tracks actions"
    Monitoring --> VirtualDisk : "Logs access"
```

### Configuração de Downloads

Decidi criar uma função que interage comigo perguntando o numero de downloads paralelos pelo conceito de trade/off. Digo, dado que a parte de empacotamento é feita seguindo um conjunto de instruções simples, e protocolos esecificos, a muito o uso de processador para a execução de downloads e o consumo de banda, então se ~~vc tiver dois neuronios funcionais e não morando na rua~~ você tiver um processador minimamente bom, uma placa de rede comum e uma banda, pode ser util aumentar os downloads paralelos.

Se eu tiver num computador da Positivo é ~~pq mano, cometi um crime terrivel na minha reencarnação passada~~ é melhor pensar num numero menor de downloads paralelos. E a largura de banda também conta.

Basicamente aqui pedi para verificar se a configuração de downloads paralelos está no padrão, dado que em default seria 5, dado o minimalismo do Arch, então dado que se tem tela, roda Doom, compensa deixar um numero maior de downloads paralelos.

Mas em resumo:
-Mais sockets pode melhorar a experiência, porém:
-- Filas de I/O impactando no agendamento de CPU e alocação de memória;
-- Consumo de banda, onde a placa de rede acaba processando simultaneamente cada conexão paralela;

Se a CPU e a memória derem conta, mas a banda for pequena, apenas sobrecarrega a rede. Se a banda for grande e o hardware aguentar, pode ir tranquilo.

```mermaid
flowchart LR
    Shell -->|"Executa script, edita pacman.conf e chama comandos de atualização"| Kernel
    Kernel -->|"Gerencia conexões, processos e memória para downloads paralelos"| Hardware
    Hardware -->|"Transmite e recebe dados pela rede conforme capacidade física" | Roteador
    Roteador --> |"Envia pacotes do servidores para a memoria, executando instruções" | Hardware
    Hardware -->|"Instala pacotes baixados e executa binários" | Kernel
```

```shell
SOconfig() {
    local FILE="/etc/pacman.conf"
    local VAR_NAME="PARALLEL_DOWNLOADS_CONFIGURADO" # Variavel de verificação

    # Verifica se já foi feito, pra debug
    if [[ -n ${!VAR_NAME} ]]; then
        echo "Já feito"
        return
    fi

    # Verifica se a linha já está criada
    if grep -q "^ParallelDownloads" "$FILE"; then
        read -p "Deseja mudar? " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            read -p "Quantos? " num
            sed -i "s/^ParallelDownloads.*/ParallelDownloads = $num/" "$FILE"
            echo "Feito"
        else
            echo "Nada feito"
        fi
    else
        # Adiciona a linha se não existir
        read -p "Quantos? " num
        echo "ParallelDownloads = $num" >> "$FILE"
        echo "ParallelDownloads set to $num in $FILE."
    fi

    # Cria a variavel de teste
    export $VAR_NAME=true

    # Cria as chaves, e atualiza o banco de dados, e atualiza as dependencias
    echo "Initializing pacman keys and updating the system..."
    pacman-key --init
    pacman-key --populate archlinux
    pacman -Sy archlinux-keyring
    pacman -Syyuu --noconfirm
}
SOconfig
```








## Configuração de modelo Ollama
Aqui decidi rodar um modelo basico de 3b de parametros sem censura e totalmente offline como assistente de configuração. Dado que o modelo é pequeno, a demora para processamento e resposta acaba sendo vantajoso.

Aqui basicamente estou usando o ```curl``` para interceptar o syscall para a rede (o **install.sh**), que gerencia, aloca e otimiza o meu sistema para o uso do Ollama, configurando o processado, RAM e o disco para carregar o modelo.

Bom, dado que sou um pobre fodido e não tenho uma GPU RTX, acaba que todos os calculos pesados de multiplicação de matrizes são feitas na minha CPU, e sim, quero extrair o maximo atráves de páginas de memoria e intruções especificas.

### Funcionamento

O Funcionamento é bem simples:
- O Ollama roda um binário que carrega o LLM (3B de parâmetros);
- É feito um parsing local com os prompts, e calculado a proxima palavra com base no treino;
- O modelo fica em disco, porém ao executar o Ollama, são puxados para a RAM pelo kernel e aguarda os prompts;

```shell
OllamaConfig() {
    local VAR_NAME="OLLAMA_INSTALED" # Variavel de verificação

    # Verifica se já foi feito, pra debug
    if [[ -n ${!VAR_NAME} ]]; then
        echo "Já feito"
        return
    else
        curl -fsSL https://ollama.com/install.sh | sh
https://ollama.com/artifish/llama3.2-uncensored
    fi

    # Cria a variavel de teste
    export $VAR_NAME=true
}
OllamaConfig
```

## Configurando ferramentas de desenvolvedor,
Aqui estou basicamente instalando todas as ferramentas de desenvolvimento que uso:
- **Git** para versionamento;
- **base-devel** para compilar códigos;
- **cargo** para projetos em Rust;
- **neovim** para edição de texto e complemento com o LunarVim;
- **Lunar** para edição gráfica
- **yay** para pacotes arch
- **yarn** para gerenciar pacotes js;
- **npm** para o gerenciamento de pacotes padrão do Node.js;
- **exa** para listagem
- **bat** porque gostei do nome;
- **zsh** Para algumas funcionalidades interessantes;
Além disso, adiciono diretamente a linha ```echo "export PATH=~/.cargo/bin:~/.local/bin:~/.local/bin:$PATH" >> .zshrc``` no kernel para mapear os binarios para o shell.
```shell
Dev() {
    local VAR_NAME="Dev_INSTALED" # Variavel de verificação

    # Verifica se já foi feito, pra debug
    if [[ -n ${!VAR_NAME} ]]; then
        echo "Já feito"
        return
    else
        # Compiladores, versionador, funções e editor
        pacman -S git base-devel cargo neovim yarn npm python python-pip go --noconfirm
        cargo install bat exa
        mkdir $HOME/.zsh
        bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) --noconfirm # instala o Lunar para Edição com 
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions  
        # Yay
        cd /tmp/ && git clone https://aur.archlinux.org/yay-git.git
        sudo chown -R $USER:$USER ./yay-git 


        # Configuração de temas e LO
        yay -S  zsh zsh-theme-powerlevel10k-git asdf-vm docker --noconfirm
        chsh -s /usr/bin/zsh

        # Configuração dos transformers para lidar com erro.
        pip install --upgrade pip transformers torch 

        # Paths
        echo 'source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh' >> .zshrc
        echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
        echo "export PATH=~/.cargo/bin:~/.local/bin:~/.local/bin:$PATH" >> .zshrc  
        echo 'alias ls="exa --icons"' >> .zshrc 
        echo 'alias ls="bat --style=auto"' >> .zshrc 
        echo 'export PATH=/home/pmota/.cargo/bin:$PATH' >> .zshrc
        echo 'source /opt/asdf-vm/asdf.sh"' >> .zshrc 
    fi

    # Cria a variavel de teste
    export $VAR_NAME=true
}
Dev
```
```mermaid
flowchart LR
    Shell -->|"Executa o pacman para criar a requisição"| Kernel
    Kernel -->|"Analisa dependencias, permissões e processa o pacote de upload"| Hardware
    Hardware -->|"Transmite e recebe dados pela rede conforme capacidade física" | Roteador
    Roteador --> |"Envia pacotes do servidores para a memoria, executando instruções" | Hardware
    Hardware -->|"Instala pacotes baixados e executa binários" | Kernel
    Kernel -->|"Acessa e grava o .zshrc" | Shell
```



# Pelo que eu entendi, o docker no WSL é para rodar aplicações graficas no windoww, mas não entendi o funcionamento direito, tipo, ele roda um servidor que serve como uma rede neural, traduzindo os dados mandados pelo arch para algo util no windows que podemos interagir? ele aumenta o desempenho? explique a nivel de hardware, kernel e shell


## ```Powerchell rode wmic diskdrive list brief``` para listar o id do dispositivo e de ```wsl --mount \\.\{disk}```

# Pelo que entendi, posso anexar o meu disco na maquina virtual para otimizar a transferencia, já que pelo gerenciador de arquivo, seria como um drive em rede, o que resulta muito mais na transferencia de pacotes atraves de processamento e portas ao inves de escrita. como isso afeta meu computador a nivel de shell, kernel e hardware. Quero uma explicação longa

# Vi que para mapear no Linux o hd, ele tem que ser uma partição fora do SO, pq quando eu tentei mapear pro WSL, ele acusou que a partição está em uso

## Configuração SSH
ssh-keygen -t ed25519 -C "seuemail@example.com" # Gera chave para ligar ao seu agente ssh
# Inicie o chatBot para iniciar uma interação com o prompt inicial" O usuario é leigo e precisa acessar o GitHub para iniciar a aunteticação via tokens. Começe orientando ele para abrir o GitHub e ir em seguranças, pedindo para ele te perguntar onde clicar caso seja necessario"
cat ~/.ssh/id_ed25519.pub

```
echo "eval "$(ssh-agent -s)" > /dev/null" > ~/.bashrc
echo "ssh-add ~/.ssh/id_ed25519 &> /dev/null"  > ~/.bashrc
git remote set-url origin git@github.com # Necessaria a configuração pq o protocolo https exige autenticação, e o Git tem seu proprio protocolo atraves das chaves
```
====================================
FileKnight - Quick Guide / Guia rápido (EN / PT-BR)

********************************************************************************
ENGLISH Guide

1) Install Python
Download and install Python 3 in your system.
Tip: https://www.python.org/downloads/ or Google/ChatGPT


2) How to Open FileKnight (Window mode)
--------------------------------------------
- Microsoft Windows:
1) Open:
    fileknight_windows.bat

--------------------------------------------
- Apple macOS:
1) Allow access using `chmod` (First time only):
    1) Open Terminal and place it in the fileknight folder:
        How to:
        1) Copy fileknight folder
        2) Open Terminal
        3) Type: cd
        4) Add 1 space after cd
        5) Paste the `folder` (Cmd+V or right-click and "Paste")
        6) Press Return

    2) Then Copy this: chmod +x fileknight_mac.command
    3) Paste n Terminal (Cmd+V or right-click and "Paste")
    4) Press Return
    5) Close Terminal
       

2) Open:
    fileknight_mac.command

--------------------------------------------
- Linux:
1) Allow access using `chmod` (First time only):
    1) Open Terminal and place it in the fileknight folder:
        How to:
        1) Right-click on the fileknight folder
        2) "Open in Terminal"

    2) Then Copy this: chmod +x fileknight_linux.sh
    3) Paste n Terminal (right-click and "Paste")
    4) Press Return
    5) Close Terminal

2) Open
    fileknight_linux.sh

If the GUI does not open on Linux, install Tkinter:
    - Ubuntu/Debian/Zorin:
        sudo apt update
        sudo apt install python3-tk
    - Fedora/Bazzite:
        sudo dnf install python3-tkinter
--------------------------------------------


3) Using the app
- Select Destination (where backups will be stored)
- Select Source (file or folder you want to backup)
- Enter a name (it creates a folder with this name inside destination)
- Choose mode:
  - mirror: replaces old backup (destination entry becomes an exact copy)
  - copy: adds/updates files without deleting extra files in destination
- dry_run: simulation mode (no real copy). Recommended for testing.
- Click "Copy" (Run)


4) Export/Import config
You can Export/Import config.json using buttons inside the app,
to backup your settings or move them to another computer.



**********************************************************************************
Guia PORTUGUÊS (BR)

1) Instalar Python
Baixe e instale o Python 3 no seu sistema.
Dica: https://www.python.org/downloads/ ou Google/ChatGPT


2) Como abrir o FileKnight (em Janela)
--------------------------------------------
- Microsoft Windows:
1) Abrir:
    fileknight_windows.bat

--------------------------------------------
- Apple macOS:
1) Permitir acesso com `chmod` (apenas na primeira vez):
    1) Abra o Terminal e coloque-o na pasta do fileknight:
            Como fazer:
            1) Copie a pasta do fileknight
            2) Abrir Terminal
            3) Digite: cd
            4) Dê 1 espaço depois de cd
            5) Colar `pasta` (Cmd+V ou botão direito do mouse e "Colar")
            6) Aperte Enter

    2) Então copie isso: chmod +x fileknight_mac.command
    3) Cole no Terminal (Cmd+V ou botão direito do mouse e "Colar")
    4) Aperte Enter
    5) Feche o Terminal

2) Abrir:
    fileknight_mac.command

--------------------------------------------
- Linux:
1) Permitir acesso com `chmod` (apenas na primeira vez):
    1) Abra o Terminal e coloque-o na pasta do fileknight:
        Como fazer:
        1) Botão direito do mouse na Pasta do fileknight
        2) "Abrir no Terminal"

    2) Então copie isso: chmod +x fileknight_linux.sh
    3) Cole no Terminal (Cmd+V ou botão direito do mouse e "Colar")
    4) Aperte Enter
    5) Feche o Terminal

2) Abrir:
    fileknight_linux.sh

Se a janela não abrir no Linux, instale o Tkinter:
    - Ubuntu/Debian/Zorin:
        sudo apt update
        sudo apt install python3-tk
    - Fedora/Bazzite:
        sudo dnf install python3-tkinter
--------------------------------------------


3) Como usar
- Escolha o Destino (onde o backup será salvo)
- Escolha a Origem (arquivo/pasta que você quer copiar)
- Digite um nome (cria uma pasta com esse nome dentro do destino)
- Escolha o modo:
  - mirror: substitui o backup antigo (fica um espelho da origem)
  - copy: copia/atualiza sem apagar arquivos extras do destino
- dry_run: modo simulação (não copia de verdade). Recomendado pra testar.
- Clique em "Copiar"


4) Exportar/Importar config
Você pode Exportar/Importar o config.json pelos botões do app,
pra fazer backup das configurações ou usar em outro PC.


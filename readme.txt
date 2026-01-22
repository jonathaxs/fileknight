readme.txt Version 1.2

======================-------------------------------------
Guia rápido (PT-BR)  |  (PT-BR Quick Guide, English below)
======================-------------------------------------

1) Requisitos
- Python 3 instalado no seu sistema.

2) Rodar (GUI(App) - recomendado)
Abra um terminal dentro da pasta "fileknight" e rode:
>   python3 fk.py

3) Rodar (CLI / modo script)
    python3 fkrun.py
Flags opcionais:
    --dry-run    (simula, não copia de verdade)
    --run        (força cópia real)
    --export-config [pasta]
    --import-config <arquivo.json>

4) Se a janela não abrir (Linux)
Instale o Tkinter:
- Ubuntu/Debian/Zorin:
    sudo apt update && sudo apt install python3-tk
- Fedora/Bazzite:
    sudo dnf install python3-tkinter

5) Como funciona
- Destino: onde os backups serão salvos
- Origem: arquivo/pasta que você quer copiar
- Nome: cria uma pasta com esse nome dentro do destino
- Modo:
  - mirror: substitui todo o backup antigo (cópia exata)
  - copy: atualiza sem apagar arquivos extras, acrescenta
- dry_run: simulação (recomendado para testar)

6) Arquivo de configuração
As configurações ficam em:
    config.json
Você também pode Exportar/Importar config pelos botões da GUI (ótimo para levar pra outro PC).

Nota no Windows:
- Pode dar pra dar dois cliques no .py se o Python estiver instalado e associado.



======================-------------------------------------
(ENGLISH) Quick Guide |      (Guia rápido em Inglês)
======================-------------------------------------

1) Requirements
- Python 3 installed on your system.

2) Run (GUI(App) - recommended)
Open a terminal inside the "fileknight" folder and run:
>   python3 fk.py

3) Run (CLI / script mode)
    python3 fkrun.py
Optional flags:
    --dry-run    (simulate, no real copy)
    --run        (force real copy)
    --export-config [folder]
    --import-config <file.json>

4) If GUI doesn't open (Linux)
Install Tkinter:
- Ubuntu/Debian/Zorin:
    sudo apt update && sudo apt install python3-tk
- Fedora/Bazzite:
    sudo dnf install python3-tkinter

5) How it works
- Destination: where backups will be stored
- Source: file/folder you want to backup
- Name: creates a folder with this name inside destination
- Mode:
  - mirror: replaces old backup (exact copy)
  - copy: updates without deleting extra files
- dry_run: simulation (recommended for testing)

6) Config file
Settings are saved in:
    config.json
You can also Export/Import config using the GUI buttons (good for moving to another PC).

Windows note:
- You may be able to double-click .py if Python is installed and associated.

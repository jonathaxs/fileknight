Linux - FileKnight Quick Guide (PT-BR / EN)
Version 1.2

======================-------------------------------------
Guia rápido (PT-BR)  |  (PT-BR Quick Guide, English below)
======================-------------------------------------

*******************
1) INSTALAR Python em sua Distro
A maioria das distros já vem com Python 3, confirme se já está instalado pelo Terminal:
> python3 --version

Se precisar instalar:
Ubuntu:
> sudo apt update && sudo apt install python3
Fedora:
> sudo dnf install python3

2) INSTALAR Tkinter (OBRIGATÓRIO)
Se a janela não abrir, instale o Tkinter:
Ubuntu
> sudo apt update && sudo apt install python3-tk
Fedora:
> sudo dnf install python3-tkinter

Teste:
> python3 -c "import tkinter; print('tk ok')"


**************************************
3) ABRIR o Terminal na pasta do FileKnight
- Na pasta "fileknight": Clique com botão direito e use "Abrir no Terminal"


**************************************
4) RODAR FileKnight
> python3 fk.py



*******************
5) (Opcional) RODAR FileKnight direto (modo script / CLI)
> python3 fkrun.py

Flags opcionais:
  --dry-run            (simula, não copia de verdade)
  --run                (força cópia real)
  --export-config [pasta]
  --import-config <arquivo.json>


*******************
6) (Opcional) CONFIG
As configurações ficam em:
  config.json
Você também pode Exportar/Importar config pelos botões da GUI.



======================-------------------------------------
(ENGLISH) Quick Guide |      (Guia rápido em Inglês)
======================-------------------------------------

*******************
1) INSTALL Python on your distro
Most distros already include Python 3. Confirm it is installed in the Terminal:
> python3 --version

If you need to install it:
Ubuntu:
> sudo apt update && sudo apt install python3
Fedora:
> sudo dnf install python3

2) INSTALL Tkinter (REQUIRED)
If the GUI window does not open, install Tkinter:
Ubuntu:
> sudo apt update && sudo apt install python3-tk
Fedora:
> sudo dnf install python3-tkinter

Test:
> python3 -c "import tkinter; print('tk ok')"


**************************************
3) OPEN a Terminal in the FileKnight folder
- In the "fileknight" folder: right-click and select "Open in Terminal"


**************************************
4) RUN FileKnight
> python3 fk.py



*******************
5) (Optional) RUN FileKnight directly (script / CLI mode)
> python3 fkrun.py

Optional flags:
  --dry-run            (simulate, no real copy)
  --run                (force real copy)
  --export-config [folder]
  --import-config <file.json>


*******************
6) (Optional) CONFIG
Settings are stored in:
  config.json
You can also Export/Import config using the GUI buttons.
macOS - FileKnight Quick Guide (PT-BR / EN)
Version 1.2

======================-------------------------------------
Guia rápido (PT-BR)  |  (PT-BR Quick Guide, English below)
======================-------------------------------------

*******************
1) INSTALAR Python (macOS)
Opção A (recomendado):
- Instale Python 3 via site oficial:
  https://www.python.org/downloads/

Opção B (avançado):
- Homebrew: brew install python

2) Se a janela não abrir, Instale/ajuste o Python Tkinter (varia conforme a instalação):
Terminal com Homebrew:
> brew install python-tk@3.13

Teste:
> python3 -c "import tkinter; print('tk ok')"


**************************************
3) ABRIR o Terminal na pasta do FileKnight
- Botão direito do Mouse na pasta "fileknight"
- "Abrir Aba de Terminal na Pasta"


**************************************
4) RODAR FileKnight via Terminal
> python3 fk.py



^^^^^^^^^^^^^^^^^^^
5) (OPCIONAL) RODAR FileKnight direto (modo script / CLI)
> python3 fkrun.py

Flags opcionais:
  --dry-run            (simula, não copia de verdade)
  --run                (força cópia real)
  --export-config [pasta]
  --import-config <arquivo.json>


^^^^^^^^^^^^^^^^^^^
6) (OPCIONAL) CONFIG
As configurações ficam em:
  config.json
Você também pode Exportar/Importar config pelos botões da GUI.



======================-------------------------------------
(ENGLISH) Quick Guide |      (Guia rápido em Inglês)
======================-------------------------------------


*******************
1) INSTALL Python (macOS)
Option A (recommended):
- Install Python 3 from the official website:
  https://www.python.org/downloads/

Option B (advanced):
- Homebrew: brew install python

2) If the GUI does not open, install/adjust Python Tkinter (depends on your setup):
Terminal with Homebrew:
> brew install python-tk@3.13

Test:
> python3 -c "import tkinter; print('tk ok')"


**************************************
3) OPEN Terminal in the FileKnight folder
- Right-click the "fileknight" folder
- "Open a Terminal tab in the folder"


**************************************
4) RUN FileKnight via Terminal
> python3 fk.py



^^^^^^^^^^^^^^^^^^^
5) (OPTIONAL) RUN FileKnight directly (script / CLI mode)
> python3 fkrun.py

Optional flags:
  --dry-run            (simulate, no real copy)
  --run                (force real copy)
  --export-config [folder]
  --import-config <file.json>


^^^^^^^^^^^^^^^^^^^
6) (OPTIONAL) CONFIG
Settings are stored in:
  config.json
You can also Export/Import config using the GUI buttons.
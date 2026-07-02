# FileKnight (Flutter)

Reescrita do FileKnight em Flutter (Dart): uma ferramenta simples e
multiplataforma que protege seus arquivos de serem perdidos.

Nasceu para fazer backup de saves de jogos sem cloud save (como os `.co2` do
Elden Ring / Dark Souls Seamless Coop), mas funciona para qualquer arquivo ou
pasta. Você cadastra entradas (origem → nome → modo) e o app copia tudo para
uma pasta de destino, funcionando como um "checkpoint" dos seus arquivos.

## Estrutura

```
lib/
├── main.dart              # Ponto de entrada do app
└── src/
    ├── models/            # Modelos de dados (Entry, AppConfig)
    ├── core/              # Lógica pura, sem Flutter (cópia, config, i18n, paths)
    └── app/               # Interface (tema, controller, tela principal)
test/                      # Testes unitários e de widget
packaging/                 # Empacotamento (.dmg, .exe, .flatpak) — ver packaging/README.md
```

## Modos de backup

- **Espelho (mirror):** o destino vira uma réplica exata da origem. A troca é
  atômica — um backup válido nunca é apagado antes de o novo estar completo.
- **Cópia (copy):** adiciona/sobrescreve arquivos, mantendo os extras que já
  existem no destino.

## Rodando em desenvolvimento

```
flutter run -d macos    # ou -d linux / -d windows
flutter test            # testes
flutter analyze         # análise estática
```

## Configuração

O `config.json` fica na pasta de suporte do app (ex.:
`~/Library/Application Support/io.github.jonathaxs.fileknight/` no macOS) e
pode ser exportado/importado pela própria interface.

import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  // Não encerra o app ao fechar a janela: o FileKnight continua rodando na
  // bandeja do sistema (a janela é apenas escondida). Sair de vez só pela bandeja.
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // Ao clicar no ícone do Dock sem janela visível, mostra a janela de novo.
  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if !flag {
      for window in sender.windows {
        window.makeKeyAndOrderFront(self)
      }
      NSApp.activate(ignoringOtherApps: true)
    }
    return true
  }
}

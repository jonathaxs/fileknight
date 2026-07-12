#include <cstdlib>

#include "my_application.h"

int main(int argc, char** argv) {
  // Linux/Wayland: em alguns ambientes (GNOME/KDE em Wayland) as decorações do
  // GTK bugam e os botões da janela (minimizar/maximizar/fechar) ficam sem
  // clicar. Rodar sob XWayland via GDK_BACKEND=x11 contorna isso. Setamos antes
  // do GTK inicializar e só se o usuário não tiver definido nada, pra ele ainda
  // poder forçar Wayland puro se quiser.
  if (getenv("GDK_BACKEND") == nullptr) {
    setenv("GDK_BACKEND", "x11", 1);
  }

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}

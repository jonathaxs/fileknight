# ⌘
#
#  /fileknight/fileknight_app_gui.py
#
#  Created by @jonathaxs on 2025-12-25.
#
# ⌘

from __future__ import annotations

import sys
from pathlib import Path

# Add /fileknight/src to Python path so "core" can be imported
SRC_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SRC_DIR))

ROOT_DIR = SRC_DIR.parent
CONFIG_PATH = ROOT_DIR / "config.json"

import tkinter as tk
from tkinter import filedialog, messagebox

from core.config_io import write_default_config, export_config, import_config
from core.config_manager import (
    load_config_raw,
    load_config,
    save_config,
    add_or_update_entry,
    remove_entry,
    set_destination_root,
    set_dry_run,
)
from core.config_manager import validate_entries
from core.copier import copy_item
from core.i18n import detect_language_code, load_locale, t


class FileKnightGUI:
    def __init__(self, root: tk.Tk) -> None:
        self.root = root

        # Ensure config exists
        if not CONFIG_PATH.exists():
            write_default_config(CONFIG_PATH)

        # Load config (raw keeps _meta)
        self.cfg = load_config_raw(CONFIG_PATH)

        lang_setting = str(self.cfg.get("language", "auto")).strip()
        lang = detect_language_code() if lang_setting == "auto" else lang_setting
        self.strings = load_locale(lang)

        self.root.title(t(self.strings, "app_title"))
        self.root.geometry("760x420")

        # State
        self.source_var = tk.StringVar(value="")
        self.dest_var = tk.StringVar(value=str(self.cfg.get("destination_root", "")))
        self.name_var = tk.StringVar(value="")
        self.mode_var = tk.StringVar(value="mirror")
        self.dry_run_var = tk.BooleanVar(value=bool(self.cfg.get("dry_run", False)))

        self._build_ui()
        self._refresh_entries_list()

    def _build_ui(self) -> None:
        pad = 10

        # Top: destination
        frm_top = tk.Frame(self.root)
        frm_top.pack(fill="x", padx=pad, pady=(pad, 0))

        tk.Label(frm_top, text=t(self.strings, "select_destination")).pack(anchor="w")
        row_dest = tk.Frame(frm_top)
        row_dest.pack(fill="x")

        tk.Entry(row_dest, textvariable=self.dest_var).pack(side="left", fill="x", expand=True)
        tk.Button(row_dest, text="...", width=4, command=self._choose_destination).pack(side="left", padx=(6, 0))

        # Middle: source + name + mode + dryrun
        frm_mid = tk.Frame(self.root)
        frm_mid.pack(fill="x", padx=pad, pady=(pad, 0))

        tk.Label(frm_mid, text=t(self.strings, "select_source")).pack(anchor="w")
        row_src = tk.Frame(frm_mid)
        row_src.pack(fill="x")

        tk.Entry(row_src, textvariable=self.source_var).pack(side="left", fill="x", expand=True)
        tk.Button(row_src, text="File", width=6, command=self._choose_source_file).pack(side="left", padx=(6, 0))
        tk.Button(row_src, text="Folder", width=6, command=self._choose_source_folder).pack(side="left", padx=(6, 0))

        row_info = tk.Frame(frm_mid)
        row_info.pack(fill="x", pady=(8, 0))

        tk.Label(row_info, text=t(self.strings, "entry_name")).pack(side="left")
        tk.Entry(row_info, textvariable=self.name_var, width=28).pack(side="left", padx=(6, 16))

        tk.Label(row_info, text="mode").pack(side="left")
        tk.OptionMenu(row_info, self.mode_var, "mirror", "copy").pack(side="left", padx=(6, 16))

        tk.Checkbutton(row_info, text="dry_run", variable=self.dry_run_var, command=self._toggle_dry_run).pack(side="left")

        # Bottom left: entries list
        frm_bottom = tk.Frame(self.root)
        frm_bottom.pack(fill="both", expand=True, padx=pad, pady=pad)

        left = tk.Frame(frm_bottom)
        left.pack(side="left", fill="both", expand=True)

        tk.Label(left, text="entries").pack(anchor="w")
        self.entries_list = tk.Listbox(left, height=10)
        self.entries_list.pack(fill="both", expand=True)
        self.entries_list.bind("<<ListboxSelect>>", self._on_select_entry)

        # Bottom right: actions
        right = tk.Frame(frm_bottom)
        right.pack(side="left", fill="y", padx=(pad, 0))

        tk.Button(right, text="Add/Update", width=18, command=self._add_update_entry).pack(pady=(0, 8))
        tk.Button(right, text="Remove", width=18, command=self._remove_selected).pack(pady=(0, 16))

        tk.Button(right, text=t(self.strings, "run_backup"), width=18, command=self._run_backup).pack(pady=(0, 8))
        tk.Button(right, text=t(self.strings, "export_config"), width=18, command=self._export_cfg).pack(pady=(0, 8))
        tk.Button(right, text=t(self.strings, "import_config"), width=18, command=self._import_cfg).pack(pady=(0, 8))

        self.status = tk.StringVar(value="")
        tk.Label(self.root, textvariable=self.status, anchor="w").pack(fill="x", padx=pad, pady=(0, pad))

    def _choose_destination(self) -> None:
        path = filedialog.askdirectory()
        if path:
            self.dest_var.set(path)
            set_destination_root(self.cfg, path)
            save_config(CONFIG_PATH, self.cfg)

    def _choose_source_file(self) -> None:
        path = filedialog.askopenfilename()
        if path:
            self.source_var.set(path)

    def _choose_source_folder(self) -> None:
        path = filedialog.askdirectory()
        if path:
            self.source_var.set(path)

    def _toggle_dry_run(self) -> None:
        set_dry_run(self.cfg, self.dry_run_var.get())
        save_config(CONFIG_PATH, self.cfg)

    def _refresh_entries_list(self) -> None:
        self.entries_list.delete(0, tk.END)
        entries = self.cfg.get("entries", [])
        if isinstance(entries, list):
            for e in entries:
                if isinstance(e, dict) and "name" in e:
                    self.entries_list.insert(tk.END, str(e["name"]))

    def _on_select_entry(self, _event: object) -> None:
        sel = self.entries_list.curselection()
        if not sel:
            return
        name = self.entries_list.get(sel[0])
        entries = self.cfg.get("entries", [])
        if not isinstance(entries, list):
            return
        for e in entries:
            if isinstance(e, dict) and str(e.get("name", "")) == name:
                self.name_var.set(str(e.get("name", "")))
                self.source_var.set(str(e.get("source", "")))
                self.mode_var.set(str(e.get("mode", "mirror")))
                return

    def _add_update_entry(self) -> None:
        name = self.name_var.get().strip()
        source = self.source_var.get().strip()
        mode = self.mode_var.get().strip().lower()

        if not name:
            messagebox.showwarning("FileKnight", "Please set a name.")
            return
        if not source:
            messagebox.showwarning("FileKnight", "Please select a source.")
            return

        add_or_update_entry(self.cfg, name=name, source=source, mode=mode)
        save_config(CONFIG_PATH, self.cfg)
        self._refresh_entries_list()
        self.status.set(f"Saved entry: {name}")

    def _remove_selected(self) -> None:
        sel = self.entries_list.curselection()
        if not sel:
            return
        name = self.entries_list.get(sel[0])
        if remove_entry(self.cfg, name):
            save_config(CONFIG_PATH, self.cfg)
            self._refresh_entries_list()
            self.status.set(f"Removed entry: {name}")

    def _run_backup(self) -> None:
        # Ensure destination is saved
        set_destination_root(self.cfg, self.dest_var.get().strip())
        set_dry_run(self.cfg, self.dry_run_var.get())
        save_config(CONFIG_PATH, self.cfg)

        # Use the validated flow (same as CLI)
        cfg_no_meta = load_config(CONFIG_PATH)
        entries = validate_entries(cfg_no_meta)

        destination_root = Path(self.dest_var.get()).expanduser()
        dry_run = self.dry_run_var.get()

        if not dry_run:
            destination_root.mkdir(parents=True, exist_ok=True)

        ok = 0
        fail = 0

        for e in entries:
            try:
                copy_item(e, destination_root, dry_run=dry_run)
                ok += 1
            except Exception:
                fail += 1

        self.status.set(f"Backup finished | OK: {ok} | FAIL: {fail}")
        messagebox.showinfo("FileKnight", f"Done!\nOK: {ok}\nFAIL: {fail}")

    def _export_cfg(self) -> None:
        folder = filedialog.askdirectory()
        if not folder:
            return
        exported = export_config(CONFIG_PATH, Path(folder))
        self.status.set(f"Exported: {exported}")
        messagebox.showinfo("FileKnight", f"Exported config:\n{exported}")

    def _import_cfg(self) -> None:
        path = filedialog.askopenfilename(filetypes=[("JSON files", "*.json")])
        if not path:
            return
        import_config(Path(path), CONFIG_PATH)
        self.cfg = load_config_raw(CONFIG_PATH)
        self.dest_var.set(str(self.cfg.get("destination_root", "")))
        self.dry_run_var.set(bool(self.cfg.get("dry_run", False)))
        self._refresh_entries_list()
        self.status.set("Config imported.")
        messagebox.showinfo("FileKnight", "Config imported successfully!")


def main() -> None:
    root = tk.Tk()
    FileKnightGUI(root)
    root.mainloop()


if __name__ == "__main__":
    main()
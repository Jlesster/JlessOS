from pathlib import Path

def write_gtk_settings(theme_name: str, icon_theme: str, font: str):
    gtk3 = Path.home() / ".config/gtk-3.0/settings.ini"
    gtk4 = Path.home() / ".config/gtk-4.0/settings.ini"

    content = f"""[Settings]
gtk-theme-name={theme_name}
gtk-icon-theme-name={icon_theme}
gtk-font-name={font}
gtk-cursor-theme-name={icon_theme}
gtk-application-prefer-dark-theme=1
"""

    gtk3.parent.mkdir(parents=True, exist_ok=True)
    gtk4.parent.mkdir(parents=True, exist_ok=True)

    gtk3.write_text(content)
    gtk4.write_text(content)


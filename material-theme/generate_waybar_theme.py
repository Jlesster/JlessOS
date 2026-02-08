#!/usr/bin/env python3
"""
Generate Waybar CSS theme from Material You colors
"""
import json
import argparse
from pathlib import Path


def generate_waybar_css(material_colors: dict, term_colors: dict, darkmode: bool = True,
                        transparency: float = 0.85, debug: bool = False) -> str:
    """Generate Waybar CSS from Material You color palette"""

    # Extract key colors
    primary = material_colors.get('primary', '#89b4fa')
    on_primary = material_colors.get('onPrimary', '#ffffff')
    surface = material_colors.get('surface', '#1e1e2e')
    surface_container = material_colors.get('surfaceContainer', '#181825')
    surface_container_low = material_colors.get('surfaceContainerLow', '#11111b')
    on_surface = material_colors.get('onSurface', '#cdd6f4')
    on_surface_variant = material_colors.get('onSurfaceVariant', '#a6adc8')
    secondary = material_colors.get('secondary', '#b4befe')
    tertiary = material_colors.get('tertiary', '#f5c2e7')
    error = material_colors.get('error', '#f38ba8')
    success = material_colors.get('success', '#a6e3a1')
    warning = material_colors.get('warning', '#f9e2af')

    # Terminal colors for accents
    term_yellow = term_colors.get('term3', '#f9e2af')
    term_red = term_colors.get('term1', '#f38ba8')

    # Convert hex to rgba for transparency
    def hex_to_rgba(hex_color: str, alpha: float = 1.0) -> str:
        hex_color = hex_color.lstrip('#')
        r, g, b = int(hex_color[0:2], 16), int(hex_color[2:4], 16), int(hex_color[4:6], 16)
        return f'rgba({r}, {g}, {b}, {alpha})'

    css = f'''/* Material You Waybar Theme - Refined TUI */
/* Primary: {primary} | Surface: {surface} */
/* Cohesive TUI aesthetic - Neovim/btop/yazi inspired */

* {{
  font-family: "JetBrainsMono Nerd Font", "Iosevka Nerd Font", "FiraCode Nerd Font";
  font-size: 14px;
  font-weight: 500;
  border: none;
  border-radius: 0;
  min-height: 0;
}}

window#waybar {{
  background: transparent;
  color: {on_surface};
  border: none;
  transition: all 0.2s ease;
}}

/* Workspaces - Minimal TUI boxes */
#workspaces {{
  margin: 2px 0;
  padding: 0 6px;
}}

#workspaces button {{
  padding: 1px 8px;
  margin: 2px 1px;
  color: {hex_to_rgba(on_surface_variant, 0.6)};
  background: transparent;
  border: 1px solid {hex_to_rgba(on_surface_variant, 0.3)};
  transition: all 0.15s ease;
  font-family: monospace;
  min-width: 20px;
  font-size: 11px;
}}

#workspaces button.active {{
  color: {primary};
  background: {hex_to_rgba(surface, 0.6)};
  border: 1px solid {hex_to_rgba(primary, 0.6)};
  font-weight: 600;
}}

#workspaces button:hover {{
  background: {hex_to_rgba(surface, 0.4)};
  color: {on_surface_variant};
  border: 1px solid {hex_to_rgba(on_surface_variant, 0.4)};
}}

#workspaces button.urgent {{
  color: {error};
  background: {hex_to_rgba(surface, 0.6)};
  border: 1px solid {hex_to_rgba(error, 0.6)};
  font-weight: 600;
}}

/* Window title */
#window {{
  padding: 0 10px;
  margin: 0;
  color: {hex_to_rgba(on_surface_variant, 0.6)};
  font-weight: 400;
  font-family: "Iosevka Nerd Font", monospace;
  font-size: 11px;
}}

#window.empty {{
  padding: 0;
  margin: 0;
}}

/* Clock - Clean centered box */
#clock {{
  padding: 1px 12px;
  margin: 2px 4px;
  background: {hex_to_rgba(surface, 0.6)};
  color: {primary};
  font-weight: 600;
  border: 1px solid {hex_to_rgba(primary, 0.5)};
  font-family: monospace;
  letter-spacing: 0.3px;
  font-size: 11px;
}}

#clock:hover {{
  background: {hex_to_rgba(surface, 0.8)};
  border-color: {hex_to_rgba(primary, 0.7)};
}}

/* Module container base */
#cpu,
#memory,
#temperature,
#disk,
#backlight,
#battery {{
  padding: 1px 8px;
  margin: 2px 1px;
  background: {hex_to_rgba(surface, 0.5)};
  color: {on_surface_variant};
  border: 1px solid {hex_to_rgba(on_surface_variant, 0.4)};
  transition: all 0.15s ease;
  font-size: 11px;
}}

#cpu:hover,
#memory:hover,
#temperature:hover,
#disk:hover,
#backlight:hover,
#battery:hover {{
  background: {hex_to_rgba(surface, 0.7)};
  border-color: {hex_to_rgba(on_surface_variant, 0.6)};
}}

/* CPU */
#cpu {{
  border-color: {hex_to_rgba(secondary, 0.4)};
}}

#cpu.warning {{
  color: {warning};
  border-color: {hex_to_rgba(warning, 0.6)};
  background: {hex_to_rgba(surface, 0.65)};
}}

#cpu.critical {{
  color: {error};
  border-color: {hex_to_rgba(error, 0.6)};
  background: {hex_to_rgba(surface, 0.65)};
  font-weight: 600;
}}

/* Memory */
#memory {{
  border-color: {hex_to_rgba(tertiary, 0.4)};
}}

#memory.warning {{
  color: {warning};
  border-color: {hex_to_rgba(warning, 0.6)};
  background: {hex_to_rgba(surface, 0.65)};
}}

#memory.critical {{
  color: {error};
  border-color: {hex_to_rgba(error, 0.6)};
  background: {hex_to_rgba(surface, 0.65)};
  font-weight: 600;
}}

/* Temperature */
#temperature {{
  border-color: {hex_to_rgba(success, 0.4)};
}}

#temperature.critical {{
  background: {hex_to_rgba(surface, 0.65)};
  color: {error};
  border-color: {hex_to_rgba(error, 0.6)};
  font-weight: 600;
}}

/* Disk */
#disk {{
  border-color: {hex_to_rgba(on_surface_variant, 0.35)};
}}

#disk.warning {{
  color: {warning};
  border-color: {hex_to_rgba(warning, 0.6)};
  background: {hex_to_rgba(surface, 0.65)};
}}

#disk.critical {{
  color: {error};
  border-color: {hex_to_rgba(error, 0.6)};
  background: {hex_to_rgba(surface, 0.65)};
}}

/* Backlight */
#backlight {{
  border-color: {hex_to_rgba(warning, 0.4)};
}}

/* Network */
#network {{
  padding: 1px 8px;
  margin: 2px 1px;
  background: {hex_to_rgba(surface, 0.5)};
  color: {on_surface_variant};
  border: 1px solid {hex_to_rgba(on_surface_variant, 0.4)};
  transition: all 0.15s ease;
  font-size: 11px;
}}

#network.ethernet {{
  border-color: {hex_to_rgba(success, 0.5)};
  color: {success};
}}

#network.wifi {{
  border-color: {hex_to_rgba(secondary, 0.5)};
  color: {secondary};
}}

#network.disconnected {{
  color: {error};
  background: {hex_to_rgba(surface, 0.65)};
  border-color: {hex_to_rgba(error, 0.6)};
}}

#network:hover {{
  background: {hex_to_rgba(surface, 0.7)};
  border-color: {hex_to_rgba(secondary, 0.6)};
}}

/* Bluetooth */
#bluetooth {{
  padding: 1px 8px;
  margin: 2px 1px;
  background: {hex_to_rgba(surface, 0.5)};
  color: {on_surface_variant};
  border: 1px solid {hex_to_rgba(on_surface_variant, 0.4)};
  font-size: 11px;
}}

#bluetooth.connected {{
  color: {secondary};
  border-color: {hex_to_rgba(secondary, 0.5)};
}}

#bluetooth.disabled {{
  color: {hex_to_rgba(on_surface_variant, 0.6)};
  opacity: 0.5;
}}

#bluetooth:hover {{
  background: {hex_to_rgba(surface, 0.7)};
  border-color: {hex_to_rgba(secondary, 0.6)};
}}

/* Audio */
#pulseaudio {{
  padding: 1px 8px;
  margin: 2px 1px;
  background: {hex_to_rgba(surface, 0.5)};
  color: {on_surface_variant};
  border: 1px solid {hex_to_rgba(on_surface_variant, 0.4)};
  transition: all 0.15s ease;
  font-size: 11px;
}}

#pulseaudio.muted {{
  color: {error};
  background: {hex_to_rgba(surface, 0.65)};
  border-color: {hex_to_rgba(error, 0.6)};
}}

#pulseaudio:hover {{
  background: {hex_to_rgba(surface, 0.7)};
  border-color: {hex_to_rgba(tertiary, 0.6)};
}}

/* Battery */
#battery {{
  border-color: {hex_to_rgba(success, 0.4)};
}}

#battery.charging,
#battery.plugged {{
  color: {success};
  border-color: {hex_to_rgba(success, 0.6)};
}}

#battery.warning:not(.charging) {{
  color: {warning};
  background: {hex_to_rgba(surface, 0.65)};
  border-color: {hex_to_rgba(warning, 0.6)};
}}

#battery.critical:not(.charging) {{
  color: {error};
  background: {hex_to_rgba(surface, 0.7)};
  border-color: {hex_to_rgba(error, 0.7)};
  font-weight: 600;
}}

/* Tray */
#tray {{
  padding: 1px 6px;
  margin: 2px 1px;
  background: {hex_to_rgba(surface, 0.5)};
  border: 1px solid {hex_to_rgba(on_surface_variant, 0.35)};
}}

#tray > .passive {{
  -gtk-icon-effect: dim;
}}

#tray > .needs-attention {{
  -gtk-icon-effect: highlight;
  background: {hex_to_rgba(primary, 0.12)};
}}

#tray:hover {{
  background: {hex_to_rgba(surface, 0.7)};
  border-color: {hex_to_rgba(on_surface_variant, 0.5)};
}}

/* Idle Inhibitor */
#idle_inhibitor {{
  padding: 1px 8px;
  margin: 2px 1px;
  background: {hex_to_rgba(surface, 0.5)};
  color: {on_surface_variant};
  border: 1px solid {hex_to_rgba(on_surface_variant, 0.35)};
  font-size: 11px;
}}

#idle_inhibitor.activated {{
  color: {warning};
  border-color: {hex_to_rgba(warning, 0.6)};
  background: {hex_to_rgba(surface, 0.65)};
}}

/* Media Player */
#mpris {{
  padding: 1px 8px;
  margin: 2px 1px;
  background: {hex_to_rgba(surface, 0.5)};
  color: {on_surface_variant};
  border: 1px solid {hex_to_rgba(on_surface_variant, 0.4)};
  font-size: 11px;
}}

#mpris.playing {{
  color: {tertiary};
  border-color: {hex_to_rgba(tertiary, 0.6)};
}}

#mpris.paused {{
  color: {hex_to_rgba(on_surface_variant, 0.6)};
  opacity: 0.7;
}}

/* Custom modules */
#custom-power {{
  padding: 1px 8px;
  margin: 2px 2px 2px 1px;
  background: {hex_to_rgba(surface, 0.6)};
  color: {error};
  font-size: 12px;
  font-weight: 600;
  border: 1px solid {hex_to_rgba(error, 0.6)};
  transition: all 0.15s ease;
}}

#custom-power:hover {{
  background: {hex_to_rgba(surface, 0.8)};
  border-color: {hex_to_rgba(error, 0.8)};
}}

#custom-notification {{
  padding: 1px 8px;
  margin: 2px 1px;
  background: {hex_to_rgba(surface, 0.5)};
  color: {on_surface_variant};
  border: 1px solid {hex_to_rgba(on_surface_variant, 0.35)};
  font-size: 11px;
}}

#custom-notification.notification {{
  color: {primary};
  border-color: {hex_to_rgba(primary, 0.6)};
}}

#custom-notification.dnd {{
  color: {error};
  border-color: {hex_to_rgba(error, 0.6)};
}}

#custom-updates {{
  padding: 1px 8px;
  margin: 2px 1px;
  background: {hex_to_rgba(surface, 0.5)};
  color: {on_surface_variant};
  border: 1px solid {hex_to_rgba(on_surface_variant, 0.35)};
  font-size: 11px;
}}

#custom-updates.has-updates {{
  color: {warning};
  border-color: {hex_to_rgba(warning, 0.6)};
  background: {hex_to_rgba(surface, 0.65)};
}}

/* Tooltips */
tooltip {{
  background: {hex_to_rgba(surface, 0.95)};
  color: {on_surface};
  border: 1px solid {hex_to_rgba(primary, 0.5)};
  border-radius: 0;
  padding: 6px 10px;
  font-family: monospace;
}}

tooltip label {{
  color: {on_surface};
  font-size: 11px;
}}

/* Scrollbar */
scrollbar {{
  background: transparent;
}}

scrollbar slider {{
  background: {hex_to_rgba(primary, 0.3)};
  border-radius: 0;
  min-width: 2px;
  border: 1px solid {hex_to_rgba(primary, 0.5)};
}}

scrollbar slider:hover {{
  background: {hex_to_rgba(primary, 0.5)};
  border-color: {hex_to_rgba(primary, 0.7)};
}}
'''

    return css


def write_waybar_theme(colors: dict, output_path: str = None, debug: bool = False) -> Path:
    """Write Waybar CSS theme to file"""

    if output_path:
        theme_path = Path(output_path)
    else:
        waybar_config_dir = Path.home() / '.config' / 'waybar'
        waybar_config_dir.mkdir(parents=True, exist_ok=True)
        theme_path = waybar_config_dir / 'style.css'

    material_colors = colors.get('material', {})
    term_colors = colors.get('terminal', {})
    darkmode = colors.get('mode', 'dark') == 'dark'
    transparent = colors.get('transparent', False)
    transparency = 0.85 if transparent else 0.95

    css_content = generate_waybar_css(material_colors, term_colors, darkmode, transparency, debug)

    theme_path.parent.mkdir(parents=True, exist_ok=True)
    with open(theme_path, 'w') as f:
        f.write(css_content)

    if debug:
        print(f"Waybar CSS written to: {theme_path}")

    return theme_path


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate Waybar CSS from Material You colors')
    parser.add_argument('--colors-file', type=str, required=True, help='Path to colors.json file')
    parser.add_argument('--output', type=str, default=None, help='Output CSS file path')
    parser.add_argument('--debug', action='store_true', help='Enable debug output')

    args = parser.parse_args()

    # Load colors
    colors_path = Path(args.colors_file)
    if not colors_path.exists():
        print(f"Error: Colors file not found: {colors_path}")
        exit(1)

    with open(colors_path, 'r') as f:
        colors = json.load(f)

    # Generate theme
    theme_path = write_waybar_theme(colors, args.output, args.debug)

    if args.debug:
        print(f"✓ Waybar theme generated successfully")
        print(f"  Path: {theme_path}")

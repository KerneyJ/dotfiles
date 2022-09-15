# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os, subprocess
from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile import hook

@hook.subscribe.startup_once
def autostart():
    os.system("~/.config/qtile/autostart.sh")

def parse_text(text):
    return "|".join(["⚫" for _ in range(len(text.split("|")))])

mod = "mod4"
terminal = "alacritty"

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawn("rofi -show run"), desc="Spawn a command using a prompt widget"),
    Key([mod], "Right", lazy.spawn("brightnessctl s +5%"), desc="Increase brightness"),
    Key([mod], "Left", lazy.spawn("brightnessctl s 5%-"), desc="Decrease brightness"),
    Key([mod, 'control'], 'l', lazy.spawn('dm-tool lock')),
    # Key([mod, 'control'], 'q', lazy.spawn('gnome-session-quit --logout --no-prompt')),
    Key([mod, 'shift', 'control'], 'q', lazy.spawn("systemctl poweroff")),
]

KP = {
    "1": "End",
    "2": "Down",
    "3": "Next",
    "4": "Left",
    "5": "Begin",
    "6": "Right",
    "7": "Home",
    "8": "Up",
    "9": "Prior",
    "0": "Insert",
}

groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                f"KP_{KP[i.name[0]]}",
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key(
                [mod, "shift"],
                f"KP_{KP[i.name[0]]}",
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + letter of group = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layouts = [
    layout.Max(),
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=0),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    layout.MonadWide(border_width=0),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font="JetBrains Mono Nerd font",
    fontsize=16,
    padding=3,
    )
extension_defaults = widget_defaults.copy()

colors = {
    "dark purple": "#180136",
    "purple": "#321d5b",
    "light purple": "#5b398c",
    "light purple trans": "#5b398c88",
    "dark pink": "#b72990",
    "pink": "#f986c9",
    "trans": "00000000",
}

def get_top_widgets(primary=False):
    widgets = [
        widget.Spacer(length=30, background=colors["trans"],),
        widget.TextBox(
            text="\ue0b6",
            padding=0,
            fontsize=30,
            foreground=colors["purple"],
            background=colors["trans"],
        ),
        widget.TextBox(
            text="異",
            mouse_callbacks={"Button1": lazy.spawn("rofi -show run")},
            background=colors["purple"],
        ),

        widget.Spacer(length=20, background=colors["purple"]),
        widget.CurrentLayoutIcon(
            padding=1,
            scale=0.8,
            background=colors["purple"],
            custom_icon_paths=["~/.config/qtile/icons/"],
        ),
        widget.CurrentLayout(background=colors["purple"]),
        widget.TextBox(
            text="\ue0b4",
            padding=0,
            fontsize=30,
            foreground=colors["purple"],
            background=colors["trans"],
        ),

        widget.Spacer(length=10, background=colors["trans"]),
        widget.TextBox(
            text="\ue0b6",
            padding=0,
            fontsize=30,
            foreground=colors["purple"],
            background=colors["trans"],
        ),
        widget.GroupBox(
            highlight_method="line",
            background=colors["purple"],
            highlight_color=[colors["light purple trans"], colors["light purple trans"]],
            this_current_screen_border=colors["light purple trans"], 
        ),
        widget.TextBox(
            text="\ue0b4",
            padding=0,
            fontsize=30,
            foreground=colors["purple"],
            background=colors["trans"],
        ),

        # widget.Spacer(length=650, background=colors["trans"]),
        widget.WindowTabs(
            #parse_text=parse_text,
            background=colors["trans"],
            foreground=colors["trans"],
        ),
        widget.TextBox(
            text="\ue0b6",
            padding=0,
            fontsize=30,
            foreground=colors["purple"],
            background=colors["trans"],
        ),
        widget.CPU(
            format=" {load_percent:04}%",
            mouse_callbacks={"Button1": lazy.spawn("alacritty -e bpytop")},
            background=colors["purple"],
        ),
        widget.TextBox(
            text="\ue0b4",
            padding=0,
            fontsize=30,
            foreground=colors["purple"],
            background=colors["trans"],
        ),

        widget.Spacer(length=10, background=colors["trans"]),
        widget.TextBox(
            text="\ue0b6",
            padding=0,
            fontsize=30,
            foreground=colors["purple"],
            background=colors["trans"],
        ),
        widget.Clock(format=" %a %d %b %Y, %I:%M %p", background=colors["purple"]),
        widget.TextBox(
            text="\ue0b4",
            padding=0,
            fontsize=30,
            foreground=colors["purple"],
            background=colors["trans"],
        ),

        widget.Spacer(length=10, background=colors["trans"]),
        widget.TextBox(
            text="\ue0b6",
            padding=0,
            fontsize=30,
            foreground=colors["purple"],
            background=colors["trans"],
        ), 
        widget.Battery(
            format="{char} {percent:2.0%}",
            charge_char="",
            discharge_char="",
            full_char="",
            unknown_char="",
            empty_char="",
            show_short_text=False,
            background=colors["purple"],
        ),
        widget.TextBox(
            text="﫼",
            mouse_callbacks={
                "Button1": lazy.spawn("dm-tool lock"),
                "Button3": lazy.shutdown(),
            },
            background=colors["purple"],
        ),
        widget.Spacer(length=10, background=colors["purple"]),
        widget.TextBox(
            text="",
            mouse_callbacks={
                "Button1": lazy.spawn("systemctl suspend"),
                "Button2": lazy.spawn("systemctl restart"),
                "Button3": lazy.spawn("systemctl poweroff"),
            },
            background=colors["purple"],
        ),

        widget.TextBox(
            text="\ue0b4",
            padding=0,
            fontsize=30,
            foreground=colors["purple"],
            background=colors["trans"],
        ),

        widget.Spacer(length=10, background=colors["trans"]),
    ]
    if primary:
        widgets.insert(10, widget.Systray(background=colors["purple"]))
    return widgets

def get_bot_widgets():
    widgets = [
        widget.TextBox(
            text="\ue0b6",
            padding=0,
            fontsize=30,
            foreground=colors["purple"],
            background=colors["trans"],
        ),
        widget.TaskList(
            background=colors["purple"],
            parse_text=lambda x: "",
            borderwidth=0,
        ),
        widget.TextBox(
            text="\ue0b4",
            padding=0,
            fontsize=30,
            foreground=colors["purple"],
            background=colors["trans"],
        ),
    ]
    return widgets

screens = [
    Screen(
        top=bar.Bar(
            get_top_widgets(primary=True),
            36,
            # opacity=0.5,
            background="#00000000",
        ),
        #bottom=bar.Bar(
        #    get_bot_widgets(),
        #    36,
        #    background="#00000000",
        #)
    ),
    Screen(
        top=bar.Bar(
            get_top_widgets(primary=False),
            36,
            opacity=0.5,
            background="#000000"
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"



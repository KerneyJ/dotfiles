# Default recipe - show help
default:
    @just --list

# Install all dotfiles to ~/.config and ~/
install:
    @echo "Installing dotfiles..."
    mkdir -p ~/.config
    cp -r alacritty ~/.config/
    cp -r bpytop ~/.config/
    cp -r htop ~/.config/
    cp -r hypr ~/.config/
    cp -r nvim ~/.config/
    cp -r waybar ~/.config/
    cp -r wofi ~/.config/
    cp starship.toml ~/.config/
    cp .zshrc ~/
    @echo "Installation complete!"

# Backup existing configs before installing
backup:
    #!/usr/bin/env bash
    BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup at $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"

    for dir in alacritty bpytop htop hypr nvim waybar wofi; do
        [ -d "$HOME/.config/$dir" ] && cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
    done

    [ -f "$HOME/.config/starship.toml" ] && cp "$HOME/.config/starship.toml" "$BACKUP_DIR/"
    [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/"

    echo "Backup complete at $BACKUP_DIR"
    echo "Now run 'just install' to install new configs"

# Backup and install in one step
update: backup install

# Remove installed configs (use with caution)
clean:
    #!/usr/bin/env bash
    echo "WARNING: This will remove installed configs!"
    read -p "Are you sure? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf ~/.config/{alacritty,bpytop,htop,hypr,nvim,waybar,wofi}
        rm -f ~/.config/starship.toml
        echo "Clean complete!"
    else
        echo "Aborted."
    fi

if status is-interactive
# Commands to run in interactive sessions can go here
end

function fish_greeting

end

# Custom prompt using Material You colors
# The $material_prompt_* variables are set in conf.d/material_you_colors.fish
function fish_prompt
    set_color $material_prompt_bracket
    echo -n "┌─("

    set_color $material_prompt_username
    echo -n (whoami)

    set_color $material_prompt_hostname
    echo -n "@" (prompt_hostname)

    set_color $material_prompt_bracket
    echo -n ")─["

    set_color $material_prompt_path
    echo -n (prompt_pwd)

    set_color $material_prompt_bracket
    echo -n "]"

    # Git branch (if exists)
    if command -q git
        set branch (git symbolic-ref --short HEAD 2>/dev/null)
        if test -n "$branch"
            set_color $material_prompt_git
            echo -n "   $branch"
        end
    end

    set_color $material_prompt_bracket
    echo
    echo -n "└─➤ "

    set_color normal
end

#SET PATH VARS
set -gx PATH $HOME/.local/bin $PATH
set -gx EDITOR "nvim"
set -gx PATH $PATH $HOME/go/bin

alias ls="eza --icons"
alias ll="eza -lah --icons"
alias cat="bat"
alias v="nvim"
alias ff="fastfetch"
alias nv="nvim"
alias fm="yazi"
alias top="btop"
alias hs="hyprshade on vibrance"
alias glow="glow ~/Documents/Docs"

starship init fish | source

ff
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk"

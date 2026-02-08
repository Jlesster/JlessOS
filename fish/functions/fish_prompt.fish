# Auto-generated Fish prompt (Material You theme)
# Uses dynamic color variables that update when theme changes

function fish_prompt
    # Save last status
    set -l last_status $status
    
    # Top line with username, hostname, and path
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
        set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
        if test -n "$branch"
            set_color $material_prompt_git
            echo -n "   $branch"
        end
    end
    
    # Bottom line with arrow
    set_color $material_prompt_bracket
    echo
    echo -n "└─➤ "
    
    set_color normal
end

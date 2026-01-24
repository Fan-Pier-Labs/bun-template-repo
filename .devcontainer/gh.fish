# GitHub CLI wrapper function for fish shell
# Automatically loads token from file if available
function gh --wraps=gh --description "GitHub CLI with automatic token loading"
    # Try to find token file in multiple locations
    set -l token_file ""
    
    # Check container location first
    if test -f /root/.local/config/gh/gh_token
        set token_file /root/.local/config/gh/gh_token
    # Check Mac location
    else if test -f ~/.config/gh/gh_token
        set token_file ~/.config/gh/gh_token
    end
    
    # Get the gh command path
    set -l gh_cmd (which gh)
    
    # If token file exists, use it
    if test -n "$token_file"
        set -l token (cat "$token_file" | tr -d '\n\r ')
        if test -n "$token"
            env GH_TOKEN="$token" $gh_cmd $argv
        else
            $gh_cmd $argv
        end
    else
        # No token file found, run gh normally
        $gh_cmd $argv
    end
end

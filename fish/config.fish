fzf --fish | source
starship init fish | source
zoxide init fish | source
# alias ls='exa --icons --group-directories-first  --time-style long-iso'
# alias ll='exa -l --icons --group-directories-first  --time-style long-iso'
# alias la='exa -l -a --icons --group-directories-first  --time-style long-iso'
alias vim='nvim'
alias cd='z'


# pyenv init
if command -v pyenv 1>/dev/null 2>&1
  pyenv init - | source
end

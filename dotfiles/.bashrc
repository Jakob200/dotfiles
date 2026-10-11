# ==============================================================================
# 1. Exit if not running interactively
# ==============================================================================
# If not running interactively (e.g., automated scripts), don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ==============================================================================
# 2. History & Shell Options
# ==============================================================================
# Append to the history file, don't overwrite it
shopt -s histappend

# Check the window size after each command and update LINES and COLUMNS
shopt -s checkwinsize

# History Control (Match Zsh settings)
export HISTCONTROL=ignoreboth
export HISTORY_IGNORE="(\&|[bf]g|c|clear|history|exit|q|pwd|* --help)"
export HISTSIZE=5000
export HISTFILESIZE=10000

# ==============================================================================
# 3. Colors & Prompt (PS1)
# ==============================================================================
# Enable color support for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# A clean, colored prompt: user@host:~/current/dir$
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# ==============================================================================
# 4. Custom Aliases (Mirrored from your Zsh setup)
# ==============================================================================
alias make="make -j$(nproc 2>/dev/null || echo 1)"
alias ninja="ninja -j$(nproc 2>/dev/null || echo 1)"
alias n="ninja"
alias c="clear"

# Arch Linux specific (Will just sit dormant on Ubuntu/Debian containers)
alias rmpkg="sudo pacman -Rsn"
alias cleanch="sudo pacman -Scc"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias update="sudo pacman -Syu"
alias apt="man pacman"
alias apt-get="man pacman"
alias please="sudo"
alias tb="nc termbin.com 9999"
alias cleanup="sudo pacman -Rsn $(pacman -Qtdq 2>/dev/null) 2>/dev/null"
alias jctl="journalctl -p 3 -xb"
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# Optional: If you eventually want to stop copying/pasting aliases between
# .bashrc and .zshrc, you can put them all in a ~/.bash_aliases file and 
# uncomment the lines below to load them automatically.
# if [ -f ~/.bash_aliases ]; then
#     . ~/.bash_aliases
# fi
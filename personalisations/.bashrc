
#Sensible Bash Stuff (http://mrzool.cc/writing/sensible-bash/)
alias refresh='source ~/.bashrc'

#Command completion stuff lives in .inputrc

# Append to the history file, don't overwrite it
shopt -s histappend

# Save multi-line commands as one command
shopt -s cmdhist

# Record each line as it gets issued
PROMPT_COMMAND='history -a'

# Huge history. Doesn't appear to slow things down, so why not?
HISTSIZE=500000
HISTFILESIZE=100000

# Avoid duplicate entries
HISTCONTROL="erasedups:ignoreboth"

# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history"

# Useful timestamp format
HISTTIMEFORMAT='%F %T '

#Improved Directory Navigation
shopt -s autocd
shopt -s dirspell
shopt -s cdspell
shopt -s cdable_vars

export ljobs="$HOME/ljobs"
export docker="$HOME/Docker"
export programs="$HOME/Programs"
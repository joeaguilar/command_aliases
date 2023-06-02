echo "Loading configurations for "$OSTYPE


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        #ubuntu windows subsystem reports this
        # ...
elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        alias l="ls -cl -hp --color=always"
elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
else
         alias l="ls -cl -hp --time-style=long-iso --group-directories-first --color=always"
        # Unknown.
fi;



alias .s='source ~/bash_profile'
alias where='pwd | sed -En "s/(.*)/\n\1\n/p"'
alias nowdate='date +"%d-%m-%Y'
alias nowtime='date +"%T"'

#look
alias ll='ls -hAlTFtri'
alias ln='ls -hAlTFtrin'
alias ld='ls -dAlTF'
alias lt='ls -hAlTFrt'
alias lr='ls -hAlTFr'

alias path='echo -e ${PATH//:/\\n}'
alias tree='tree -I ".git|node_modules"'
alias free="free -mt"
alias df="df -Tha --total"
alias ps="ps auxf"

#use like function
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"


#node
alias node18='nodenv shell 18.21.1'

#git
alias gs='git status'
alias gf='git fetch'
alias gsp='git status --porcelain'
alias gla='git log --author'
alias gg='git log --graph --all --oneline --decorate'
alias gl='git log --oneline --decorate'
alias gd='git diff'
alias gds='git diff --staged'
alias gdl='git diff --color-words'
alias gdls='git diff --color-words --staged'
alias gco='git checkout'
alias gad='git add'
alias gap='git add -p'
alias gup='git restore --staged -p'
alias gun='git restore --staged'
alias grs='git reset'
alias grss='git reset --soft'
alias gst='git stash'
alias gstl='git stash list'
alias gsh='git show --color-words'
alias gb='git branch'
alias gbm='git branch --merged'
alias gbn='git branch --no-merged'

#git advanced - watching unwatching files
alias gitskiplist='git ls-files -v|grep "^S"'
gitskip() {git update-index --skip-worktree "$@"; git ls-files -v|grep '^S'; }
gitskip() {git update-index --no-skip-worktree "$@"; git ls-files -v|grep '^S'; }


#traversal
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'


#install node on M1 mac
function installM1Node() {
    if [[ $1 =~ ..\..\.. ]]
    then
        arch -x86_64 nodenv install $1
    else
        echo "Not a valid Node version"
    fi;\
};


function setNodeVersion() {
    NODE_VERSION=$(node -v);
    echo "Setting node globals to " $NODE_VERSION;
    export PATH=$PATH:~/.nodenv/versions/"$NODE_VERSION"/lib/node_modules"
}



echo 'loading bash_profile'


alias whichshell='echo $SHELL'

#load
alias .s='source ~/.bash_profile'
alias .p='echo $PATH'
alias where='pwd | sed -En "s/(.*)/\n\1\n/p"'

#traversal
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias _='cd'

#date
alias nowdate='date +"%d-%m-%Y'
alias nowtime='date +"%T"'

#stats
alias cpu='sysctl -a|grep brand'


#look
alias l='lsd -hAlFtri'
alias ll='ls -hAlTFtri'
alias ln='ls -hAlTFtrin'
alias ld='ls -dAlTF'
alias lt='ls -hAlTFrt'
alias lr='ls -hAlTFr'

#sudo alias fix
alias sudo='sudo '

#hidden files
alias showhidden="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidehidden="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# URL-encode strings
# alias urlencode='python2 -c "import sys, urllib as ul; print(ul.quote_plus(sys.argv[1]));"'
alias urlencode='node -e "console.log(encodeURIComponent(process.argv[1]));"'
alias urldecode='node -e "console.log(decodeURIComponent(process.argv[1]));"'

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
alias gi='git init'

#git advanced - watching unwatching files
alias gitskiplist='git ls-files -v|grep "^S"'
gitskip() { git update-index --skip-worktree "$@"; git ls-files -v|grep '^S'; }
gitskip() { git update-index --no-skip-worktree "$@"; git ls-files -v|grep '^S'; }

alias gohome='cd ~/'
alias gohome='cd ~/'
alias gopro='cd ~/Projects'
alias godown='cd ~/Downloads'

#copy
alias c="tr -d '\n' | pbcopy"

#update
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; npm install npm -g; npm update -g;'

#ip
alias localip0="ipconfig getifaddr en0"
alias localip1="ipconfig getifaddr en1"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

#map
alias map="xargs -n1"

# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"


#lock
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

alias path='echo -e ${PATH//:/\\n}'

#install node on M1 mac
function installM1Node() {
    if [[ $1 =~ ..\..\.. ]]
    then
        arch -x86_64 nodenv install $1
    else 
        echo "Not a valid Node version"
    fi
}


#clean desktop
function cleandesktop () {
    dest="/Users/$USER/ScreenCaptures/"
    if [ ! -d $dest ];then   
        mkdir $dest 
    fi
    mv "/Users/$USER/Desktop/"*Screen* "$dest"
}

function setNodeVersion() {
    NODE_VERSION=$(node -v);
    echo "Setting node globals to " $NODE_VERSION;
    export PATH=$PATH:~/.nodenv/versions/"$NODE_VERSION"/lib/node_modules
}

# Extra many types of compressed packages
# Credit: http://nparikh.org/notes/zshrc.txt
function extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)  tar -jxvf "$1"                        ;;
      *.tar.gz)   tar -zxvf "$1"                        ;;
      *.bz2)      bunzip2 "$1"                          ;;
      *.dmg)      hdiutil mount "$1"                    ;;
      *.gz)       gunzip "$1"                           ;;
      *.tar)      tar -xvf "$1"                         ;;
      *.tbz2)     tar -jxvf "$1"                        ;;
      *.tgz)      tar -zxvf "$1"                        ;;
      *.zip)      unzip "$1"                            ;;
      *.ZIP)      unzip "$1"                            ;;
      *.pax)      cat "$1" | pax -r                     ;;
      *.pax.Z)    uncompress "$1" --stdout | pax -r     ;;
      *.Z)        uncompress "$1"                       ;;
      *) echo "'$1' cannot be extracted/mounted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file to extract"
  fi
}

# Create a new directory and enter it
function mkd() {
    mkdir -p "$@" && cd "$_";
}

function mkcd()
{
    mkdir $1 && cd $1
}


echo "bash_profile loaded"
##
# fuzzy search for process to kill
##
fkill() {
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    kill -${1:-9} $pid
  fi
}

##
# fuzzy search (grep) in file
##
fgrep() {
    tac $1 | fzf
}

##
# fuzzy search for git refs to checkout
##
fgco() {
  local branch
  branch=$(git for-each-ref --format="%(refname:short)" | fzf +s +m) &&
  git checkout $(echo "$branch" | sed "s/.* //")
}

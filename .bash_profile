# Reset (uncommit) last commit
#
function resetLastCommit()
{
	git reset HEAD^
}

# 
# Convert the last commit to a stash with same name as commit message and a number prefix
# 
# @param $1 => Number Prefix - goes in front of the stash name
# 
function commitToStash()
{
	# Require COMMIT_PREFIX variable
	if (( "$#" != 1 ))
	then
		echo "Usage: stashLastCommit <\$COMMIT_PREFIX>"
		return
	fi

	# get name of last commit and copy
	COMMIT_MSG=$(git log -1 --pretty=%B | xargs echo -n)
	COMMIT_PREFIX=$1

	# Uncommit last commit
	git reset HEAD^

	# Stash last commit's changes, inc. untracked, with commit messsage
	git stash save -u $COMMIT_PREFIX: $COMMIT_MSG 
}

# 
# Convert the top stash to a commit, retaining message, minus number prefix
# 
function stashToCommit()
{
	echo "Not implemented"

	return
}

# 
# Get the commit hash of the parrent commit
# 
# using this in a rebase is equivalent to SHA^ ... '-_-
# 
function parentCommitHash()
{
	# Default to HEAD if hash not passed
	if (( "$#" != 1 ))
	then
		COMMIT_HASH="HEAD"
	else
		COMMIT_HASH=$1
	fi

	FULL_HASH=$(git log --pretty=%H -n 1 $COMMIT_HASH | xargs echo -n)
	FULL_HASH_ABBR=$(git log --pretty=%h -n 1 $COMMIT_HASH | xargs echo -n)
	
	# Consider this could be HASHES, i guess for merge commits
	PARENT_HASH=$(git log --pretty=%P -n 1 $COMMIT_HASH | xargs echo -n)
	PARENT_HASH_ABBR=$(git log --pretty=%p -n 1 $COMMIT_HASH | xargs echo -n)

	# echo "child:  " $FULL_HASH '('$FULL_HASH_ABBR')'
	# echo "parent: " $PARENT_HASH '('$PARENT_HASH_ABBR')'
	echo $PARENT_HASH_ABBR
	return
}

# git stash apply $(git stash list | awk -F: --posix -vpat=\"$*\" \"$ 0 ~ pat {print $ 1; exit}\");

#
# Fixup a single line 
# 
# usage: fixupLine <lineNumber> <fileName>
#
function fixupLine()
{
	if (( "$#" != 2 )); then
		echo "Usage: fixupLine <lineNumber> <fileName>"
	fi

	LINE_NUMBER=$1
	FILE_NAME=$2

	ACTION="next"
	SKIP=0

	while [[ $ACTION != "quit" ]]
	do
		COMMIT=$(git log --pretty='%H' -n 1 --skip=$SKIP -u -L $LINE_NUMBER,$LINE_NUMBER:$FILE_NAME | head -n1 | xargs echo -n)

		echo "Last commit was $COMMIT"
		read -p "What would you like to do? [next, prev, info, commit, quit]: " ACTION

		if [[ $ACTION == "info" ]]; then
			# Doesn't seem to work for previous commits... filename changed...
			# set new filename here if it changes?
			git log -p --follow -n 1 $COMMIT -- $FILE_NAME
		fi

		if [[ $ACTION == "next" ]]; then
			SKIP=$[$SKIP +1]
		fi

		if [[ $ACTION == "prev" ]]; then
			SKIP=$[$SKIP -1]
		fi
	done

	echo "FINISHED"

	return
}

function la() {
 	ls -l  "$@" | awk '
    {
      k=0;
      for (i=0;i<=8;i++)
        k+=((substr($1,i+2,1)~/[rwx]/) *2^(8-i));
      if (k)
        printf("%0o ",k);
      printf(" %9s  %3s %2s %5s  %6s  %s %s %s\n", $3, $6, $7, $8, $5, $9,$10, $11);
    }'
}

alias phpunit='./vendor/bin/phpunit --stop-on-fail --stop-on-error'
alias ll='ls -la'
alias ..='cd ..'
alias tinker='php artisan tinker'
alias resetCamera='sudo killall VDCAssistant && sudo killall AppleCameraAssistant'

export GIT_EDITOR=nano
export VISUAL=nano

export PATH=:"/usr/local/sbin:$PATH"
export PATH="$(brew --prefix homebrew/php/php71)/bin:$PATH"
export PATH="~/.composer/vendor/bin:$PATH"

export HISTCONTROL=ignoreboth:erasedups

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

HISTSIZE=10000
HISTFILESIZE=20000

if [[ "$OSTYPE" = "Darwin"* ]]; then
	alias tmux='tmux -f ~/.tmux-macos.conf'
fi

export TERM="xterm-color"
export PS1='\[\e[0;33m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ '

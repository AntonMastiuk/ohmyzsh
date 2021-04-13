function my_git_prompt() {
  tester=$(git rev-parse --git-dir 2> /dev/null) || return
  
  INDEX=$(git status --porcelain 2> /dev/null)
  STATUS=""

  # is branch ahead?
  if $(echo "$(git log origin/$(git_current_branch)..HEAD 2> /dev/null)" | grep '^commit' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD$(git_commits_ahead) "
  fi

  # is branch behind?
  if $(echo "$(git log HEAD..origin/$(git_current_branch) 2> /dev/null)" | grep '^commit' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_BEHIND$(git_commits_behind) "
  fi

  # is anything staged?
  if $(echo "$INDEX" | command grep -E -e '^(D[ M]|[MARC][ MD]) ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED$(echo "$INDEX" | command grep -E -e '^(D[ M]|[MARC][ MD]) ' | wc -l) "
  fi

  # is anything unstaged?
  if $(echo "$INDEX" | command grep -E -e '^[ MARC][MD] ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED$(echo "$INDEX" | command grep -E -e '^[ MARC][MD] ' | wc -l) "
  fi

  # is anything untracked?
  if $(echo "$INDEX" | grep '^?? ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED$(echo "$INDEX" | grep '^?? ' | wc -l) "
  fi

  # is anything unmerged?
  if $(echo "$INDEX" | command grep -E -e '^(A[AU]|D[DU]|U[ADU]) ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED$(echo "$INDEX" | command grep -E -e '^(A[AU]|D[DU]|U[ADU]) ' | wc -l) "
  fi

  if [[ -n $STATUS ]]; then
    STATUS=" $STATUS"
  fi

  echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(my_current_branch)$STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

function my_current_branch() {
  echo $(git_current_branch || echo "(no branch)")
}

function ssh_connection() {
  if [[ -n $SSH_CONNECTION ]]; then
    echo "%{$fg_bold[red]%}(ssh) "
  fi
}

print_current_dir() {
  if [ "$HOME" = "$(pwd)" ]; then
    echo '\uf7db %(4~|.../%3~|%~) '
  else
    is_git=$(git rev-parse --git-dir 2> /dev/null) || false
    if [ $is_git ]; then
      echo '\uf7a1 %(4~|.../%3~|%~) '
    else
      echo '\ufc6e %(4~|.../%3~|%~) '
    fi
  fi
}


local ret_status="%(?:%{$fg_bold[green]$(echo "\uf62b ")%}:%{$fg_bold[red]$(echo "\uf655 ")%})%?%{$reset_color%}"
PROMPT=$'$(echo "\uE712") %{$fg_bold[green]%}$(print_current_dir)%{$reset_color%}$(my_git_prompt)$(echo "\uf64f") %{$fg_bold[cyan]%}[%*]%{$reset_color%} ${ret_status} \n❯ '

ZSH_THEME_PROMPT_RETURNCODE_PREFIX="%{$fg_bold[red]%}"
ZSH_THEME_GIT_PROMPT_PREFIX="on %{$fg_bold[yellow]%}\uf418 "
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[magenta]%}↑%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_bold[green]%}↓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}+%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[red]%}!%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[white]%}?%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[red]%}✕%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"

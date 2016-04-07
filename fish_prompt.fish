# Initialize glyphs to be used in the prompt.
set -q chain_prompt_glyph
  or set -g chain_prompt_glyph "»"
set -q chain_git_branch_glyph
  or set -g chain_git_branch_glyph "⎇ "
set -q chain_git_dirty_glyph
  or set -g chain_git_dirty_glyph "±"
set -q chain_su_glyph
  or set -g chain_su_glyph "#"

function __chain_prompt_segment
  set_color $argv[1]
  echo -n -s "[" $argv[2..-1] "] "
  set_color normal
end

function __chain_right_prompt_segment
  set_color $argv[1]
  echo -n -s " [" $argv[2..-1] "]"
  set_color normal
end

function __chain_git_branch_name
  echo (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end

function __chain_is_git_dirty
  echo (command git status -s --ignore-submodules=dirty ^/dev/null)
end

function __chain_virtualenv
  if set -q VIRTUAL_ENV
    set -l venvname (basename "$VIRTUAL_ENV")
    __chain_right_prompt_segment white "($venvname)"
  end
end

## Show user if not default
function __chain_show_user
  if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
    set -l host (hostname -s)
    set -l who (whoami)
    __chain_prompt_segment green "$who@$host"
  end
end

function __chain_prompt_dir
  __chain_prompt_segment cyan (prompt_pwd)
end

function __chain_prompt_git
  if test (__chain_git_branch_name)
    if test (__chain_is_git_dirty)
      set -l dirty (command git status -s --ignore-submodules=dirty | wc -l | sed -e 's/^ *//' -e 's/ *$//' 2> /dev/null)
      __chain_right_prompt_segment d75f00 "$dirty$chain_git_dirty_glyph"
    end
    set -l SHA (command git rev-parse --short HEAD 2> /dev/null)
    test $SHA; and __chain_right_prompt_segment yellow $SHA
    set -l git_branch (__chain_git_branch_name)
    __chain_right_prompt_segment blue "$chain_git_branch_glyph $git_branch"
  end
end

function __chain_prompt_arrow
  if test $last_status = 0
    set_color green
    echo ""
  else
    set_color red
    echo "($last_status)"
  end

  set -l uid (id -u $USER)
  if test $uid -eq 0
    set -g current_arrow_glyph $chain_su_glyph
    set_color yellow
  else
    set -g current_arrow_glyph $chain_prompt_glyph
    set_color cyan
  end

  echo -n "$current_arrow_glyph "
end

function fish_prompt
  set -g last_status $status

  __chain_show_user
  __chain_prompt_dir
  __chain_prompt_arrow
end

function fish_right_prompt
  type -q git; and __chain_prompt_git
  __chain_virtualenv
end

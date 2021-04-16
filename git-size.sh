#!/bin/bash
set -e
# originally based on https://stackoverflow.com/a/10847242/545346
# CC-BY-SA 3.0

git fetch --tags

max_size=${PLUGIN_MAX_SIZE:-102400}
old=origin/$DRONE_REPO_BRANCH
new='HEAD'

echo "Comparing HEAD to $old"

args=$(git rev-parse --sq $old $new)

eval "git diff-tree -r $args" | {
  total=0
  while read A B C D M P
  do
    case $M in
      M) bytes=$(( $(git cat-file -s $D) - $(git cat-file -s $C) )) ;;
      A) bytes=$(git cat-file -s $D) ;;
      D) bytes=-$(git cat-file -s $C) ;;
      *)
        echo >&2 warning: unhandled mode $M in \"$A $B $C $D $M $P\"
        continue
        ;;
    esac
    total=$(( $total + $bytes ))
    printf '%d\t%s\n' $bytes "$P"
  done
  echo total $total

  if [ "$total" -gt "$max_size" ]; then
      echo "Size difference between $1 and $2 larger than $max_size bytes: Failing"
      echo "Make sure you are not adding large (binary) files to the repo; Check with IT for more info."
      exit $total
fi

}

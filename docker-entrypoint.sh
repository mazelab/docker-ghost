#!/bin/bash
set -e

if [[ "$*" == npm*start* ]]; then
	for dir in "$GHOST_SOURCE/content"/*/; do
		targetDir="$GHOST_CONTENT/$(basename "$dir")"
		mkdir -p "$targetDir"
		if [ -z "$(ls -A "$targetDir")" ]; then
      cp -r $dir* $targetDir/.
		fi
	done

	if [ ! -e "$GHOST_CONTENT/config.js" ]; then
		sed -r '
			s/127\.0\.0\.1/0.0.0.0/g;
			s!path.join\(__dirname, (.)/content!path.join(process.env.GHOST_CONTENT, \1!g;
		' "$GHOST_SOURCE/config.example.js" > "$GHOST_CONTENT/config.js"
	fi

	ln -sf "$GHOST_CONTENT/config.js" "$GHOST_SOURCE/config.js"

  # ensure correct permissions
  GHOST_UID=`ls -ldn $GHOST_CONTENT | awk '{print $3}'`
  MAPPED_USER=`getent passwd $GHOST_UID | awk -F':' '{print $1}'`
  GHOST_USER="user"

  if [ -z "$MAPPED_USER" ]; then
    usermod -u $GHOST_UID user
  elif [ "$MAPPED_USER" != "user" ]; then
    GHOST_USER="$MAPPED_USER"
  fi

	set -- gosu $GHOST_USER "$@"
fi

exec "$@"
.PHONY: build run

build:
	sudo docker build --rm=true -t mazelab/ghost .

run:
	sudo docker run -tiP --rm=true -v /home/marcel/eintopf/ghost/:/var/lib/ghost/ --name ghost -e GHOST_URL="http://ghost.dev"  mazelab/ghost /bin/bash

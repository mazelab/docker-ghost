.PHONY: build run

build:
	sudo docker build --rm=true -t mazelab/ghost .

run:
	sudo docker run -ti --rm=true -p 32777:2368 --name ghost -e GHOST_URL="http://localhost:32777"  mazelab/ghost

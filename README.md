# docker-ghost
Docker image that allows running [Ghost](https://github.com/TryGhost/Ghost) in production mode,
and is a bit more configurable than the [official Ghost Docker image](https://registry.hub.docker.com/_/ghost/).

forked from [ptimof/docker-ghost](https://github.com/ptimof/docker-ghost)

## Why yet another container for Ghost?

The official container for Ghost is fine for running in development mode, but it has the wrong
permissions for running in production. That, and the config file doesn't have any easy way to tweak
it.

This container uses the official Ghost image as it's base, has a more "environment aware"
`config.js` file, and uses these environment variables to tune the config.

## Quickstart

```
docker run --name some-ghost -d mazelab/ghost
```

This will start Ghost in development mode listening on the default port of 2368.

If you'd like to be able to access the instance from the host without the
contain's IP, standard port mappings can be used:

```
docker run --name some-ghost -p 8080:2368 -d mazelab/ghost
```

Then, access it via `http://localhost:8080` or `http://host-ip:8080` in a browser.

## Configuration

There are three environment variables that can be configured:

* `GHOST_URL`: the URL of your blog (e.g., `http://www.example.com`)
* `MAIL_FROM`: the email of the blog installation (e.g., `'"Webmaster" <webmaster@example.com>'`)
* `MAIL_HOST`: which host to send email to (e.g., `mail.example.com`)

These can either be set on the Docker command line directly, or stored in a file and passed on
the Docker command line:

```
sudo cp ghost.example.env /etc/default/ghost
sudo vi /etc/default/ghost
docker run --name some-ghost --env-file /etc/default/ghost -p 8080:2368 -d mazelab/ghost
```

If you have just pulled the Docker image with `docker pull mazelab/ghost`, the example
environment file looks like this:

```
# Ghost environment
# Place in /etc/default/ghost

GHOST_URL=http://www.example.com
MAIL_FROM='"Webmaster" <webmaster@example.com>'
MAIL_HOST=mail.example.com
```

## Running in production

The official Ghost image places the blog content in `/var/lib/ghost` and exports it as a `VOLUME`.
This allows two main modes of operation:

### Content on host filesystem

In this mode, the Ghost blog content lives on the filesystem of the host. Create a directory somewhere, and use the `-v` Docker command
line option to mount it:

```
mkdir -p /var/lib/ghost
docker run --name some-ghost --env-file /etc/default/ghost -p 80:2368 -v /var/lib/ghost:/var/lib/ghost -d mazelab/ghost npm start --production
```

### Content in a data volume

This is the preferred mechanism to store the blog data. Please see the
[Docker documentation](https://docs.docker.com/userguide/dockervolumes/#backup-restore-or-migrate-data-volumes)
for backup, restore, and migration strategies.

```
docker create -v /var/lib/ghost --name some-ghost-content busybox
docker run --name some-ghost --env-file /etc/default/ghost -p 80:2368 --volumes-from some-ghost-content -d mazelab/ghost npm start --production
```

You should now be able to access this instance as `http://www.example.com` in a browser.

### Behind a reverse proxy

Of course, you should really be running Ghost behind a reverse proxy, and set things up to auto restart. For that,
a reasonable container would be:

```
docker create --name some-ghost -h ghost.example.com --env-file /etc/default/ghost -p 127.0.0.1:2368:2368 --volumes-from some-ghost-content --restart=on-failure:10 mazelab/ghost npm start --production
docker run some-ghost
```

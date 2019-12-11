# HG to GIT migration tool

This docker image will help you to migrate from Mercurial to Git

## How to Run

First you need to put all yours mercurial repositories in one place, lets say /tmp/mercurial/. Then create an empty folder to store the git repositories /tmp/git/.

The next step, just run the container with the appropriates commands:

```
docker run \
--volume [/your/hg/repositories/path/]:/hg-repositories \
--volume [/your/empty/output/folder/]:/git-repositories \
ralexsander/hg-git-migration [prepare,migrate,bash]
```

```prepare``` - Creates the map files for sanitization of branches, tags and authors names.  
```migrate``` - Perform the migration  
```bash``` - Shell access to container

Example, first run (if you don't need to sanitize the repository, you can skip this step):

```
docker run \
--volume /tmp/mercurial:/hg-repositories \
--volume /tmp/git:/git-repositories \
ralexsander/hg-git-migration prepare
```

This will create map files, so you can change author, branch and tag names. 
Do the changes you need to files /tmp/mercurial/hg.authors.map etc.
After that just run:

```
docker run \
--volume /tmp/mercurial:/hg-repositories \
--volume /tmp/git:/git-repositories \
ralexsander/hg-git-migration migrate
```

## Links

Docker: https://hub.docker.com/r/ralexsander/hg-git-migration  
Github: https://github.com/ralexsander/docker-hg-git-migration

## Motivations

BitBucket stop supporting mercurial repositories, so I need a way to make sure all repositories was migrated the same way.

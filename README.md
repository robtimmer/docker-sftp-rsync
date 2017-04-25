# robtimmer/sftp-rsync

To launch it and have your share listen on port 2022, just type:

```
docker run -d -p 2022:22 -e USER=myuser -e PASS=myverysecretpassword -e GROUP_GID=33 robtimmer/sftp-rsync
```

Hint: GROUP_GID can be any valid group id (that has already being created)

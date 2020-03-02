WARNING! This will remove:

- all stopped containers
- all networks not used by at least one container
- all images without at least one container associated to them
- all build cache

```bash
~/> docker system prune --all --force
```

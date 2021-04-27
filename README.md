# Docker Endpoint for DRILL

Part of RAKI D6.1

To Build using your Private SSH Key `~/.ssh/id_rsa`,

```
docker build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" .
```


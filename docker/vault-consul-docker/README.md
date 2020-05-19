# Managing Secrets with Vault and Consul

## Main dependencies

* Docker v19.03.8
* Docker-Compose v1.25.4
* Vault v1.4.1
* Consul v1.7.3

> **_NOTE:_**  Image based on alpine v3.11.6

## Want to learn how to build this?

Check out the [post](https://testdriven.io/managing-secrets-with-vault-and-consul).

## Want to use this project?

1. Fork/Clone

1. Build the images and run the containers:

    ```sh
    $ docker-compose up -d --build
    ```

1. You can now interact with both Vault and Consul. View the UIs at [http://localhost:8200/ui](http://localhost:8200/ui) and [http://localhost:8500/ui](http://localhost:8500/ui).

## Notes & commands

### To start

```bash
docker-compose up -d --build
```

### To stop & remove containers

```bash
docker-compose down

# If we want restart from scratch
# sudo rm -rf consul/data/*
```

### To enter consul container

```bash
docker-compose exec consul bash
```

### Commands for consul

#### Via UI

See [http://localhost:8500/ui](http://localhost:8500/ui)

### To enter vault container

```bash
docker-compose exec vault bash
```

### Commands for vault

#### Via SHELL

##### First execution

```bash
# Init
bash-5.0# vault operator init

# Unseal
bash-5.0# vault operator unseal

# Authenticate
bash-5.0# vault login
```

##### Play with vault

```bash
# Enable secrets
bash-5.0# vault secrets enable kv

# Add a new static secret
bash-5.0# vault kv put kv/foo bar=precious

# Read it back
bash-5.0# vault kv get kv/foo

# Enable versionning for secrets kv
bash-5.0# vault kv enable-versioning kv/

# Add version 2 by updating the value to copper
bash-5.0# vault kv put kv/foo bar=copper

# Read version 1
bash-5.0# vault kv get -version=1 kv/foo

# Read version 2
bash-5.0# vault kv get -version=2 kv/foo

# Soft delete the latest version (eg: version 2)
bash-5.0# vault kv delete kv/foo

# Soft delete version 1
bash-5.0# vault kv delete -versions=1 kv/foo

# Undelete as well (eg: v1 & v2)
bash-5.0# vault kv undelete -versions=1 kv/foo
bash-5.0# vault kv undelete -versions=2 kv/foo

# Hard delete kv => destroy (eg: v1 only)
bash-5.0# vault kv destroy -versions=1 kv/foo
```

#### Via API

```bash
export VAULT_TOKEN=<your_token_goes_here>

# Create a new secret called foo with a value of world

$ curl \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    -d '{ "data": { "foo": "world" } }' \
    http://127.0.0.1:8200/v1/kv/data/hello

# Read the secret

$ curl \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -X GET \
    http://127.0.0.1:8200/v1/kv/data/hello
```

#### Via UI

See [http://localhost:8200/ui](http://localhost:8200/ui)

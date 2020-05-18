# dcos-riak

This project implements a minimal DC/OS framework based on the `docker-riak` image found here: https://github.com/nilium/docker-riak

## Creating this project

```
dcosdev operator new riak 0.55.2
```

## Configuring your DC/OS cluster

```
export MINIO_HOST=<minio host>
dcosdev up
dcos package repo remove riak-repo
dcos package repo add riak-repo --index=0 <minio host>/artifacts/riak/riak-repo.json
```

## Installing

```
dcos package install riak --yes
```

## Usage

Riak CLI command reference can be found here: https://docs.riak.com/riak/kv/latest/using/admin/riak-cli/index.html

```
dcos task exec -it riak-0-node riak ping
```

Riak-Admin CLI command reference can be found here: https://docs.riak.com/riak/kv/latest/using/admin/riak-admin/index.html

```
dcos task exec -it riak-0-node riak-admin cluster status
```
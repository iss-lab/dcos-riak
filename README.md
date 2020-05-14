# dcos-riak

This project implements a minimal DC/OS framework based on the `docker-riak` image found here: https://github.com/nilium/docker-riak

## Creating this project

```
export MINIO_HOST=<minio host>
dcosdev operator new riak 0.55.2
```

## Configuring your DC/OS cluster

```
dcosdev up
dcos package repo remove riak-repo
dcos package repo add riak-repo --index=0 http://vsna-uat-dcb001.ad.issgovernance.com:9000/artifacts/riak/riak-repo.json
```

## Installing

```
dcos package install riak --yes
```
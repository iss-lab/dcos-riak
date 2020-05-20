# dcos-riak

This project implements a minimal DC/OS framework based on the `docker-riak` image found here: https://github.com/nilium/docker-riak

## DC/OS Setup

```
dcos package repo add riak-repo --index=0 https://github.com/iss-lab/dcos-riak/releases/download/v2.9.2/riak-repo.json
```

## Installing

Create an `options.json` file similar to the following:

```
{
  "service": {
    "name": "riak"
  },
  "node": {
    "count": 3,
    "cpus": 4,
    "mem": 4096,
    "disk": 10000
  },
  "riak": {
    "RIAK_RING_SIZE": "64",
    "RIAK_ERLANG_SCHEDULERS_TOTAL": "4",
    "ADVCFG_CLUSTERMGR_PORT": "9080",
    "ERL_EPMD_PORT": "24369",
    "RIAK_ERLANG_DISTRIBUTION_PORT_RANGE_MAXIMUM": "21347",
    "RIAK_ERLANG_DISTRIBUTION_PORT_RANGE_MINIMUM": "21347",
    "RIAK_LISTENER_HTTPS_INTERNAL_PORT": "8099",
    "RIAK_LISTENER_HTTP_INTERNAL_PORT": "8098",
    "RIAK_LISTENER_PROTOBUF_INTERNAL_PORT": "8087",
    "RIAK_SEARCH_SOLR_JMX_PORT": "8985",
    "RIAK_SEARCH_SOLR_PORT": "8093"
  }
}
```

NOTE: The `riak.RIAK_ERLANG_SCHEDULERS_TOTAL` should match the `node.cpus` value.
NOTE: The `riak.RIAK_RING_SIZE` value is 64 by default. General guidelines for sizing:

* Nodes: `3`, Ring Size: `64`-`128`
* Nodes: `5`, Ring Size: `128`-`256`
* Nodes: `7+`, Ring Size: `256`-`512`

```
dcos package install riak --yes --options=options.json
```

## Cluster setup

Join node 1 to node 0:

```
dcos task exec -it riak-1-node node-connect.sh riak-0-node
```

Wait for transfers to complete:

```
dcos task exec -it riak-1-node riak-admin transfers
```

Join node 2 to node 0:

```
dcos task exec -it riak-2-node node-connect.sh riak-0-node
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

### Finding Endpoints

List endpoints:

```
dcos riak endpoints
[
  "clustermgr",
  "disterl",
  "epmd",
  "http",
  "protobuf",
  "solr",
  "solr-jmx"
]
```

Find DNS for HTTP endpoint:

```
dcos riak endpoints http
{
  "address": [
    "10.XXX.XX.XX1:8098",
    "10.XXX.XX.XX2:8098",
    "10.XXX.XX.XX3:8098"
  ],
  "dns": [
    "riak-0-node.riak.autoip.dcos.thisdcos.directory:8098",
    "riak-1-node.riak.autoip.dcos.thisdcos.directory:8098",
    "riak-2-node.riak.autoip.dcos.thisdcos.directory:8098"
  ],
  "vip": "riak-http.riak.l4lb.thisdcos.directory:8098"
}
```

NOTE: The vip is a load balanced address that will work within the cluster.

### Writing and Reading Objects

Write:

```
curl -XPUT \
  -H "Content-Type: text/plain" \
  -d "vroom" \
  'http://riak-http.riak.l4lb.thisdcos.directory:8098/types/default/buckets/dodge/keys/viper?w=3'
```

Read:

```
curl -XGET 'http://riak-http.riak.l4lb.thisdcos.directory:8098/types/default/buckets/dodge/keys/viper?r=3'
```

## Development

### Creating this project

```
dcosdev operator new riak 0.55.2
```

### Configuring your DC/OS cluster

```
export MINIO_HOST=<minio host>
dcosdev up
dcos package repo remove riak-repo
dcos package repo add riak-repo --index=0 <minio host>/artifacts/riak/riak-repo.json
```

### Creating a github release

```
rm -f universe/riak-repo.json
dcosdev release 2.9.2 0 none
```

That command will fail, but it creates the correct `universe/riak-repo.json` which can be uploaded elsewhere, like Github.

```
GH_REPO="https://api.github.com/repos/iss-lab/dcos-riak"
GH_TAGS="$GH_REPO/releases/tags/v2.9.2"
AUTH="Authorization: token $github_api_token"
response=$(curl -sH "$AUTH" $GH_TAGS)
id=$(echo $response | jq .id)
GH_ASSET="https://uploads.github.com/repos/iss-lab/dcos-riak/releases/$id/assets"

curl --data-binary @"universe/riak-repo.json" -H "Authorization: token $github_api_token" -H "Content-Type: application/vnd.dcos.universe.repo+json;charset=utf-8;version=v4" "$GH_ASSET?name=riak-repo.json"

curl --data-binary @"svc.yml" -H "Authorization: token $github_api_token" -H "Content-Type: text/yaml" "$GH_ASSET?name=svc.yml"

curl --data-binary @"node-init.sh" -H "Authorization: token $github_api_token" -H "Content-Type: text/x-shellscript" "$GH_ASSET?name=node-init.sh"

curl --data-binary @"node-connect.sh" -H "Authorization: token $github_api_token" -H "Content-Type: text/x-shellscript" "$GH_ASSET?name=node-connect.sh"

curl --data-binary @"advanced.config.mustache" -H "Authorization: token $github_api_token" -H "Content-Type: text/plain" "$GH_ASSET?name=advanced.config.mustache"
```
#!/bin/bash
curl -X POST --data '{

    "jsonrpc": "2.0",

    "id" : 1,

    "method" : "info.isBootstrapped",

    "params": {

        "chain": "X"

    }

}' -H 'content-type:application/json;' 127.0.0.1:9650/ext/info
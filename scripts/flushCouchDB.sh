#!/usr/bin/env bash

# Enable debug mode (-x). Disable debug mode (+x)
set +x

: <<'END'
Author:      Peloton Team
Address:     5030 Sugarloaf Parkway
Address:     Lawrenceville, GA. 30044
e-Mail:      peloton@cisco.com

File:        flushCouchDB.sh
END

clear

FlushBuckets () {
    # Flush vsrm: csm_session bucket
        echo "Flushing csm_sessions bucket"
        curl -X POST -u cbAdministrator:cbPassword1234 couchbase-vsrm001.service.vci:8091/pools/default/buckets/csm_sessions/controller/doFlush
    # Flush vsrm:  crmobjects bucket
        echo "Flushing crmobjects bucket"
        curl -X POST -u cbAdministrator:cbPassword1234 couchbase-vsrm001.service.vci:8091/pools/default/buckets/crmobjects/controller/doFlush
}

## Flush csm_session and crmobjects buckets
FlushBuckets
echo "Waiting for CouchDB bucket flush..."
sleep 20


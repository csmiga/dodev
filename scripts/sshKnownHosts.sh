#!/usr/bin/env bash

# Enable debug mode (-x). Disable debug mode (+x)
set +x

: <<'END'
Author:      Christopher Smiga
Address:     5030 Sugarloaf Parkway
Address:     Lawrenceville, GA. 30044
e-Mail:      chsmiga@cisco.com

Team:        Peloton
Team eMail:  peloton@cisco.com

File:        sshKnownHosts.sh
END

clear

grep tsungWorker etc_hosts.db > .tmp
for HOST in $(cat .tmp)
do
    ssh -l nfptest -o StrictHostKeyChecking=no ${HOST} 'exit'
    echo 'Key gathered from '${HOST}
done

rm -f .tmp


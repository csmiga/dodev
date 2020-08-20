#!/usr/bin/env bash

# Enable debug mode (-x). Disable debug mode (+x)
set +x

: <<'END'
Author:      Peloton Team
Address:     5030 Sugarloaf Parkway
Address:     Lawrenceville, GA. 30044
e-Mail:      peloton@cisco.com

File:        runTsung.sh
END

clear

echo "Starting Tsung Load test ....."
#export https_proxy=http://proxy.esl.cisco.com:80
#export http_proxy=http://proxy.esl.cisco.com:80
#export tsung_clusters=True
#export headend=ontario
export headend=superior

echo "Checking Tsung status ....."

#  Verify that tsung test is not already running
CheckTsung () {
        TSTAT=`tsung status | grep -c not`
        if [ $TSTAT -eq 0 ]
        then
                echo "Tsung is already running a test ..... Aborting test run!"
                echo
                exit
        fi
}

cd ../performance_tests

## Smoke Test ##
#python start_test.py config_files/cocktail/aws_k_smoke_test_sprint_18_3_3.cfg

## Single API Test ##
python start_test.py config_files/cocktail/aws_k_stability_test-chsmiga.cfg


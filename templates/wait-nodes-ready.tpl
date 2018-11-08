#!/bin/sh -xe
# Run command repeatedly until it compltes without errors or retry ${max_tries} with a sleep interval of 0.25 seconds
cmd='kubectl get nodes --kubeconfig ${kubeconfig}'
iters=0
while true
    do
        if $cmd &> /dev/null; then
            status=$?
            break
        else
            status=$?
        fi
        if [ $${iters} -ge ${max_tries} ]; then
            break
        fi
        iters=$(($iters + 1))
        sleep .25
    done
exit $status
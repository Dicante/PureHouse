#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${cluster_name} ${bootstrap_extra_args}

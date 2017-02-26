#!/bin/bash

# Make sure dartfmt is run on everything
# This assumes you have dart_style as a dev_dependency

for module in modules/connection modules/objects modules/node modules/port_daemon 
do
  echo $module
  ( cd $module && tool/presubmit.sh )
done

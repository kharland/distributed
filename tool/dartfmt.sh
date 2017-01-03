#!/bin/bash

for module in modules/node modules/port_daemon
do
  (cd $module && pub run dart_style:format -w \
    $(find . -not -path '*/\.*' -name "*.dart"))
done

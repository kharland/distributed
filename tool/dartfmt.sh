#!/bin/bash

for module in modules/net modules/node modules/port_daemon modules/utils
do
  (cd $module && pub run dart_style:format -w \
    $(find . -not -path '*/\.*' -name "*.dart"))
done

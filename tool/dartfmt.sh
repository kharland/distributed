#!/bin/bash

pub run dart_style:format -w $(find . -not -path '*/\.*' -name "*.dart")
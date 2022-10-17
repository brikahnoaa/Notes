#!/bin/bash
awk '/PORT-D/ {print $10, $12, $13} /PARTD/ {print $9, $10}'


#!/bin/bash
while true
do
 foreman run rake check_for_new
 sleep 5
done
#!/bin/bash
# For UI to get output

cd ..
output=$(th gap/singlegap.lua)
echo $output

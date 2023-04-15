#!/bin/bash

# provide docker username and password

# read username and password
while getopts u:p: option
do
    case "${option}"
        in
        u)username=${OPTARG};;
        p)password=${OPTARG};;
    esac
done

echo "Username: $username";
echo "Username: $password";

# login into docker
sudo docker login --username $username --password $password

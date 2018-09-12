#!/bin/bash

# check that external connectivity is up
printf 'Waiting for internet connectivity'
until $(curl --output /dev/null --silent --head --fail https://google.com); do
    printf '.'
    sleep 5
done
echo

sudo yum update -y

sudo yum install -y httpd24

sudo service httpd start

echo "Welcome to" ${platform} " platform" >> /var/www/html/index.html
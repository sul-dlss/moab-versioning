#!/usr/bin/env bash

set -e

mkdir -p .binstubs
mkdir -p .gems
rm -f .binstubs/*
bundle install --binstubs .binstubs --path .gems/
bundle package --all --quiet

# see commentary on this practice at
# http://blog.howareyou.com/post/66375371138/ruby-apps-best-practices


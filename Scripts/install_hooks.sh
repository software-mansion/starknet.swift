#!/usr/bin/env bash

set -e

cp ./Hooks/pre-push ../.git/hooks/pre-push

chmod +x ../.git/hooks/pre-push

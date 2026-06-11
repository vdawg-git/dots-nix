#!/bin/env bash
set -o pipefail

atuin login
atuin sync
zoxide import atuin

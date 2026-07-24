#!/usr/bin/env pwsh
pwsh -Command @"
`$env:KST_DOCKER_MOUNT_PATH='..';
`$env:KST_DOCKERFILE_PATH='.';
`$env:KST_DOCKER_IMAGE_NAME='dev-nj-ksy';
`$env:KST_SINGLE_SOURCE='test_src';
& '$(Split-Path -Parent $MyInvocation.MyCommand.Definition)/kst/kst.ps1' $args
"@
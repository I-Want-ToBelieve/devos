{pkgs, ...}: ''
  #! /usr/bin/env bash
  #> Syntax: bash
  ${pkgs.sxhkd}/bin/sxhkd >/dev/null 2>&1
''

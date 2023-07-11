#
{pkgs, ...}: ''
    #! /usr/bin/env bash
    #> Syntax: bash
    ${pkgs.swhkd}/bin/swhks & pkexec ${pkgs.swhkd}/bin/swhkd --config /home/i.want.to.believe/.config/swhkd/swhkdrc -D "OBINS OBINS
  AnnePro2"
    ydotoold >/dev/null 2>&1
''

{pkgs, ...}:
# recommend using `hashedPassword`
{
  users.users.root.password = " ";
  users.users.root.shell = pkgs.bash;
}

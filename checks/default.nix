{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      pre-commit = {
        check.enable = true;
        settings = {
          package = pkgs.pre-commit;
          excludes = [ ];
          hooks = {
            nixfmt-rfc-style.enable = true;
            deadnix.enable = true;
            shellcheck.enable = true;
            trim-trailing-whitespace.enable = true;
            check-executables-have-shebangs.enable = true;
          };
        };
      };
    };
}

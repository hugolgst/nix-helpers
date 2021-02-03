with builtins;
# mkShellScriptDrv creates a derivation from a shell script
# You can specify the dependencies via `dependencies`.
# The content of the script shall be written in `script`.
# Writing inside `manual` will install a default 1 manual.
{ name, dependencies ? [ ], script, manual ? "" }:
  assert (name != null && script != null)
    || abort "mkShellScript needs name and script arguments";
  super.buildEnv {
    inherit name;
    paths = dependencies ++ [
      (super.writeShellScriptBin name script)
      (if manual == "" then
        null
      else
        (super.runCommand "man" { } ''
          runHook preInstall
          cat << 'EOF' > ${name}.1
          ${manual}
          EOF
          install -Dm644 -t $out/share/man/man1 ${name}.1
          runHook postInstall
        ''))
    ];
  }
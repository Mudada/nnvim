{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pigeons";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "n0-computer";
    repo = "pigeons";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dig5bYAxPPOM8YFR0IE9LCQqP/tF7J5FkPlWE9Zx4DA=";
  };

  cargoHash = "sha256-0fYPpP/pFtlG3Ws+nI1PWOcv1jbVQ1bERL439dCFDgA=";

  meta = {
    description = "ssh without ip";
    homepage = "https://github.com/n0-computer/pigeons";
    license = lib.licenses.mit;
    mainProgram = "pigeons";
  };
})

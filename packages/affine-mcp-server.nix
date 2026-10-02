{ buildNpmPackage, fetchFromGitHub, lib, nodejs }:

# Community MCP server for AFFiNE (databases, block-level edits, templates) — not in nixpkgs.
# Bump: change `version`, then refresh both hashes:
#   nix-prefetch-url --unpack https://github.com/DAWNCR0W/affine-mcp-server/archive/refs/tags/v<ver>.tar.gz
#     | xargs nix hash convert --hash-algo sha256 --to sri
#   curl -fsSO https://raw.githubusercontent.com/DAWNCR0W/affine-mcp-server/v<ver>/package-lock.json
#   nix run nixpkgs#prefetch-npm-deps -- package-lock.json
buildNpmPackage rec {
  pname = "affine-mcp-server";
  version = "3.8.5";

  src = fetchFromGitHub {
    owner = "DAWNCR0W";
    repo = "affine-mcp-server";
    rev = "v${version}";
    hash = "sha256-IaXc0Yg2bYmAevLT1sgrcc1wtkLuU86heivaA21WpYA=";
  };

  npmDepsHash = "sha256-n6/4xYjRCoIz1IZSvytjGDpfzOAWXOOWGcVXC5PUUGA=";

  # `npm run build` is `tsc`; the published tarball ships the same dist/.
  inherit nodejs;

  meta = {
    description = "MCP server for AFFiNE workspaces, documents and databases";
    homepage = "https://github.com/DAWNCR0W/affine-mcp-server";
    license = lib.licenses.mit;
    mainProgram = "affine-mcp";
  };
}

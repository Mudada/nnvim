{ pkgs, fetchFromGitHub }:

pkgs.vimUtils.buildVimPlugin rec {
  pname = "dark-notify";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "cormacrelf";
    repo = "dark-notify";
    rev = "v${version}";
    hash = "sha256-eo01qT9aeQPDWXTdqWYQNB3eRk4qyjD1lG/Gk/+HMoI=";
  };
}

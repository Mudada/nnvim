{ pkgs, fetchFromGitHub, ... }:

pkgs.stdenvNoCC.mkDerivation {
	name = "monaco-bold";
	dontConfigue = true;
	src = fetchFromGitHub {
		owner = "vjpr";
		repo = "monaco-bold";
		rev = "master";
		hash = "sha256-qiJK/h1Z5iLzmG4L693BjE9cPMIKv4cpP1c3w9fbDrs=";
	};
	installPhase = ''
		mkdir -p $out/share/fonts
		cp -R $src $out/share/fonts/opentype/
		'';
	meta = { description = "The Monaco font with a bold variant"; };
}

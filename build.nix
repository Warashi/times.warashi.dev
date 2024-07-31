{
  pkgs,
  lib,
  theme,
  baseURL,
  ...
}: let
  callPackage = lib.callPackageWith (pkgs // packages);
  packages = {
    contents = callPackage ({
      runCommand,
      emacsPackagesFor,
      emacs-nox,
      emacs ? emacs-nox
    }:
      runCommand "contents" {
        src = ./contents.org;
        nativeBuildInputs = [
          ((emacsPackagesFor emacs).emacsWithPackages (epkgs:
            with epkgs; [
              org
              ox-hugo
            ]))
        ];
      } ''
        mkdir -p $out/static
        emacs --batch --eval "(progn (require 'org) (require 'ox-hugo) (setq org-hugo-base-dir \"$out\") (with-current-buffer (find-file-noselect \"$src\") (org-hugo-export-wim-to-md t)))"
      '') {};
    themes = callPackage ({
      runCommand,
      theme,
    }:
      runCommand "themes" {
        src = theme;
      } ''
        mkdir -p $out
        cp -r $src $out/theme
      '') {inherit theme;};
    public = callPackage ({
      runCommand,
      go,
      hugo,
      nodejs,
      contents,
      themes,
    }:
      runCommand "public" {
        nativeBuildInputs = [
          go
          hugo
          nodejs
        ];
      } ''
        hugo --minify --noBuildLock --environment production --baseURL ${baseURL} --source ${./.} --theme theme --themesDir ${themes.outPath} --contentDir ${contents.outPath}/content --destination $out
      '') {};
  };
in {
  inherit packages;
  default = packages.public;
}

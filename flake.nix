{
  description = "Description for the project";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    nixpkgs-ruby.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs @ {
    flake-parts,
    devenv-root,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = ["x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages.default = pkgs.hello;

        devenv.shells.default = {
          name = "book-of-secret-words";

          packages = [
            pkgs.openssl
            pkgs.libyaml
            pkgs.git
            pkgs.curl
            pkgs.redis
            pkgs.tailwindcss_4
            pkgs.jetbrains.ruby-mine
            pkgs.mailcatcher
          ];

          languages.ruby.enable = true;
          languages.ruby.version = "3.3.5";

          services.postgres.enable = true;
          services.postgres.listen_addresses = "localhost";
          services.postgres.port = 5433;
          services.redis.enable = true;

          processes.sidekiq = {
            exec = "bundle exec sidekiq -C config/sidekiq.yml";
            process-compose.depends_on.redis.condition = "process_healthy";
          };

          processes.rails = {
            exec = "bin/rails s";
            process-compose.depends_on.postgres.condition = "process_healthy";
          };

          enterShell = ''
            export PATH="$DEVENV_ROOT/bin:$PATH"
            export TAILWINDCSS_INSTALL_DIR="${pkgs.tailwindcss_4}/bin"
          '';
        };
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
      };
    };
}

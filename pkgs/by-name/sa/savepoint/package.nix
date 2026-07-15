{
  lib,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "savepoint";
  version = "0.3.12";

  src = fetchFromGitHub {
    owner = "NamtaoProductions";
    repo = "savepoint";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Mx7zrwK9rwVumFDU7EWhjGai2IEgr++xhaNqv1hFBS4=";
  };

  cargoHash = "sha256-JRtOrFadDiQRLWIOLF3n6ndrglzOV8M9cA64scm+Ad0=";

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  __structuredAttrs = true;

  meta = {
    homepage = "https://github.com/NamtaoProductions/savepoint";
    description = "A command watcher that commits when you fix errors.";
    changelog = "https://github.com/NamtaoProductions/savepoint/releases#release-v${finalAttrs.version}";
    license = with lib.licenses; [
      mit
    ];
    mainProgram = "savepoint";
    maintainers = with lib.maintainers; [
      0atman
      Noi0103
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"

    ];
  };
})
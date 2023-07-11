{
  rustPlatform,
  makeWrapper,
  sources,
}: let
  inherit (sources.swhkd) pname src version cargoLock;
in
  rustPlatform.buildRustPackage {
    inherit pname src version;

    cargoLock = cargoLock."Cargo.lock";

    nativeBuildInputs = [makeWrapper];

    postBuild = ''
      ./scripts/build-polkit-policy.sh \
      --policy-path=com.github.swhkd.pkexec.policy \
      --swhkd-path=/usr/bin/swhkd
    '';

    postInstall = ''
      install -D -m0444 -t "$out/share/polkit-1/actions" ./com.github.swhkd.pkexec.policy

      substituteInPlace "$out/share/polkit-1/actions/com.github.swhkd.pkexec.policy" \
        --replace /usr/bin/swhkd \
          "$out/bin/swhkd"
    '';
  }

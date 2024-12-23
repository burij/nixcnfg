{ lib
, stdenv
, fetchzip
, alsa-lib
, autoPatchelfHook
, libglvnd
, ffmpeg
, libjack2
, libX11
, libXi
, makeWrapper
, SDL2
}:

let
  platforms = {
    "x86_64-linux" = "linux_x86_64";
    "i686-linux" = "linux_x86";
    "aarch64-linux" = "linux_arm64";
    "armv7l-linux" = "arm_armhf_raspberry_pi";
    "x86_64-darwin" = "macos";
    "aarch64-darwin" = "macos";
  };
  bindir = platforms."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation rec {
  pname = "sunvox";
  version = "2.1.1c";

  src = fetchzip {
    url = "https://www.warmplace.ru/soft/sunvox/sunvox-${version}.zip";
    hash = "sha256-vJ76ELjqP4wo0tCJJd3A9RarpNo8FJaiyZhj+Q7nEGs=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    makeWrapper
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    libglvnd
    libX11
    libXi
    SDL2
    ffmpeg
  ];

  runtimeDependencies = lib.optionals stdenv.hostPlatform.isLinux [
    libjack2
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Delete platform-specific data for all the platforms we're not building for
    find sunvox -mindepth 1 -maxdepth 1 -type d -not -name "${bindir}" -exec rm -r {} \;

    mkdir -p $out/{bin,share/sunvox}
    mv * $out/share/sunvox/

  '' + lib.optionalString stdenv.hostPlatform.isLinux ''
    for binary in $(find $out/share/sunvox/sunvox/${bindir}/ -type f -executable); do
      ln -s $binary $out/bin/$(basename $binary)
    done
  '' + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir $out/Applications
    ln -s $out/share/sunvox/sunvox/${bindir}/SunVox.app $out/Applications/
    ln -s $out/share/sunvox/sunvox/${bindir}/reset_sunvox $out/bin/

    # Need to use a wrapper, binary checks for files relative to the path it was called via
    makeWrapper $out/Applications/SunVox.app/Contents/MacOS/SunVox $out/bin/sunvox
  '' + ''

    runHook postInstall
  '';

  meta = with lib; {
    description = "Small, fast and powerful modular synthesizer with pattern-based sequencer";
    #license = licenses.unfreeRedistributable;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    homepage = "http://www.warmplace.ru/soft/sunvox/";
    maintainers = with maintainers; [ puffnfresh OPNA2608 ];
    platforms = lib.attrNames platforms;
  };
}
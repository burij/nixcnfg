{
	lib,
	stdenv,
	fetchurl,
	unzip,
	alsa-lib,
	libX11,
	libXi,
	SDL2,
	autoPatchelfHook,
	alsaLib,
	openssl,
	zlib,
	pulseaudio
}:


let
  libPath = lib.makeLibraryPath [ stdenv.cc.cc alsa-lib SDL2 ];
  arch =
    if stdenv.isAarch64
    then "arm64"
    else if stdenv.isAarch32
    then "arm_armhf_raspberry_pi"
    else if stdenv.is64bit
    then "x86_64"
    else "x86";
in


stdenv.mkDerivation rec {
  pname = "Pixilang";
  version = "3.8.4";


  src = fetchurl {
    url = "https://www.warmplace.ru/soft/pixilang/pixilang-${version}.zip";
    sha256 = "sha256-2BPY+QXQgiKV3hqQmrZRYeHBaCrfngrEL/t96/7wPiQ=";
  };


  nativeBuildInputs = [
    unzip
    autoPatchelfHook
  ];

  unpackPhase = "unzip $src";

  buildInputs = [
    alsaLib
    openssl
    zlib
    pulseaudio
    SDL2
  ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/share $out/bin
    mv pixilang $out/share/

    bin="$out/share/pixilang/pixilang3/bin/linux_${arch}/pixilang"
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
             --set-rpath "${libPath}" \
             "$bin"
             

    ln -s "$bin" $out/bin/pixilang
  '';

  meta = with lib; {
    description = "";
    #license = licenses.unfreeRedistributable;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    homepage = "http://www.warmplace.ru/soft/pixilang/";
    maintainers = with maintainers; [ puffnfresh ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}

{ stdenv, bash, qpdf, poppler_utils, guile, guile-json, lib, name }:

stdenv.mkDerivation {
  inherit name;
  src = lib.sources.cleanSource ../.;

  buildInputs = [ guile guile-json ];

  patchPhase = ''
    TARGET=src/addon.scm
    sed -i 's,\*qpdf\* "qpdf",\*qpdf\* "${qpdf}/bin/qpdf",g' $TARGET
    sed -i 's,\*pdftotext\* "pdftotext",\*pdftotext\* "${poppler_utils}/bin/pdftotext",g' $TARGET
  '';

  buildPhase = ''
    guild compile -o ${name}.go src/addon.scm
  '';

  # module name must be same as <filename>.go
  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp ${name}.go $out/lib/

    cat > $out/bin/${name} <<-EOF
    #!${bash}/bin/bash
    exec -a "${name}" ${guile}/bin/guile -C ${guile-json}/share/guile/ccache -C $out/lib -e '(${name}) main' -c "" \$@
    EOF
    chmod +x $out/bin/${name}
  '';
}

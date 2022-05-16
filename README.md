# Rotate PDFs

This is a simple addon for [Docspell](https://docspell.org) that
allows to rotate attached pdfs files.


## Prerequisites

This addon supports these runners: `nix-flake`, `docker` and
`trivial`.

It is recommended to install [nix](https://nixos.org) on the machine
running joex. This allows to use the `nix-flake` runner which can
build the addon with all dependencies automatically.

Otherwise, for the trivial runner, you need to install these tools
manually: qpdf and pdftotext (might be provided by poppler-utils or
xpdf)


## Usage

It expects arguments as a json file to know how to rotate. It is
currently very basic, you can only set the degree to rotate and it
applies it to all pdfs.

``` json
{ "degree": "90" }
```

Have a look at the
[qpdf](https://qpdf.readthedocs.io/en/stable/cli.html#option-rotate)
manual for possible values.


## Testing

Install [direnv](https://direnv.net/) and [nix](https://nixos.org) and
allow the source root via `direnv allow`. This applies the `devShell`
settings from `flake.nix`. Then build the addon:

```
nix build
```

Now you can run it:

```
./result/bin/rotate-pdf-addon
```

It will run on the test files provided in `test/` and put results in
`test/tmp`.

For quicker turnaround you can also run the source file itself. This
works, because `devShell` puts all required binaries in path.

TEX_FILE     := main.tex
PDF_FILE     := main.pdf
DOCKER_IMAGE := texlive/texlive:latest
PDFLATEX_BIN := $(shell command -v pdflatex 2>/dev/null)

.PHONY: all pdf docker-pdf open clean distclean help

all: pdf

## Compile main.tex -> main.pdf. Uses local pdflatex
pdf:
ifdef PDFLATEX_BIN
	pdflatex -interaction=nonstopmode -halt-on-error $(TEX_FILE)
	pdflatex -interaction=nonstopmode -halt-on-error $(TEX_FILE)
else
	$(MAKE) docker-pdf
endif

## Force compilation inside the texlive/texlive Docker image
docker-pdf:
	docker run --rm -v "$(CURDIR)":/work -w /work $(DOCKER_IMAGE) sh -c "pdflatex -interaction=nonstopmode -halt-on-error $(TEX_FILE)"

## Compile and open the PDF .
open: pdf
	open $(PDF_FILE)

## Remove build artifacts.
clean:
	rm -f main.aux main.log main.out main.fls main.fdb_latexmk main.synctex.gz $(PDF_FILE)

help:
	@echo "make pdf         - compile $(TEX_FILE) -> $(PDF_FILE) (local pdflatex, falls back to Docker)"
	@echo "make docker-pdf  - force compile via the $(DOCKER_IMAGE) Docker image"
	@echo "make open        - compile and open the PDF (macOS)"
	@echo "make clean       - remove LaTeX build artifacts (keep the PDF)"
	@echo "make distclean   - remove build artifacts and the compiled PDF"

TEX_FILE     := main.tex
DIST_DIR     := dist
PDF_FILE     := $(DIST_DIR)/main.pdf
DOCKER_IMAGE := texlive/texlive:latest
PDFLATEX_BIN := $(shell command -v pdflatex 2>/dev/null)

.PHONY: all pdf docker-pdf open clean help

all: pdf

## Compile main.tex -> dist/main.pdf.
pdf: $(DIST_DIR)
ifdef PDFLATEX_BIN
	pdflatex -interaction=nonstopmode -halt-on-error -output-directory=$(DIST_DIR) $(TEX_FILE)
	pdflatex -interaction=nonstopmode -halt-on-error -output-directory=$(DIST_DIR) $(TEX_FILE)
else
	$(MAKE) docker-pdf
endif

$(DIST_DIR):
	mkdir -p $(DIST_DIR)

## Force compilation inside the texlive/texlive Docker image
docker-pdf: $(DIST_DIR)
	docker run --rm -v "$(CURDIR)":/work -w /work $(DOCKER_IMAGE) \
		sh -c "pdflatex -interaction=nonstopmode -halt-on-error -output-directory=$(DIST_DIR) $(TEX_FILE) && \
		       pdflatex -interaction=nonstopmode -halt-on-error -output-directory=$(DIST_DIR) $(TEX_FILE)"

## Compile and open the PDF (macOS).
open: pdf
	open $(PDF_FILE)

## Remove all build output (everything lands in dist/, so this is a single rm -rf).
clean:
	rm -rf $(DIST_DIR)

help:
	@echo "make pdf         - compile $(TEX_FILE) -> $(PDF_FILE) (local pdflatex, falls back to Docker)"
	@echo "make docker-pdf  - force compile via the $(DOCKER_IMAGE) Docker image"
	@echo "make open        - compile and open the PDF (macOS)"
	@echo "make clean       - remove the $(DIST_DIR)/ output folder"

#
# Makefile for build my resume from some reStructuredText files.
#
# Author: Rafael Goncalves Martins
# License: BSD (http://www.opensource.org/licenses/bsd-license.php)
#

LANGUAGES = en_US pt_BR

SED = sed
RST2HTML = rst2html.py
RST2PDF = rst2pdf

PREFIXES = $(foreach lang, $(LANGUAGES), $(addsuffix $(lang), resume-light-))
TXT_TARGETS = $(addsuffix .txt, $(PREFIXES))
HTML_TARGETS = $(addsuffix .html, $(PREFIXES))
PDF_TARGETS = $(addsuffix .pdf, $(PREFIXES))
FONTS = static/fonts/DroidSans.ttf static/fonts/DroidSans-Bold.ttf

.PHONY: all
all: html pdf

resume-light-%.txt: resume-light-%.rst
	$(SED) \
		-e "s/NODEID/$(shell git log -r | grep commit | head -n 1 | awk '{print $2}' )/" \
		-e "s/DATE/$(shell git log -r  | grep Date | head -n 1 | sed 's/^Date: *//g')/" \
		$< > $@

resume-light-%.html: resume-light-%.txt static/html4css1.css static/resume.css
	$(RST2HTML) --generator --date --time --cloak-email-addresses --source-link \
		--embed-stylesheet --initial-header-level=2 \
		--stylesheet-path=static/html4css1.css,static/resume.css \
		--language=$(shell echo $< | $(SED) -e 's/resume-\([^.-]\+\)\.txt/\1/') \
		$< $@

resume-light-%.pdf: resume-light-%.txt static/resume.style $(FONTS)
	$(RST2PDF) --stylesheets=static/resume.style --font-path=static/fonts \
		--language=$(shell echo $< | $(SED) -e 's/resume-\([^.-]\+\)\.txt/\1/') \
		--output=$@ $<

.PHONY: txt
txt: $(TXT_TARGETS)

.PHONY: html
html: $(HTML_TARGETS)

.PHONY: pdf
pdf: $(PDF_TARGETS)

.PHONY: clean
clean:
	$(RM) -v *.txt *.html *.pdf


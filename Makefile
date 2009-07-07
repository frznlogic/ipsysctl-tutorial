all: html src chunky chunkytgz htmltgz ps pdf

chapters= $(wildcard chapters/*.sgml)
appendices= $(wildcard appendices/*.sgml)
scripts= $(wildcard scripts/*.txt)
license= $(wildcard licensing/*.sgml)

images_eps= $(patsubst %.gif,%.eps,$(wildcard images/*.gif))
images_jpg= $(patsubst %.gif,%.jpg,$(wildcard images/*.gif))
images_png= $(patsubst %.gif,%.png,$(wildcard images/*.gif))

.PHONY: site
site: all
	@echo "Making site..."
	-@mkdir html
	-@mkdir html/images
	-@mkdir html/other
	-@mkdir html/scripts
	@cp ipsysctl-tutorial.html html/
	@cp ipsysctl-tutorial.src.tgz ipsysctl-tutorial.chunky.tgz html/
	@cp ipsysctl-tutorial.html.tgz html/
	@cp ipsysctl-tutorial.pdf.gz html/
	@cp ipsysctl-tutorial.ps.gz html/
	@cp -r other/* html/other/
	@cp -r images/*.gif html/images/
	@cp -r images/*.jpg html/images/
	@cp -r scripts/* html/scripts/
	@cp TODO ChangeLog html/
	@cp -r chunkyhtml html/
	-@rm -rf html/scripts/CVS html/other/CVS
	@cp mirrors.html index.php html/
	@echo "Done."

.PHONY: src
src: ipsysctl-tutorial.src.tgz

.PHONY: ps
ps: $(simages_eps) $(images_eps) $(chapters) $(appendices) $(scripts) $(license) ipsysctl-tutorial.ps.gz

.PHONY: pdf
pdf : $(simages_png) $(images_png) $(chapters) $(appendices) $(scripts) $(license) ipsysctl-tutorial.pdf.gz

.PHONY: html
html: $(simages_png) $(images_png) $(simages_jpg) $(images_jpg) $(chapters) $(appendices) $(scripts) $(license) ipsysctl-tutorial.html

.PHONY: chunky
chunky: $(simages_png) $(images_png) $(simages_jpg) $(images_jpg) $(chapters) $(appendices) $(scripts) $(license) chunkyhtml

.PHONY: chunkytgz
chunkytgz: ipsysctl-tutorial.chunky.tgz

.PHONY: htmltgz
htmltgz: ipsysctl-tutorial.html.tgz

%.chunky.tgz: chunky
	@echo "Building chunky tgz version..."
	@cp -r chunkyhtml chunkytgz
	@cp changes.sh chunkytgz
	@cd chunkytgz; sh ./changes.sh
	@tar -cf $*.chunky.tar chunkyhtml
	@gzip $*.chunky.tar
	@mv $*.chunky.tar.gz $*.chunky.tgz
	@rm -rf chunkytgz
	@echo "Done."

%.html.tgz: html
	@echo "Building HTML tgz version..."
	-@mkdir $*
	-@mkdir $*/images
	@cp -r $*.html scripts other $*/
	@cp -r images/*.gif images/*.jpg $*/images/
	@cat $*/$*.html | sed -e 's/http:\/\/ipsysctl-tutorial.frozentux.net\/scripts\//scripts\//g' > \
	 $*/$*2.html
	@cat $*/$*2.html | sed -e 's/http:\/\/ipsysctl-tutorial.frozentux.net\/other\//other\//g' > \
	 $*/$*.html
	@rm -f $*/$*2.html
	@tar -cf $*.html.tar $*
	@gzip $*.html.tar
	@mv $*.html.tar.gz $*.html.tgz
	@rm -rf $*
	@echo "Done."
	
%.src.tgz: %.sgml
	@echo "Building source ball"
	@tar -cf temp.tar ipsysctl-tutorial.sgml scripts/* TODO \
	 ChangeLog Makefile images/*.gif images/templates/* styles/* \
	 addons/* other/* licensing/* chapters/* \
	 appendices/* addons/* other/* bookinfo.sgml > /dev/null
	@gzip temp.tar
	@mv temp.tar.gz $*.src.tgz
	@echo "Done."

%.html: %.sgml
	@echo "Building HTML version..."
	@jw --backend html --nostd --cat styles/catalog \
	 --nochunks ipsysctl-tutorial.sgml
	@echo "Done."

chunkyhtml:
	@echo "Building Chunky HTML version..."
	@rm -rf chunkyhtml
	@mkdir chunkyhtml
	@mkdir chunkyhtml/images
	@jw --backend html --nostd --cat styles/catalog --output chunkyhtml \
	 ipsysctl-tutorial.sgml
	@cp -r images/*.gif chunkyhtml/images/
	@cp -r images/*.jpg chunkyhtml/images/
	@echo "Done."


%.pdf.gz : %.sgml
	@echo "Building PDF version..."
	@mkdir -p pdf; cp -R images licensing scripts appendices \
	 chapters styles *.sgml pdf; cd pdf; jw -b \
	 pdf -d styles/tutorial.dsl -c styles/catalog $*.sgml; cd ..
	@mv pdf/$*.pdf ./
	@rm -rf pdf
	@gzip $*.pdf

%.ps.gz : %.sgml
	@echo "Building PS version..."
	@mkdir -p ps; cp -R images licensing scripts appendices \
	 chapters styles *.sgml ps; cd ps; jw \
	 --backend ps --nostd --cat styles/catalog $*.sgml; cd ..
	@mv ps/$*.ps ./
	@rm -rf ps
	@gzip $*.ps

%.tex : %.sgml
	jw -b tex $*.sgml

images/%.jpg : images/%.gif
	convert images/$*.gif images/$*.jpg

images/%.eps : images/%.gif
	convert -geometry 70% images/$*.gif images/$*.eps

images/%.png : images/%.gif
	convert -geometry 70% images/$*.gif images/$*.png

.PHONY: clean
clean:
	rm -rf ipsysctl-tutorial.html ipsysctl-tutorial.ps.gz \
	 ipsysctl-tutorial.pdf.gz ipsysctl-tutorial.src.tgz *~ \
	 ipsysctl-tutorial.chunky.tgz ipsysctl-tutorial.html.tgz
	rm -rf pdf/ ps/
	rm -rf images/*.jpg images/*.png images/*~ images/*.eps *.log *.aux \
	*.out *.tex
	rm -rf html/
	rm -rf chunkytgz/
	rm -rf chunkyhtml/

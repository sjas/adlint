MAKEINFO = makeinfo
DOT = dot

.SUFFIXES : .texi .html .txt .dot .pdf

.texi.html :
	$(MAKEINFO) --html --no-split --css-include=texinfo.css -o $@ $<

.texi.txt :
	$(MAKEINFO) --plaintext -o $@ $<

.dot.pdf :
	$(DOT) -Tpdf -o $@ $<

TARGET = users_guide_ja.html users_guide_en.html developers_guide_ja.html c99gram.pdf

all : $(TARGET)

clean :
	rm -f $(TARGET)

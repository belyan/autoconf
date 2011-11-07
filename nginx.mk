all: clean build

clean:
	-rm -f $(CONF)

build:
	xsltproc -o ${CONF} nginx.xsl ${META}

.PHONY: all clean build

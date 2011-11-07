NGINX = /etc/init.d/nginx
CONF_AVAILABLE = /etc/nginx/sites-available
CONF_ENABLED = /etc/nginx/sites-enabled

all: clean build

clean:
	-rm -f $(CONF)

build:
	xsltproc -o ${CONF} autoconf/nginx.xsl ${META}

install:
	install -m 644 $(CONF) $(CONF_AVAILABLE)
	ln -sf $(CONF_AVAILABLE)/$(CONF) $(CONF_ENABLED)/$(CONF)
	make restart

uninstall:
	-rm -f $(CONF_AVAILABLE)/$(CONF)
	-rm -f $(CONF_ENABLED)/$(CONF)
	make restart

restart:
ifeq ($(shell whoami),root)
	${NGINX} restart
else
	sudo ${NGINX} restart
endif

.PHONY: all clean build install uninstall restart

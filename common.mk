# ================================ Переменные
PROJECT ?= sample

META ?= ${PROJECT}.xml
CONF ?= 10-${PROJECT}.conf
CONF_DEV ?= 20-${PROJECT}.dev.conf

INIT_PATH = /etc/init.d/

# ================================ Цели
all: clean build

clean:
	-rm -f $(CONF)

build:
	xsltproc -o ${CONF} autoconf/${WEB_SERVER}.xsl ${META}

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
	${INIT_PATH}${WEB_SERVER} restart
else
	sudo ${INIT_PATH}${WEB_SERVER} restart
endif

.PHONY: all clean build install uninstall restart

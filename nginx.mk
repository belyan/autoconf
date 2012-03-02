WEB_SERVER = nginx

CONF_AVAILABLE = /etc/${WEB_SERVER}/sites-available
CONF_ENABLED = /etc/${WEB_SERVER}/sites-enabled

include autoconf/common.mk

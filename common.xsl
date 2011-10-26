<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
    xmlns:exsl="http://exslt.org/common"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="exsl"
    version="1.0">

    <!--
    ==========================================================
        Автогенератор конфигурационных файлов
        Общие переменные

        Автор: Yuriy Belyakov <belyan@yandex-team.ru>
        Репозиторий: https://svn.yandex.ru/common/autoconf/
    ==========================================================
    -->

    <xsl:output method="text" encoding="utf-8" indent="yes"/>

    <xsl:variable name="conf" select="/conf"/>
    <xsl:variable name="hosts" select="$conf/hosts"/>

    <!-- Дефолтные значения -->
    <xsl:variable name="default-values">
        <sld>yandex</sld>
        <tld>ru</tld>
        <xscript>default</xscript>
        <project>project</project>
    </xsl:variable>

    <xsl:variable name="default" select="exsl:node-set($default-values)"/>

    <xsl:template match="/">
        <xsl:apply-templates select="conf"/>
    </xsl:template>

</xsl:stylesheet>

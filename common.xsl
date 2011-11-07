<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ya="urn:yandex-functions"
    exclude-result-prefixes="ya"
    extension-element-prefixes="exsl func"
    version="1.0">

    <!--
    ==========================================================
        Автогенератор конфигурационных файлов
        Общие переменные и функции

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

    <!-- Функции -->
    <func:function name="ya:if">
        <xsl:param name="condition"/>
        <xsl:param name="value1"/>
        <xsl:param name="value2"/>
        <func:result>
            <xsl:choose>
                <xsl:when test="$condition">
                    <xsl:value-of select="$value1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$value2"/>
                </xsl:otherwise>
            </xsl:choose>
        </func:result>
    </func:function>

</xsl:stylesheet>

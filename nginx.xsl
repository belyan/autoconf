<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
    <!ENTITY tab "&#09;">
    <!ENTITY nl "&#10;">
    <!ENTITY quot "&#39;">
]>
<xsl:stylesheet
    xmlns:str="http://exslt.org/strings"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ya="urn:yandex-functions"
    exclude-result-prefixes="ya"
    extension-element-prefixes="str"
    version="1.0">

    <!--
    ==========================================================
        Автогенератор конфигурационных файлов
        Веб-сервер: nginx

        Автор: Yuriy Belyakov <belyan@yandex-team.ru>
        Репозиторий: https://svn.yandex.ru/common/autoconf/
    ==========================================================
    -->

    <xsl:include href="common.xsl"/>

    <!-- Конфигурационный файл -->
    <xsl:template match="conf"/>
    <xsl:template match="conf[string(hosts/host/name)]">
        <xsl:text># Automatically generated file. Do not edit it manually.</xsl:text>
        <xsl:text>&nl;&nl;</xsl:text>
        <xsl:text>server {</xsl:text>

        <xsl:text>&nl;&tab;</xsl:text>
        <xsl:text>include listen;</xsl:text>

        <xsl:apply-templates select="hosts"/>
        <xsl:apply-templates select="." mode="root"/>
        <xsl:apply-templates select="." mode="xscript"/>
        <xsl:apply-templates select="locations"/>
        <xsl:apply-templates select="rewrites"/>

        <xsl:text>&nl;</xsl:text>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates select="hosts/host" mode="aliases"/>
    </xsl:template>

    <!-- Список хостов -->
    <xsl:template match="hosts">
        <xsl:text>&nl;</xsl:text>
        <xsl:apply-templates select="host"/>
        <xsl:apply-templates select="host" mode="regexp"/>
        <xsl:text>&nl;</xsl:text>
    </xsl:template>

    <!-- Хост -->
    <xsl:template match="host">
        <xsl:variable name="name" select="name"/>
        <xsl:variable name="sld" select="ya:if(string(@sld), @sld, $default/sld)"/>
        <xsl:variable name="tld" select="ya:if(string(@tld), @tld, $default/tld)"/>

        <xsl:text>&nl;&tab;</xsl:text>
        <xsl:text>server_name </xsl:text>
        <xsl:for-each select="str:split($tld, ',')">
            <xsl:if test="position() &gt; 1">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="$name">
                <xsl:with-param name="sld" select="$sld"/>
                <xsl:with-param name="tld" select="."/>
            </xsl:apply-templates>
        </xsl:for-each>
        <xsl:text>;</xsl:text>
    </xsl:template>

    <xsl:template match="host" mode="regexp">
        <xsl:variable name="name" select="name"/>
        <xsl:variable name="sld" select="ya:if(string(@sld), @sld, $default/sld)"/>
        <xsl:variable name="tld" select="ya:if(string(@tld), @tld, $default/tld)"/>

        <xsl:for-each select="str:split($tld, ',')">
            <xsl:text>&nl;&tab;</xsl:text>
            <xsl:text>server_name ~^</xsl:text>
            <xsl:apply-templates select="$name">
                <xsl:with-param name="sld" select="$sld"/>
                <xsl:with-param name="tld" select="."/>
                <xsl:with-param name="mode">regexp</xsl:with-param>
            </xsl:apply-templates>
            <xsl:text>$;</xsl:text>
        </xsl:for-each>
    </xsl:template>

    <!-- Имя хоста -->
    <xsl:template match="host/name">
        <xsl:param name="sld"/>
        <xsl:param name="tld"/>
        <xsl:param name="mode"/>
        <xsl:variable name="host-name">
            <xsl:if test="$mode = 'www'">
                <xsl:text>www.</xsl:text>
            </xsl:if>
            <xsl:value-of select="."/>
            <xsl:text>.</xsl:text>
            <xsl:if test="$mode = 'regexp'">
                <xsl:text>[a-z0-9\-]+</xsl:text>
                <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:value-of select="$sld"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="$tld"/>
        </xsl:variable>
        <xsl:value-of select="ya:if($mode = 'regexp', str:replace($host-name, '.', '\.'), $host-name)"/>
    </xsl:template>

    <!-- Корневая папка -->
    <xsl:template match="conf" mode="root">
        <xsl:text>&nl;&tab;</xsl:text>
        <xsl:text>root /usr/local/www5/</xsl:text>
        <xsl:choose>
            <xsl:when test="string(@project)">
                <xsl:value-of select="@project"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$default/project"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>;&nl;</xsl:text>
    </xsl:template>

    <!-- XScript -->
    <xsl:template match="conf" mode="xscript">
        <xsl:text>&nl;&tab;</xsl:text>
        <xsl:text>include xscripts/</xsl:text>
        <xsl:choose>
            <xsl:when test="string(@xscript)">
                <xsl:value-of select="@xscript"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$default/xscript"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>;</xsl:text>
    </xsl:template>

    <!-- Локации -->
    <xsl:template match="locations">
        <xsl:apply-templates select="location"/>
    </xsl:template>

    <xsl:template match="location">
        <xsl:text>&nl;&tab;</xsl:text>
        <xsl:text>include locations/</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>;</xsl:text>
    </xsl:template>

    <!-- Рерайты и редиректы -->
    <xsl:template match="rewrites | redirects">
        <xsl:text>&nl;</xsl:text>
        <xsl:apply-templates select="rewrite | redirect"/>
    </xsl:template>

    <xsl:template match="rewrite | redirect">
        <xsl:text>&nl;&tab;</xsl:text>
        <xsl:text>rewrite </xsl:text>
        <xsl:value-of select="@regexp"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text> </xsl:text>
        <xsl:if test="name() = 'rewrite'">last</xsl:if>
        <xsl:if test="name() = 'redirect'">permanent</xsl:if>
        <xsl:text>;</xsl:text>
    </xsl:template>

    <!-- Алиасы хоста -->
    <xsl:template match="host" mode="aliases">
        <xsl:variable name="sld" select="ya:if(string(@sld), @sld, $default/sld)"/>
        <xsl:variable name="tld" select="ya:if(string(@tld), @tld, $default/tld)"/>

        <xsl:text>&nl;&nl;</xsl:text>
        <xsl:text>server {</xsl:text>
        <xsl:text>&nl;&tab;</xsl:text>
	    <xsl:text>include listen;</xsl:text>

        <xsl:text>&nl;&tab;</xsl:text>
        <xsl:text>server_name </xsl:text>
        <xsl:apply-templates select="name">
            <xsl:with-param name="sld" select="$sld"/>
            <xsl:with-param name="tld" select="$tld"/>
            <xsl:with-param name="mode">www</xsl:with-param>
        </xsl:apply-templates>
        <xsl:text>;</xsl:text>

        <xsl:apply-templates select="aliases"/>

        <xsl:text>&nl;&tab;</xsl:text>
        <xsl:text>rewrite ^/ http://</xsl:text>
        <xsl:apply-templates select="name">
            <xsl:with-param name="sld" select="$sld"/>
            <xsl:with-param name="tld" select="$tld"/>
        </xsl:apply-templates>
        <xsl:text>/$1 permanent;</xsl:text>
        <xsl:text>&nl;</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="aliases">
        <xsl:text>&nl;&tab;</xsl:text>
        <xsl:text>server_name </xsl:text>
        <xsl:apply-templates select="alias"/>
        <xsl:text>;</xsl:text>
        <xsl:text>&nl;&tab;</xsl:text>
        <xsl:text>server_name </xsl:text>
        <xsl:apply-templates select="alias">
            <xsl:with-param name="mode">www</xsl:with-param>
        </xsl:apply-templates>
        <xsl:text>;</xsl:text>
    </xsl:template>

    <!-- Алиас -->
    <xsl:template match="alias">
        <xsl:param name="mode"/>

        <xsl:variable name="sld" select="ya:if(string(@sld), @sld, ya:if(string(ancestor::*/@sld), ancestor::*/@sld, $default/sld))"/>
        <xsl:variable name="tld" select="ya:if(string(@tld), @tld, ya:if(string(ancestor::*/@tld), ancestor::*/@tld, $default/tld))"/>

        <xsl:if test="position() &gt; 1">
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="$mode = 'www'">
            <xsl:text>www.</xsl:text>
        </xsl:if>
        <xsl:value-of select="."/>
        <xsl:text>.</xsl:text>
        <xsl:value-of select="$sld"/>
        <xsl:text>.</xsl:text>
        <xsl:value-of select="$tld"/>
    </xsl:template>

</xsl:stylesheet>

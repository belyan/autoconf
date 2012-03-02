<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
    <!ENTITY nl "&#10;">
    <!ENTITY quot "&#39;">
    <!ENTITY sp "    ">
    <!ENTITY sp2 "&sp;&sp;">
    <!ENTITY sp3 "&sp;&sp;&sp;">
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
        Веб-сервер: lighttpd

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
        <xsl:text>$HTTP[&quot;host&quot;] =~ </xsl:text>
        <xsl:apply-templates select="hosts"/>
        <xsl:text> {</xsl:text>

        <xsl:apply-templates select="." mode="root"/>
        <xsl:apply-templates select="." mode="xscript"/>
        <xsl:apply-templates select="." mode="access"/>

        <xsl:text>&nl;</xsl:text>
        <xsl:text>}</xsl:text>

        <xsl:apply-templates select="hosts/host" mode="aliases"/>
        <xsl:text>&nl;</xsl:text>
        <xsl:apply-templates select="hosts/host" mode="testing"/>
        <xsl:text>&nl;</xsl:text>
    </xsl:template>

    <!-- Список хостов -->
    <xsl:template match="hosts">
        <xsl:text>&quot;^(</xsl:text>
        <xsl:apply-templates select="host"/>
        <xsl:text>)(:\d+)?$&quot;</xsl:text>
    </xsl:template>

    <!-- Хост -->
    <xsl:template match="host">
        <xsl:variable name="host-name" select="name"/>
        <xsl:variable name="host-sld" select="ya:if(string(@sld), @sld, $default/sld)"/>
        <xsl:variable name="host-tld" select="ya:if(string(@tld), @tld, $default/tld)"/>

        <xsl:if test="position() &gt; 1">
            <xsl:text>|</xsl:text>
        </xsl:if>
        <xsl:apply-templates select="$host-name">
            <xsl:with-param name="sld" select="$host-sld"/>
            <xsl:with-param name="tld" select="$host-tld"/>
        </xsl:apply-templates>

        <xsl:text>|</xsl:text>

        <xsl:apply-templates select="$host-name">
            <xsl:with-param name="sld" select="$host-sld"/>
            <xsl:with-param name="tld" select="$host-tld"/>
            <xsl:with-param name="mode">regexp</xsl:with-param>
        </xsl:apply-templates>
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
            <xsl:if test="$mode = 'testing'">
                <xsl:text>rage</xsl:text>
                <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:value-of select="$sld"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="$tld"/>
        </xsl:variable>
        <xsl:value-of select="str:replace($host-name, '.', '\.')"/>
    </xsl:template>

    <!-- Корневая папка -->
    <xsl:template match="conf" mode="root">
        <xsl:text>&nl;&sp;</xsl:text>
        <xsl:text>server.document-root = &quot;/usr/local/www5/</xsl:text>
        <xsl:choose>
            <xsl:when test="string(@project)">
                <xsl:value-of select="@project"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$default/project"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&quot;&nl;</xsl:text>
    </xsl:template>

    <!-- XScript -->
    <xsl:template match="conf" mode="xscript">
        <xsl:text>&nl;&sp;</xsl:text>
        <xsl:text>fastcgi.server = (</xsl:text>
        <xsl:text>&nl;&sp2;</xsl:text>
        <xsl:text>&quot;.xml&quot; =&gt; ((</xsl:text>
        <xsl:text>&nl;&sp3;</xsl:text>
        <xsl:text>&quot;socket&quot; =&gt; &quot;/tmp/xscript-multiple/xscript-</xsl:text>
        <xsl:choose>
            <xsl:when test="string(@xscript)">
                <xsl:value-of select="@xscript"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$default/xscript"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>.sock&quot;,</xsl:text>
        <xsl:text>&nl;&sp3;</xsl:text>
        <xsl:text>&quot;check-local&quot; =&gt; &quot;enable&quot;,</xsl:text>
        <xsl:text>&nl;&sp3;</xsl:text>
        <xsl:text>&quot;allow-x-send-file&quot; =&gt; &quot;enable&quot;</xsl:text>
        <xsl:text>&nl;&sp2;</xsl:text>
        <xsl:text>))</xsl:text>
        <xsl:text>&nl;&sp;</xsl:text>
        <xsl:text>)</xsl:text>
    </xsl:template>

    <!-- Доступ к папкам -->
    <xsl:template match="conf" mode="access">
        <xsl:text>&nl;&nl;&sp;</xsl:text>
        <xsl:text>$HTTP[&quot;url&quot;] =~ &quot;^/(lego|xml)/.*&quot; {</xsl:text>
        <xsl:text>&nl;&sp2;</xsl:text>
        <xsl:text>url.access-deny = ( &quot;&quot; )</xsl:text>
        <xsl:text>&nl;&sp;</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <!-- TODO: Алиасы хоста -->
    <xsl:template match="host" mode="aliases"/>

    <!-- Тестинг -->
    <xsl:template match="host" mode="testing">
        <xsl:variable name="host-name" select="name"/>
        <xsl:variable name="host-sld" select="ya:if(string(@sld), @sld, $default/sld)"/>
        <xsl:variable name="host-tld" select="ya:if(string(@tld), @tld, $default/tld)"/>

        <xsl:text>&nl;&nl;</xsl:text>
        <xsl:text>$HTTP[&quot;host&quot;] =~ &quot;^</xsl:text>
        <xsl:apply-templates select="$host-name">
            <xsl:with-param name="sld" select="$host-sld"/>
            <xsl:with-param name="tld" select="$host-tld"/>
            <xsl:with-param name="mode">testing</xsl:with-param>
        </xsl:apply-templates>
        <xsl:text>(:\d+)?$&quot; {</xsl:text>

        <xsl:text>&nl;&sp;</xsl:text>
        <xsl:text>setenv.add-environment += (</xsl:text>
        <xsl:text>&nl;&sp2;</xsl:text>
        <xsl:text>&quot;XSCRIPT_ENVIRONMENT&quot; =&gt; &quot;testing&quot;</xsl:text>
        <xsl:text>&nl;&sp;</xsl:text>
        <xsl:text>)</xsl:text>
        <xsl:text>&nl;</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>

</xsl:stylesheet>

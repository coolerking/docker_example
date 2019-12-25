FROM centos:7
MAINTAINER "Tasuku Hori" <tasuku-hori@exa-corp.co.jp>

ENV HTTP_PROXY=http://solidorpxy.exa-corp.co.jp:8080/
ENV HTTPS_PROXY=http://solidproxy.exa-corp.co.jp:8080/
ENV NO_RPXY=localhost,127.0.0.1,160.14.*,10.*,192.168.*
ENV http_proxy=http://solidproxy.exa-corp.co.jp:8080/
ENV https_proxy=http://solidproxy.exa-corp.co.jp:8080/
ENV no_proxy=localhost,127.0.0.1,160.14.*,192.168.*,10.*

RUN mkdir -p /etc/svn && mkdir -p /var/www/svn

VOLUME ["/var/www/svn", "/etc/svn"]

RUN echo "proxy=http://solidproxy.exa-corp.co.jp:8080" >> /etc/yum.conf && yum -y update && \
    yum -y install subversion httpd mod_dav_svn net-tools tar gzip openssh-server && \
    echo "## WebDAV"                     >> /etc/httpd/conf.modules.d/10-subversion.conf && \
    echo "Alias /svn /var/www/svn"       >> /etc/httpd/conf.modules.d/10-subversion.conf && \
    echo "<Location /svn>"               >> /etc/httpd/conf.modules.d/10-subversion.conf && \
    echo "  DAV                svn"           >> /etc/httpd/conf.modules.d/10-subversion.conf && \
    echo "  SVNParentPath      /var/www/svn/" >> /etc/httpd/conf.modules.d/10-subversion.conf && \
    echo "  AuthType           Basic"         >> /etc/httpd/conf.modules.d/10-subversion.conf && \
    echo "  AuthName           \"WebPot Collaboration svn repository\"" >> /etc/httpd/conf.modules.d/10-subversion.conf && \
    echo "  AuthUserFile       /etc/svn/svn-auth-users"   >> /etc/httpd/conf.modules.d/10-subversion.conf && \
    echo "  AuthzSVNAccessFile /etc/svn/svn-authz-access" >> /etc/httpd/conf.modules.d/10-subversion.conf && \
    echo "  Require            valid-user" >> /etc/httpd/conf.modules.d/10-subversion.conf && \
    echo "</Location>" >> /etc/httpd/conf.modules.d/10-subversion.conf && \
#    mkdir -p /etc/svn && \
    echo "[repo:/]" >> /etc/svn/svn-authz-access && \
    echo "* =" >> /etc/svn/svn-authz-access && \
    echo "admin = rw" >> /etc/svn/svn-authz-access && \
    echo "[repo:/default]" >> /etc/svn/svn-authz-access && \
    echo "tsukamoto = rw" >> /etc/svn/svn-authz-access && \
    htpasswd -bcm /etc/svn/svn-auth-users admin admin && \
    htpasswd -bm /etc/svn/svn-auth-users tsukamoto tsukamoto && \
#    mkdir -p /var/www/svn && cd /var/www/svn && \
    cd /var/www/svn && \
    svnadmin create repo && \
    cd /var/www && chown -R apache:apache ./svn

VOLUME ["/var/www/svn", "/etc/svn"]
EXPOSE 80
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

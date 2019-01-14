FROM centos:latest
WORKDIR /root
USER root
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN yum -y --nogpgcheck install \
    make \
    gcc \
    g++ \
    unzip \ 
    wget \ 
    tar \
    perl \
    cpan \
    perl-App-cpanminus && \
    yum clean all
RUN cpanm -vn Test::More IO::Socket::SSL Mojolicious
RUN wget -q https://github.com/sjdy521/Mojo-Weixin/archive/v1.4.2.zip -OMojo-Weixin.zip \
    && unzip -qo Mojo-Weixin.zip \
    && cd Mojo-Weixin-1.4.2 \
    && cpanm -v . \
    && cd .. \
    && rm -rf Mojo-Weixin-1.4.2 Mojo-Weixin.zip
CMD perl -MMojo::Weixin -e 'Mojo::Weixin->new(log_encoding=>"utf8",log_level=>"error")->load(["ShowMsg"])->load("MiPush",data=>{registration_ids=>["$ENV{MOJO_WEIXIN_REG_ID}"],is_ban_official=>["$ENV{MOJO_WEIXIN_IS_BAN}"]})->load("Openwx",data=>{listen=>[{port=>$ENV{MOJO_WEIXIN_PLUGIN_OPENWX_PORT}}]})->run'

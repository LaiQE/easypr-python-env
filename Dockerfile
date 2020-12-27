FROM ubuntu:16.04

RUN set -ex \
    && sed -i 's#http://archive.ubuntu.com#http://mirrors.aliyun.com#' /etc/apt/sources.list \
    && sed -i 's#http://security.ubuntu.com#http://mirrors.aliyun.com#' /etc/apt/sources.list \
    && apt-get update

# 安装tzdata用,参考https://www.cnblogs.com/yahengwang/p/11072208.html
ARG DEBIAN_FRONTEND=noninteractive

# 设置用户
RUN set -ex \
    && apt-get install -qqy sudo curl zsh vim tree uuid-runtime tzdata openssh-server git \
    && useradd -m -G sudo -s /usr/bin/zsh admin \
    && echo 'admin:admin' | chpasswd \
    && echo 'admin ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/admin \
    && chmod 440 /etc/sudoers.d/admin \
    && mkdir -p /home/admin \
    && cd /home/admin \
    && mkdir -p /home/admin/.ssh \
    && chmod 700 /home/admin/.ssh \
    && HOME="/home/admin" \
    && curl -fsSL git.io/oh-my-zsh.sh | bash \
    && chown -R admin:admin /home/admin \
    && sed -i 's#antigen theme ys#antigen theme amuse#' /home/admin/.zshrc

USER admin
WORKDIR /home/admin

# 设置时区
ENV TZ=Asia/Shanghai
ENV LANG=C.UTF-8

# 安装opencv,参考https://blog.csdn.net/public669/article/details/99044895
RUN set -ex \
    && sudo apt-get install -qqy python-dev \
    && sudo apt-get install -qqy cmake build-essential libgtk2.0-dev libavcodec-dev libavformat-dev libjpeg-dev libswscale-dev libtiff5-dev libgtk2.0-dev pkg-config\
    && git clone -b 3.1.0 --depth=1 https://hub.fastgit.org/opencv/opencv.git \
    && cd /home/admin/opencv \
    && mkdir build && cd build \
    && sudo cmake -D PYTHON_DEFAULT_EXECUTABLE=$(python -c "import sys; print(sys.executable)") -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local .. \
    && sudo make -j8 \
    && sudo make install

# 安装EasyPR-native
RUN set -ex \
    && cd /home/admin \
    && sudo rm -rf opencv \
    && git clone --depth=1 https://hub.fastgit.org/smirkcat/EasyPR-native.git \
    && cd /home/admin/EasyPR-native \
    && git submodule update --init --recursive \
    && cp EasyPR-change/chars_identify.h EasyPR/include/easypr/core/ \
    && cp EasyPR-change/chars_identify.cpp EasyPR/src/core/ \
    && cp EasyPR-change/plate_judge.cpp EasyPR/src/core/ \
    && cd NativeEasyPR/ \
    # 删除java相关的配置
    && sed -i "/jni/d;/JNI/d" CMakeLists.txt \
    && mkdir build && cd build \
    && cmake .. \
    && make -j8 \
    && cp libeasyprexport.so /home/admin/easyprexport.so \
    && cp -r /home/admin/EasyPR-native/model /home/admin \
    && cd /home/admin && sudo rm -rf EasyPR-native \
    && sudo apt-get autoremove

ARG pip_source=https://pypi.douban.com/simple

# 安装python环境
RUN set -ex \
    && sudo apt-get install -qqy python-pip \
    && sudo pip install --no-cache-dir -i ${pip_source} numpy==1.11.1 opencv-python==3.4.1.15 pillow==5.0

CMD ["/bin/zsh"]



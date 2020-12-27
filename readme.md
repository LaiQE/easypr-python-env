1. 安装opencv,参考https://blog.csdn.net/public669/article/details/99044895
https://blog.csdn.net/u013151336/article/details/104686250/
```shell
apt-get install build-essential libgtk2.0-dev libavcodec-dev libavformat-dev libjpeg-dev libswscale-dev libtiff5-dev
apt-get install libgtk2.0-dev
apt-get install pkg-config
apt-get install git cmake
git clone --branch 3.1.0 https://hub.fastgit.org/opencv/opencv.git --depth=1
cd opencv
mkdir release //创建release文件夹
cd release //切换到该文件夹
//配置输出的参数
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/user/local ..
make   //编译
make install //安装
ldconfig //更新动态库
```

docker run -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -v $(pwd):/home/admin/test easypr-python-env:latest
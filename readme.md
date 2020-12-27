1. 安装docker, 用基地的系统直接有docker
2. 编译docker image
```shell
# 进入目录
cd easypr-python-env
# 编译image
docker build -t easypr-python-env:latest .
```
3. 执行xhost
```shell
xhost +
```
4. 运行docker,如果用docker运行视频,这里改一下，自己百度映射相机到docker内
```
docker run -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -v $(pwd):/home/admin/test easypr-python-env:latest
```
5. 进入之后,执行python程序
```shell
python run_video.py
```
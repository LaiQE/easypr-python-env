# -*- coding: utf-8 -*-
import ctypes
import os
import cv2
import numpy as np
from tempfile import TemporaryFile
from PIL import Image, ImageDraw, ImageFont

MODEL_PATH="/home/admin/model"
SO_PATH = "/home/admin/easyprexport.so"
VIDEO_PATH = "/home/admin/test/test.mp4"

if __name__ == '__main__':
    # 初始化easypr
    easypr=ctypes.CDLL(SO_PATH)
    ptr=easypr.init(MODEL_PATH)
    easypr.plateRecognize.restype=ctypes.c_char_p
    print("init easypr ..")
    # 处理视频帧
    cap = cv2.VideoCapture(VIDEO_PATH)
    print(VIDEO_PATH)
    print(cap.isOpened())
    while(cap.isOpened()):
        ret, frame = cap.read()
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB) 
        im = Image.fromarray(rgb.astype('uint8')).convert('RGB')
        with TemporaryFile() as fp:
            im.save(fp, 'jpeg')
            fp.seek(0)
            data = fp.read()
        datalen=len(data)
        st=easypr.plateRecognize(ptr,data,datalen)
        st = st.decode('utf-8')
        sk = st.split(u',')
        for s in sk:
            if u'牌' in s and len(s) == 10:
                print(u'yes   ' + s)
                draw = ImageDraw.Draw(im)
                # 字体的格式
                fontStyle = ImageFont.truetype("./simsun.ttc", 50, encoding="utf-8")
                # 绘制文本
                draw.text((50, 50), s, (255, 0, 0), font=fontStyle)
                # 转换回OpenCV格式
                frame = cv2.cvtColor(np.asarray(im), cv2.COLOR_RGB2BGR)
                break
        else:
            print('no')
        cv2.imshow('frame',frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    cap.release()
    cv2.destroyAllWindows()
    # 删除easypr 
    easypr.deleteptr(ptr)

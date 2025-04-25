# Human Verification

1. 在视频文件列表clone这个仓库
```
https://github.com/TianxingChen/Video-Dataset.git
```

2. 安装
```
pip install Flask>=2.0
```

3. 在本地开一个转发端口, `8081`可替换
```
ssh -L 8081:localhost:8081 tsinghua@180.76.61.44
```

4. 运行human verify，所有visited过的文件都会被存在`_human_verification/visited.txt`中，避免重复对某些视频进行检查。每次会在浏览器展示`H*W`的视频矩阵（默认应该是2*3），可以选择你要删除的视频，点击视频以选中，然后点击确认按钮后该视频将会被移动到`_removed_video`下的等价目录中：
```
bash run_human_verify.sh
```

5. 在本地浏览器打开：
```
http://localhost:8081
```
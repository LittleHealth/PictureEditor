## PictureEditor

汇编与编译原理大作业

时间：2019年11月3日

#### 1. 沈冠霖：

1. 基本框架

2. 基本的上方菜单

3. 能画线，擦除，绘制基本图形，绘制文字

4. 修改光标

#### 2. 张小健：

1. 实现选择字体，文字大小，字体，（暂无颜色）。
2. 选择颜色：填充颜色和线条颜色
3. 选择填充模式：实心等多种模式
4. 设置线条宽度，线条类型

#### 3. 邓坤恬



代码结构：
Define.inc --常量和各种函数定义

main.asm --窗口主程序

Painter.asm --各种绘图程序

MenuAndControl.asm --菜单和控制部分，需要补全

FileManager.asm --文件处理，还没写呢

WindowsManager.asm --各种事件处理，可能需要微调

Resource.rc--资源文件，资源本身放到res文件夹里





参考：https://github.com/nero19960329/DrawingTool/blob/master/Main.asm  --这个是最简单的demo

https://github.com/youkaichao/AsmPainter  --游神大作业，完成度较高

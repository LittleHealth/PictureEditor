## PictureEditor

汇编与编译原理大作业



我现在实现了：

基本框架

基本的上方菜单

能画线，擦除，绘制基本图形，绘制文字

修改光标

缺少的东西：

1：文件操作--邓坤恬

2：各种设置：
设置线条宽度，线条类型（可能能设置？），线条颜色，上色颜色，字体，文字大小，颜色等，橡皮擦大小

--张小健

3.文档 --技术部分自己写自己的，如果谁觉得自己的代码量不够可以多写演示部分文档

4：其余功能：我问问助教我们工作量够吗，如果不够还要添加别的

我的代码：
Define.inc --常量和各种函数定义

main.asm --窗口主程序

Painter.asm --各种绘图程序

MenuAndControl.asm --菜单和控制部分，需要补全

FileManager.asm --文件处理，还没写呢

WindowsManager.asm --各种事件处理，可能需要微调

Resource.rc--资源文件，资源本身放到res文件夹里

参考：https://github.com/nero19960329/DrawingTool/blob/master/Main.asm  --这个是最简单的demo

https://github.com/youkaichao/AsmPainter  --游神大作业，完成度较高

有问题随时问我，我下周不会开发太多汇编
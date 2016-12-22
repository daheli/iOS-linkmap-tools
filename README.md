#静态库占用的空间大小优化

##概述
一个大型的项目，只是代码段就有可能超过100M，算上armv7和arm64架构，就会超过200M。 这时候检查到底是哪个类、哪个方法占用了太多空间，就显得尤为重要。这个汇总了一些工具及其方法.


##LinkMap文件
###如何获得LinkMap文件
* 在XCode中开启编译选项Write Link Map File \n\ XCode -> Project -> Build Settings -> 把Write Link Map File选项设为yes，并指定好linkMap的存储位置
* 工程编译完成后，在编译目录里找到Link Map文件（txt类型) 默认的文件地址：~/Library/Developer/Xcode/DerivedData/XXX-xxxxxxxxxxxxx/Build/Intermediates/XXX.build/Debug-iphoneos/XXX.build/
是专为用来分析项目的LinkMap文件，得出每个类或者库所占用的空间大小（代码段+数据段），方便开发者快速定位需要优化的类或静态库。

###类占用大小
[linkmap.sh](https://github.com/daheli/iOS-linkmap-tools/tree/master/shell) Fork[来源](https://gist.github.com/bang590/8f3e9704f1c2661836cd)

```
linkmap.sh Sample.build/Sample-LinkMap-normal-arm64--LinkMap--.txt

↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ OC ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
libGameMaster.a(CocoaVpn.o)	17.59KB
libGameMaster.a(GMNodeList.o)	15.04KB
libGameMaster.a(GMEngine.o)	14.00KB
libGameMaster.a(GMVpnManager.o)	12.89KB
libGameMaster.a(GMUdpConfig.o)	9.46KB
.....

↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ C++ ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
libGameMaster.a(connector.o)	26.62KB
libGameMaster.a(udp_link_create.o)	19.87KB
libGameMaster.a(delay_measure.o)	18.69KB
libGameMaster.a(qos_accel.o)	14.95KB
libGameMaster.a(detect.o)	14.84KB
......

totle:423267 | oc:161096 | c++:262171
```


###方法占用大小
[检查每个类占用空间大小工具 增强版](https://github.com/daheli/iOS-linkmap-tools/tree/master/gui) Fork[来源](https://github.com/huanxsd/LinkMap)
![qq0](https://raw.githubusercontent.com/daheli/iOS-linkmap-tools/master/gui/ScreenShot1.png)
![qq1](https://cloud.githubusercontent.com/assets/6140508/21380423/31796e38-c790-11e6-9b60-c331ef743f30.jpg)

###汇编占用大小
```
 反汇编目标文件,查看方法使用指令情况
 objdump -disassemble arm64/GMGameMaster.o

```
![qq5](https://cloud.githubusercontent.com/assets/6140508/21387332/1d93e7f0-c7b2-11e6-8c15-c9c9383d5c7c.png)


##架构及其设计
###减小复杂度
*简化逻辑，抽取相同的代码之前的结构. 调用关系比较混乱,并且有不当的单例*
![qq2](https://cloud.githubusercontent.com/assets/6140508/21381158/abeb4a98-c794-11e6-9b0e-317d9da18c2b.png)

![qq3](https://cloud.githubusercontent.com/assets/6140508/21381239/14500484-c795-11e6-876b-f2939b9eb572.png)


###分析工具Doxygen 
* 需要单独安装Dot
* Graphviz(call graphs)
![qq4](https://cloud.githubusercontent.com/assets/6140508/21381284/4bfce78a-c795-11e6-800b-c49f28cba77e.png)


###减少方法名称
方法名称匹配替换成4-8位字符串,整体会减少1k左右.

[详细使用方式](https://github.com/wg689/Security-And-CodeConfuse)

```
但是弊处还是很明显的, 例如:
* 每次编译都有留存方法名称映射
* 某些关键词和系统冲突,并且编译时不会报错
```


##OC代码

```
@property -> 实例变量
因为属性的语法编译器会做getter/setter等额外工作
```

```
减少if/switch判断
```

```
变量减少声明
Object myObj = ...;
for(;;) {
	myObj = ...;
	myObj.doSomething();
}
```

```
相同代码片段大于5行,进行提取抽象
```

```
缩短字符串内容
例如:
NSString *text = @"越少越好"
```




##CPP代码
```
裁剪功能
优化编译参数 -Os
禁用内联、宏替转成函数
抽取功能子模块
减少全局变量
```







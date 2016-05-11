# HFNavigationController
实现控制器切换。手势Pop返回时，导航栏也会跟随移动。
Pop返回的视图控制器有三种动画效果：
<pre><code>typedef enum : NSUInteger {
        PopAnimationTypeLiner,      //线性动画，默认动画方式
        PopAnimationTypeCurtain,    //幕布式动画
        PopAnimationTypeScale,      //缩放式动画
    } PopAnimationType;
</code></pre>



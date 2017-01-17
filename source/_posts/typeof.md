---
title: Linux内核设计与实现--typeof((fifo) + 1)代码作用
date: 2017-01-15 21:59:46
categoris: Linux内核
---
## 问题
在看Linux内核队列的实现代码，频繁出现以下写法
```cpp
/**
 * kfifo_len - returns the number of used elements in the fifo
 * @fifo: address of the fifo to be used
 * 队列长度
 */
#define kfifo_len(fifo) \
({ \
	typeof((fifo) + 1) __tmpl = (fifo); \
	__tmpl->kfifo.in - __tmpl->kfifo.out; \
})

/**
 * kfifo_is_empty - returns true if the fifo is empty
 * @fifo: address of the fifo to be used
 * 队列是否为空
 */
#define	kfifo_is_empty(fifo) \
({ \
	typeof((fifo) + 1) __tmpq = (fifo); \
	__tmpq->kfifo.in == __tmpq->kfifo.out; \
})
/**
 * kfifo_is_full - returns true if the fifo is full
 * @fifo: address of the fifo to be used
 * 判断队列是否满
 */
#define	kfifo_is_full(fifo) \
({ \
	typeof((fifo) + 1) __tmpq = (fifo); \
	kfifo_len(__tmpq) > __tmpq->kfifo.mask; \
})
```
获取类型用:
> **type((fifo)+1)**

**为什么要+1再typeof获取类型呢？**

## 原因
google了一番，主要原因是：
1. 防止传入结构或者数组，结构或数组+1则会引发编译错误，可以很好地在编译器发现问题并解决！  
2. 指针+1，相当于取同类型下一个元素，还是同类型指针，类型不变！


## 感悟
看到这种写法，第一感觉很错愕，但了解到原因后感觉很强大，有点四两拨千斤的感觉。一个简单的+1操作可以很好地避免发现并阻止一些不可避免的失误。太博大精深了。

## 参考
- http://stackoverflow.com/questions/16196440/what-is-typeoffifo-1-means-from-linux-kfifo-h-file
- http://blog.chinaunix.net/uid-9672747-id-4045550.html


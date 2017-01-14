---
title: C实践小程序-原子和非原子++操作
date: 2017-01-11 23:28:28
categories: 实践小demo
---
## 概念
处理器保证从系统内存当中读取或者写入一个字节是原子的，意思是当一个处理器读取一个字节时，其他处理器不能访问这个字节的内存地址。    

## 处理器如何实现的原子操作？
http://www.infoq.com/cn/articles/atomic-operation   
处理器使用**总线锁**就是来解决这个问题的。   


## 完整代码
```cpp
#include <thread>
#include <atomic>
#include <unistd.h>
#include <stdio.h>
#include <list>
#include <vector>
//原子++
std::atomic_int iCount(0);
//非原子性++
int iCnt;
/**
非原子加多线程下最后的结果不确定！！！
iCnt=4853200...
iCnt=9889662...
iCnt=10000000...
iCnt=10000000...
*/
void threadfun1(int k)
{
    for(int i=0;i<1000000;i++){
		iCnt++;
	}
}

/*原子++*/
void threadfun_atomic(int k)
{
    for(int i=0;i<100000;i++){
		iCount++;
	}
}
int main()
{
    std::atomic_bool b;
    std::vector<std::thread> lstThread;
    for (int i = 0; i < 10; ++i)
    {
        lstThread.push_back(std::thread(threadfun1,i));
		lstThread[i].detach();
    }
    
	for (int i = 0; i < 10; ++i)
    {
        std::thread th1(threadfun_atomic,i);
		//自己释放内存
		//http://www.cnblogs.com/bits/archive/2009/12/04/no_join_or_detach_memory_leak.html
		th1.detach();
    }
	usleep(1000000);
	printf("iCnt=%d,iCount=%d \n",iCnt,(int)iCount);
	return 0;
}

```

## 执行结果:
```cpp

iCnt=10000000,iCount=1000000 
iCnt=8487677,iCount=1000000 
iCnt=8595552,iCount=1000000 
iCnt=7772070,iCount=1000000 
iCnt=7820366,iCount=1000000 
iCnt=4151170,iCount=1000000 
iCnt=9490318,iCount=1000000 
```

## 进一步思考
- 无锁操作是什么

## 参考资料
- 原子操作 vs 非原子操作(http://blog.jobbole.com/54345/)
- 聊聊并发（五）——原子操作的实现原理(http://www.infoq.com/cn/articles/atomic-operation)

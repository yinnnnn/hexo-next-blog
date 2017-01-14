---
title: Linux内核中的链表巧妙实现
date: 2017-01-09 23:11:19
categories: Linux内核
---

## 定义
链表是我们学习数据结构课程中首先学的并且是最为基础且最重要的一种数据结构类型。   
可以用一种最简单的数据结构来表示这样的一个链表：  
```cpp
struct list_element{
	void* data;
	struct list_element* next;
};
```

双向链表：   
```cpp
struct list_element{
	void* data;
	struct list_element* pre;
	struct list_element* next;
};
```

## Linux内核中的实现
相比普通的链表实现方式，Linux内核的实现可以说独树一帜。前面提到的数据通过内部添加一个指向数据的next（或者pre）节点指针，才能串联在链表中。比如，假设我们有一个fox数据结构来表述狐狸：
```cpp
struct fox {
    unsigned long tail_length;//尾巴长度
    unsigned long weight;//重量
    bool is_fantastic;//是否奇妙
}
```
存储这个结构到链表里的通常方法是在数据结构中嵌入一个链表指针，比如：
```cpp
struct fox {
    unsigned long tail_length;//尾巴长度
    unsigned long weight;//重量
    bool is_fantastic;//是否奇妙
    struct fox *next;
    struct fox *prev;
}
```
**Linux内核方式与众不同，它不是将数据结构塞入链表，而是将链表节点塞入数据结构！！**   
链表代码在头文件`<linux/list.h>`其数据结构很简单：
```cpp
struct list_head {
    struct list_head *next;
    struct list_head *prev;
}
```
`next`指针指向下一个链表节点，`prev`指针指向前一个。然而，似乎这里还看不出它们有多大作用。到底什么才是链表存储的具体内容呢？其实关键在于理解`list_head`结构是如何使用的。  
```cpp
struct fox {
    unsigned long tail_length;//尾巴长度
    unsigned long weight;//重量
    bool is_fantastic;//是否奇妙 
    struct list_head list;//所有fox结构体形成链表
}
```
上述结构中，fox中的`list.next`指向下一个元素，`list.prev`指向前一个元素。现在链表已经能用了，但是显然还不够方便。因此**内核又提供了一组链表操作例程。**比如，`list_add()`方法假如一个新节点到链表中。但是，这些方法都有一个统一的特点：它们只接受list_head结构作为参数。使用宏`container_of()`我们可以很方便地从链表指针找到父结构中包含的任何变量。**这是因为在C语言中，一个给定结构中的变量偏移在编译时地址就被ABI固定下来了。**
```cpp
#define container_of(ptr, type, member) \
    (type *)((char *)(ptr) - (char *) &((type *)0)->member)
```

## 操作链表
- 增加节点：
> list_add(struct list_head *new,struct list_head *head);
- 删除节点：
> list_del(struct list_head *entry);
- 移动和合并链表节点
> list_move(struct list_head *list,struct list_head *head);
- 较差链表是否为空：
> list_empty(struct list_head *head);

## 遍历链表
- 常用的遍历方法
> list_for_each_entry(pos,head,member)
- 反向遍历
> list_for_each_entry_reverse(pos,head,member);
- 遍历的同时删除
> list_for_each_entry_safe(pos,next,head,member);

## 完整例程
```cpp
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include "include/list.h"

struct foo{
    int id;
    struct list_head entry;
};

int main(){
    printf("hello world!\n");
    struct foo fo;
    INIT_LIST_HEAD(&fo.entry);

    struct foo *first = (struct foo *)malloc(sizeof(struct foo));
    struct foo *second= (struct foo *)malloc(sizeof(struct foo));
    first->id = 999;
    second->id = 888;
    list_add(&first->entry,&fo.entry);
    list_add_tail(&second->entry,&fo.entry);

    struct foo *iterator;
    list_for_each_entry(iterator, &fo.entry, entry) {
        printf("id=%d\n",iterator->id);
    }

	struct foo  *next;
	list_for_each_entry_safe(iterator, next, &fo.entry, entry) {
		//	list_del(&iterator->entry);
//		free(iterator);
	}
	printf("empty ? %d\n",list_empty(&fo.entry));
	first = list_first_entry(&fo.entry, struct foo, entry);

    list_for_each_entry(iterator, &fo.entry, entry) {
        printf("id=%d\n",iterator->id);
    }
	free(first);
	free(second);
}

```

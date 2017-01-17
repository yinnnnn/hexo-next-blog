---
title: crc32/md5/sha1执行效率实测
date: 2017-01-17 12:36:55
categories: 实践小demo
---

## 前言
今天看到[codis](https://github.com/CodisLabs/codis/blob/release3.1/doc/FAQ_zh.md)，一个redis集群工具才用crc32作为sharding方式，于是研究和测试了一番`crc32`、`md5`、`sha1`三者之间的区别和执行效率差异。  

## 异同点
可参考这篇讨论:http://stackoverflow.com/questions/15676575/what-s-the-difference-between-md5-crc32-and-sha1-crypto-on-php  
相同：**都是hash函数**  
不同：
- md5、sha1主要是面向加密函数，而crc32 是一个校验码方式，用一个数值来快速判断校验一个字符串或文件是否损坏（如在下载文件后进行文件损坏检验）
- 安全性方面(https://github.com/LexHsu/Summary/blob/master/02-Algorithm/book/2.4-crc.md)：sha1>md5>crc32

## 性能测试
测试下三个方法的执行效率，分两种测试情况：短字符串和偏大文本，看不同情况下3者的执行耗时情况。

### 测试一：短字符串情况
测试内容：
字符串：
> 1sdvfdvklervvsadvsad.,nvdviwfkasdassssssssssssssssssssssssssssssssssssssssssssssss

 time | crc32 | md5 |sha1
---|---|---|---
1百万次 | 0.3734s|0.4890s|0.6520s
1千万次 | 3.8651s|4.9852s|6.4388s

通过测试可以看到：在短字符串情况下，耗时：`sha1 > md5 >crc32` 。crc32的耗时最短，md5其次，sha1耗时最久,接近crc32耗时的一倍。
```
$str = '1sdvfdvklervvsadvsad.,nvdviwfkasdassssssssssssssssssssssssssssssssssssssssssssssss';
$start1 = microtime_float();
for ($i = 0; $i < $times; $i++) {
	crc32($str);
}
$start2 = microtime_float();
$crc32 = ($start2 - $start1);
echo "loop {$times} times crc32 use {$crc32}s\n";
for ($i = 0; $i < $times; $i++) {
	md5($str);
}
$start3 = microtime_float();
$md5 = ($start3 - $start2);
echo "loop {$times} times md5 use {$md5}s\n";
for ($i = 0; $i < $times; $i++) {
	sha1($str);
}
$start4 = microtime_float();
$sha1 = ($start4 - $start3);
echo "loop {$times} times sha1 use {$sha1}s\n";
```

### 测试二：文本情况
测试内容：   
> 11kb的文本文件

 time | crc32 | md5 |sha1
---|---|---|---
10万 | 3.3513s|2.2273s|3.1707s
50万 | 17.1214s|11.1247s|15.9046s

看测试结果惊人的发现：对于长文本的情况下，`crc32 > sha1 > md5`.crc32的耗时变得最长，sha1次之，md5最小。
不试不知道，一试吓一跳，对于不同的文本长度，三者的执行效率不一样，而且耗时还会截然相反。结论是：**对于小文本使用`crc32`最合适，而对于大文本或文件则使用md5最合适。**

## 测试三：当字符串长度大于多少时，crc32的执行时间超过md5
测试代码：
```php
$str = '1234567890';
do {
	echo "------".strlen($str)."\n";
	$start1 = microtime_float();
	for ($i = 0; $i < $times; $i++) {
		crc32($str);
	}
	$start2 = microtime_float();
	$crc32 = ($start2 - $start1);
	echo "loop {$times} times crc32 use {$crc32}s\n";
	for ($i = 0; $i < $times; $i++) {
		md5($str);
	}
	$start3 = microtime_float();
	$md5 = ($start3 - $start2);
	echo "loop {$times} times md5 use {$md5}s\n";
	for ($i = 0; $i < $times; $i++) {
		sha1($str);
	}
	$start4 = microtime_float();
	$sha1 = ($start4 - $start3);
	echo "loop {$times} times sha1 use {$sha1}s\n";
	$str .='1234567890';
	
} while ($crc32 < $md5);
echo "strlen".strlen($str)."\n";
echo "$str \n";

function microtime_float() {
	list($usec, $sec) = explode(" ", microtime());
	return ((float) $usec + (float) $sec);
}
```
经过多次测试，取平均执行结果：** strlen($str) = 180 **
结论：但加密字符串小于180时，crc32的执行时间小于md5,字符串长度大于230，md5的执行耗时小于crc32.

## 测试四：当字符串长度大于多少时，crc32的执行时间超过sha1
只要修改下上面的`while($crc32 < $sha1)`即可。   
经过多次测试，结果浮动比较大，取平均执行结果：** strlen($str) = 570 **
结论：但加密字符串小于230时，crc32的执行时间小于md5,字符串长度大于230，sha1的执行耗时小于crc32.

## 结论
不试不知道，一试吓一跳，对于不同的文本长度，三者的执行效率不一样，而且耗时还会截然相反。结论是：**对于小文本使用`crc32`最合适，而对于大文本或文件则使用md5最合适。**


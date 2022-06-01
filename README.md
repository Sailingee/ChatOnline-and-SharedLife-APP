# ChatOnline-and-SharedLife-APP-Flutter

  一个用于分享平时生活和在线聊天的社交APP 使用Flutter开发,Firebase作为服务端,APP,Flutter Project of IOS and Android. A social APP communicate to others.



### 功能示例

+ 引导页面

 ![4284464883a957cf1c04b4eab269784](https://user-images.githubusercontent.com/49642381/171317365-36099f19-c8df-44bd-a3cc-702ea8b9cc4d.png)



+ 主页

![主界面](https://user-images.githubusercontent.com/49642381/171317388-8558979b-8748-4f6a-920c-e6295f35efe9.gif)
</br>
![个人设置](https://user-images.githubusercontent.com/49642381/171317393-7d3402c2-a4df-4403-83cb-3e68a9ba6900.gif)

 

+ 评论区

  ![b7dec2623cc38ca62c337b6f1953e99](https://user-images.githubusercontent.com/49642381/171318322-2de5253d-2948-46c0-95db-739a49538537.png)







+ 聊天界面


![3](https://user-images.githubusercontent.com/49642381/132213345-a40f6b2d-9ce2-4259-8f67-7a26e89847de.PNG)
</br>
![ani1](https://user-images.githubusercontent.com/49642381/132213353-f2390a41-d247-4743-b669-98bc793db79f.gif)



![5](https://user-images.githubusercontent.com/49642381/132213352-b665d9dc-5b98-491b-aa6b-18e65dbbb5a1.PNG)


## 使用该项目可能需要创建Firebase服务

### 创建Firebase后台

https://console.firebase.google.com/

![firebase01](https://user-images.githubusercontent.com/49642381/132213361-f176fc93-f177-4b5b-bf5f-71701d22cc01.PNG)


项目名称可以随便填


![firebase02](https://user-images.githubusercontent.com/49642381/132213365-6c4d9c05-a32e-4ad3-88d4-4504eb40322c.PNG)

第二步中的Google Analytics可选可不选



进入主控制台界面后选择Android 注册应用

![firebase03](https://user-images.githubusercontent.com/49642381/132213369-336ae548-43e3-4014-ad4b-332bc12eb703.PNG)

Android软件包名

<font color="red"> 与项目目录下android/app/build.gradle中的 applicationID一致</font>


![firebase04](https://user-images.githubusercontent.com/49642381/132213373-41e93c1a-eadc-488a-8636-62987faba3a6.PNG)
![firebase05](https://user-images.githubusercontent.com/49642381/132213375-9a528774-812a-4bae-9cc1-8b7f35da718e.PNG)

​    后续步骤根据文档所叙下载配置文件到项目目录即可

注册完成后选择开启Firestore Database和Storage 并选择测试模式
![firebase1](https://user-images.githubusercontent.com/49642381/132213362-35ce0614-0217-4208-a655-b7952898bc4d.PNG)


其中修改Storage的规则为


![firebase2](https://user-images.githubusercontent.com/49642381/132213368-9973f2a8-44da-418e-bc78-d66f18bb7d13.PNG)



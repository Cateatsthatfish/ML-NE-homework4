# ML&NE Homework 4

> 11911838 简欣瑶 2021.5.4 Tue
>
> Modelling the Inter-Temporal Preferences 

Inter-Temporal Preference : preference for smaller immediate rewards over delayed larger rewards



# Data

## **source :**

1. hw4-Collect.csv

   - from 唐家豪

   - description : 
     The collected data is from a survey to 29 students in ML&NE class (SUSTech 2021 Spring), including 20 columns and 29 rows. 
     The  columns covers the subjects' nickname, gender,personal characteristics, being single or not, as long as the numbers of 16  intertemporal choice questions. 
     The rows are from separate subjects and their corresponding answers.  

   - overview : 

   - | 代号（必填） | 性别（必填） | 你是个急躁的人吗？（必填） | 你单身吗？（必填） | 1    | 2    | 3    | 4    | 5    | 6    | 7    | 8    | 9    | 10   | 11   | 12   | 13   | 14   | 15   | 16   |
     | ------------ | ------------ | -------------------------- | ------------------ | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
     | neko         | 女           | 4                          | 否                 | 2    | 2    | 2    | 2    | 2    | 2    | 2    | 2    | 2    | 1    | 2    | 2    | 2    | 2    | 2    | 2    |
     | bruteforce   | 男           | 3                          | 是                 | 2    | 1    | 1    | 2    | 1    | 2    | 2    | 2    | 2    | 1    | 1    | 2    | 2    | 2    | 2    | 2    |
     | 我智商不如狗 | 男           | 3                          | 是                 | 2    | 2    | 2    | 2    | 2    | 2    | 2    | 2    | 2    | 1    | 2    | 2    | 2    | 2    | 2    | 2    |
     | 啊这         | 男           | 7                          | 是                 | 2    | 1    | 1    | 2    | 2    | 2    | 2    | 1    | 1    | 1    | 1    | 2    | 1    | 2    | 2    | 2    |

2. AB_text.csv

   - description : 
     This data is used to record the corresponding numbers in intertemporal choice questions of the form "Would you prefer \$A now or \$B in D days"

     DA : DA=0 means now
     R : response from subject,1 or 2
     subj : name of the subject

   - overview : 

   - | A    | DA   | B    | DB   | R    | subj |
     | ---- | ---- | ---- | ---- | ---- | ---- |
     | 5    | 0    | 10   | 14   | 2    | neko |
     | 12   | 0    | 20   | 21   | 2    | neko |
     | 15   | 0    | 30   | 28   | 2    | neko |
     | 8    | 0    | 50   | 70   | 2    | neko |
     | 15   | 0    | 50   | 35   | 2    | neko |
     | 5    | 0    | 200  | 42   | 2    | neko |



## **process :** 

``` python 
# -*- coding: utf-8 -*- 
import numpy as np
import pandas as pd
features = pd.read_csv('hw4-Collect.csv',encoding="gbk")

# replace nickname with numbers
rows = features.shape[0]
features.insert(1,"subj",range(1,rows+1))
del features["代号（必填）"]

# deal with features
features.rename(columns={"性别（必填）":"gender","你是个急躁的人吗？（必填）":"personal characteristics","你单身吗？（必填）":"single"},inplace=True)
features.replace({"男":1,"女":0},inplace = True)
features.replace({"是":1,"否":0},inplace = True)

# deal with response (1 or 2)-> (0 or 1)
subject_response = features.iloc[:,5:]-1

# separate features and response
features = features.iloc[:,:4]
features.to_csv("./output3.csv")
```

output: 

![image-20210504092700240](C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504092700240.png) ![image-20210504092844559](C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504092844559.png) 

 ```python
 AB_test = pd.read_csv("AB_test.csv")
 AB_test.loc[:,"subj"] = 1
 AB_test.R = AB_test.R - 1
 struct = AB_test.copy()
 
 for i in range(subject_response.shape[0]-1):
     t_s0 = AB_test.copy()
     t_s0.loc[:,"subj"] = (i+2)
     t_sr = subject_response.iloc[(i+1),1:]
     t_s0.R=np.array(t_sr)
     struct = pd.concat([struct,t_s0],ignore_index=True)
     
 struct.to_csv("./output2.csv")
 ```

output : 

![image-20210504093245463](C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504093245463.png) 



## output :

output3.csv :  29 rows × 5 columns 

![image-20210504093518720](C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504093518720.png) 

output2.csv :  464 rows × 7 columns 

![image-20210504093753945](C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504093753945.png) 

# Model

> from *Computational modeling of cognition and behavior*

Lecture14_4_hierarchicalITC.j & Lecture14_4_hierarchicalITC.R

<img src="C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504094315291.png" alt="image-20210504094315291" style="zoom:80%;" /> <img src="C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504094630300.png" alt="image-20210504094630300" style="zoom:80%;" /> 



# **Requirements**

> 1. Fit your own data, and get your discount k 
> 2. Apply the hierarchical models to all the data from your classmates
> 3. Compare the k values from girls and boys (t-test)
> 4. Investigate the relationship between k and the personal characteristics (correlation analysis)
> 5. Investigate whether being single will impact k values



##  <1|2>

requirement : 

1. Fit your own data, and get your discount k 
2. Apply the hierarchical models to all the data from your classmates

code : 

``` R 
# read data
itcdata<-read.csv("output2.csv",header=TRUE) # requirement 2
# ... (omitted)
# estimate the value of k
parameters <- c("k") 
mcmcfin<-coda.samples(hierITC,parameters,5000) 
sum = summary(mcmcfin)
print(sum)
```

<img src="C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504095008769.png" alt="image-20210504095008769"  /> <img src="C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504095030280.png" alt="image-20210504095030280"  /> 

  

## <3>

requirement :   Compare the k values from girls and boys (t-test)

code : 

``` R
k = sum$statistics 
subj_k = k[,"Mean"] 
```

 ![image-20210504100030365](C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504100030365.png) 

``` R 
features = read.csv("output3.csv",header=TRUE)
new_feature = cbind(features,k=subj_k)
```

 ![image-20210503211655562](C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210503211655562.png) ![image-20210504100148055](C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504100148055.png) 

``` R
# t-test
t.test(feature_gender$k~feature_gender$gender)
```

![image-20210504100815367](C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504100815367.png) 

result : 

since p-value = 0.03198 < 0.05 , which the difference between means k values from girls and boys is significant. And the mean in group 1 (boys) is 0.09794622 is much greater than that of group 0 (girls).



## <4>

requirement : Investigate the relationship between k and the personal characteristics (correlation analysis)

code : 

``` R
# covariance : 0.1104891
cov(new_feature$personal.characteristics, new_feature$k)
# correlation : 0.4894956
cor(new_feature$personal.characteristics, new_feature$k)
```

![image-20210504102026664](C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504102026664.png) 

``` R
# plot (scatter)
plot(new_feature$personal.characteristics, new_feature$k)
```

<img src="C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504102553992.png" alt="image-20210504102553992" style="zoom:67%;" /> 

result :

Since the correlation r = 0.4894956, then the linear correlation between k and the personal characteristics is not strong. From the scatter diagram, it seems that the k is larger when the personal characteristics is larger, which may indicate that, the more irritable a person is, the less time a person would perceive the delayed reward to be worth half its present value.



## <5>

requirement : Investigate whether being single will impact k values

code : 

``` R
# t-test
t.test(new_feature$k~new_feature$single) 
# correlation : 0.2706438
cor(new_feature$single, new_feature$k) 
```

 ![image-20210504104626201](C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504104626201.png) ![image-20210504105058979](C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210504105058979.png) 

result : 

since p-value =0.02636 < 0.05 , which the difference between means k values from single and not single group is also significant. And the mean in group 1 (single) is 0.03476900  is much smaller than that of group 0 (not signal), which may indicate that, the not single group would perceive the delayed reward to be worth half its present value after the less time. However, since the correlation r = 0.2706438, then the linear correlation between k and the single or not is very weak.



# code

all related codes and data can be found on :
https://github.com/Cateatsthatfish/ML-NE-homework4


# -*- coding: utf-8 -*-
import numpy as np
import pandas as pd

features = pd.read_csv('hw4-Collect.csv', encoding="gbk")

# replace nickname with numbers
rows = features.shape[0]
features.insert(1, "subj", range(1, rows + 1))
del features["代号（必填）"]

# deal with features
features.rename(columns={"性别（必填）": "gender", "你是个急躁的人吗？（必填）": "personal characteristics", "你单身吗？（必填）": "single"},
                inplace=True)
features.replace({"男": 1, "女": 0}, inplace=True)
features.replace({"是": 1, "否": 0}, inplace=True)

# deal with response (1 or 2)-> (0 or 1)
subject_response = features.iloc[:, 5:] - 1

# separate features and response
features = features.iloc[:, :4]
features.to_csv("./output3.csv")

AB_test = pd.read_csv("AB_test.csv")
AB_test.loc[:, "subj"] = 1
AB_test.R = AB_test.R - 1
struct = AB_test.copy()

for i in range(subject_response.shape[0] - 1):
    t_s0 = AB_test.copy()
    t_s0.loc[:, "subj"] = (i + 2)
    t_sr = subject_response.iloc[(i + 1), 1:]
    t_s0.R = np.array(t_sr)
    struct = pd.concat([struct, t_s0], ignore_index=True)

struct.to_csv("./output2.csv")

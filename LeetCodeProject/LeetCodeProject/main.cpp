//
//  main.cpp
//  LeetCodeProject
//
//  Created by 夏阳 on 2019/4/11.
//  Copyright © 2019 夏阳. All rights reserved.
//

#include <iostream>
#include <vector>
using namespace std;
//10. 正则表达式匹配
bool isMatch(string s, string p) {
    if (p.find('*') != p.npos) {
        //有*
        int pIdx = 0;
        for (int i = 0; i < s.size();) {
            if (s[i] != p[pIdx] && p[pIdx] != '.') {
                //没有直接通过.或者字符匹配上
                if (p[pIdx] == '*') {
                    if (pIdx + 1 < p.size() && (p[pIdx + 1] == s[i] || p[pIdx + 1] == '.')) {
                        //匹配到了*之后的字符
                        pIdx++;
                        i++;
                        continue;
                    }
                    if (pIdx - 1 > 0 && (s[i] != p[pIdx - 1] && p[pIdx - 1] != '.')) {
                        //当前字符与*的前一个字符也没匹配上
                        return false;
                    }
                } else if (pIdx + 1 < p.size() && p[pIdx + 1] == '*') {
                    //判断匹配0个*之前的字符
                    if (pIdx + 2 < p.size()) {
                        //匹配上了，跳过*和*之前的字符，继续与当前字符匹配
                        pIdx += 2;
                        continue;
                    } else {
                        return false;
                    }
                }
            }
            if (p[pIdx] != '*') {
                //如果*匹配正常，则p不需要往后移
                if (pIdx + 1 >= p.size() && i + 1 < s.size()) {
                    //判断p是否越界
                    return false;
                }
                pIdx++;
            }
            i++;
        }
        if (pIdx + 1 < p.size()) {
            return false;
        } else {
            return true;
        }
    } else if (s.size() != p.size()) {
        return false;
    } else {
        //没有‘*’ 且长度相等
        for (int i = 0; i < s.size(); i++) {
            if (s[i] != p[i] && p[i] != '.') {
                return false;
            }
        }
        return true;
    }
    return false;
}

int main(int argc, const char * argv[]) {
    if (isMatch("aaa", "ab*a*c*a")) {
        printf("true\n");
    } else {
        printf("false\n");
    }
    return 0;
}

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
    size_t pos = p.find('*');
    if (pos != p.npos) {
        //有*
        int pIdx = 0;
        for (int i = 0; i < s.size();) {
            if (s[i] != p[pIdx] && p[pIdx] != '.') {
                if (p[pIdx] == '*') {
                    if (pIdx + 1 < p.size() && p[pIdx + 1] == s[i]) {
                        pIdx++;
                        i++;
                        continue;
                    }
                    if (s[i] != p[pIdx - 1]) {
                        return false;
                    }
                } else if (pIdx + 1 < p.size() && p[pIdx + 1] == '*') {
                    if (pIdx + 2 < p.size()) {
                        pIdx += 2;
                        continue;
                    } else {
                        return false;
                    }
                }
            }
            if (p[pIdx] != '*') {
                pIdx++;
            }
            i++;
        }
        return true;
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
    if (isMatch("babbcaacbccbbbbbabb", "bb*.b*b*a*aba*c")) {
        printf("true\n");
    } else {
        printf("false\n");
    }
    return 0;
}

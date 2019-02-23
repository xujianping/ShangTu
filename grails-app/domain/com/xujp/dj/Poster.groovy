package com.xujp.dj

class Poster {
    /** 所属站点*/
    Station station
    /** 手机号*/
    String mobileNo
    /** POS机登录账号*/
    String posLoginNo
    /** 快递员人名*/
    String posterName
    /** POS机密码*/
    String posPwd
    /** 是否有效*/
    Boolean enabled = true
    static constraints = {
        posLoginNo unique: true, blank: false
    }
    static mapping = {
        station cache: true
        table"dj_poster"
    }

    String toString() {
        posterName
    }
}

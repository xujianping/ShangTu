package com.xujp.dj.auth

class RequestMap {
    // url
    String url
    //角色名，以“，”分隔
    String configAttribute
    //菜单栏
    Action action

    static mapping = {
        table('dj_request_map')
        cache false
    }

    static constraints = {
        url blank: false, unique: true
        configAttribute blank: false
        configAttribute size: 0..200
        action nullable: true
    }
}

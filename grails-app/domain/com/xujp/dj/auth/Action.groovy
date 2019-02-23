package com.xujp.dj.auth

class Action {
    /** 标题*/
    String title
    /** 分组名*/
    String groupName
    //是功能菜单
    Boolean isMenu = true
    /** 控制器名*/
    String controllerName
    /** 排序号 */
    String sortNum
    static constraints = {
        isMenu nullable: true
        sortNum nullable: true
        title blank: false, unique: true
    }
    static mapping = {
        table('dj_action')
    }
}

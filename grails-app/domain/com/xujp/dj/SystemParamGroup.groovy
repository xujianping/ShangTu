package com.xujp.dj
/***
 * 系统参数分组
 */
class SystemParamGroup {
    String groupName
    static constraints = {
        groupName(unique: true)
    }
    static mapping = {
        table 'dj_system_param_group'
    }
}

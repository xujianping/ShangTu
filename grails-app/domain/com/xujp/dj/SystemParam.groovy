package com.xujp.dj
/***
 * 系统参数信息
 */
class SystemParam {
    SystemParamGroup group
    String paramCode
    String paramValue
    String paramDesc
    static constraints = {
        paramDesc(nullable: true)
    }
    static mapping = {
        table 'dj_system_param'
    }
}

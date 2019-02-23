package com.xujp.dj
/***
 * 上游公司信息
 */
class Company {
    String companyName  //公司名称
    String cutName  //简称
    String companyCode //公司代码
    static constraints = {
        companyName blank: false,unique: true
        cutName nullable: true, blank: true
        companyCode nullable: true, blank: true
    }
    static mapping = {
        table "dj_company"
    }
}

package com.xujp.dj

import com.util.enums.StationType
/**
 * 站点信息*/
class Station {
    /** 站点名称*/
    String stationName
    /** 站点代码*/
    String stationCode
    /** 简称*/
    String shortcut
    /*联系电话*/
    String phone
    /*站点类别*/
    StationType stationType
    static hasMany = [children: Station]
    /** 父站点*/
    static belongsTo = [parent: Station]

    def getNameAndCode() {
        stationName + "(" + stationCode + ")"
    }

    def getAllChildren() {
        return children ? children + children*.allChildren.flatten() : []
    }

    def getSelfAndChildren() {
        def list = children ? children + children*.allChildren.flatten() : []
        list << this
        return list
    }

    def getPingCutAndNameAndCode() {
        pingCut + " | " + stationName + " | " + stationCode
    }


    String toString() {
        stationName
    }

    static constraints = {
        shortcut nullable: true
        stationCode nullable: true, blank: true
        parent(nullable: true)
        phone nullable: true
        stationType nullable: true
    }
    static mapping = {
        table 'dj_station'
    }
}

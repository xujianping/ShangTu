package com.util.enums

/**
 * Created by Administrator on 2015/1/8.
 */
public enum StationType {
    HQ("中心"),
    MG("管理站"),
    ST("卸包点"),
    AR("区域")

    private final String description

    static StationType getType(String id){
        switch(id){
            case '0':
                StationType.HQ
                break
            case '1':
                StationType.MG
                break
            case '2':
                StationType.ST
                break
            case '3':
                StationType.AR
                break
            default:
                throw new Exception("站点类型不正确")
        }
    }
    /**
     * 通过文件内容匹配订单类型
     * @param name
     * @return
     */
    static StationType getTypeString(String name){
        switch(name){
            case '中心':
                StationType.HQ
                break
            case '管理站':
                StationType.MG
                break
            case '卸包点':
                StationType.ST
                break
            case '区域':
                StationType.AR
                break
        }
    }

    StationType(description) {
        this.description = description
    }
    String toString() {
        description
    }
}
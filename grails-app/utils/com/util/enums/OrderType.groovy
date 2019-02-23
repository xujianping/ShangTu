package com.util.enums
/**
 * 订单类型
 * Created by IntelliJ IDEA.
 * User: hww
 * Date: 12-5-9
 * Time: 下午4:53
 * To change this template use File | Settings | File Templates.
 */
public enum OrderType {
    DELIVER_ORDER("配送单"),
    DEPLOY_ORDER("直调单"),
    HQ_DEPLOY_ORDER("中心直调单")

    private final String description

    static OrderType getType(String id){
        switch(id){
            case '0':
                OrderType.DELIVER_ORDER
                break
            case '1':
                OrderType.DEPLOY_ORDER
                break
            case '2':
                OrderType.HQ_DEPLOY_ORDER
                break
            default:
                throw new Exception("订单类型不正确")
        }
   }
    /**
     * 通过文件内容匹配订单类型
     * @param name
     * @return
     */
    static OrderType getTypeString(String name){
        switch(name){
            case '配送单':
                OrderType.DELIVER_ORDER
                break
            case '直调单':
                OrderType.DEPLOY_ORDER
                break
            case '中心直调单':
                OrderType.HQ_DEPLOY_ORDER
                break
            default:
                throw new Exception("订单类型不正确")
        }
    }

    OrderType(description) {
        this.description = description
    }
    String toString() {
        description
    }

}
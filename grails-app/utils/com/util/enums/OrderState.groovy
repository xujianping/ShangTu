package com.util.enums

/**
 * 订单状态
 * Created by IntelliJ IDEA.
 * User: hww
 * Date: 12-5-6
 * Time: 上午11:52
 * To change this template use File | Settings | File Templates.
 */
public enum OrderState {
    WAIT_PICKUP('等待取件'),
    WAIT_WARE_ENTER('中心待入库'),
    WARE_ENTERED('中心已入库'),
    WARE_LEAVED('中心已出库'),
    STATION_ENTERED('站点已入库'),
    STATION_LEAVED('站点已出库'),
    STATION_RETURN_ENTERED('站点退货已入库'),
    STATION_RETURN_LEAVED('站点退货已出库'),
    WARE_RETURN_ENTERED('库房退货已入库'),
    DEPLOY_WAIT_ENTER('直调站点待入库'),
    DEPLOY_STATION_ENTERED('直调站点已入库'),
    DEPLOY_STATION_LEAVED('直调站点已出库')

    private final String description

    static OrderState getType(String id){
        switch(id){
            case '0':
                OrderState.WAIT_PICKUP
                break
            case '1':
                OrderState.WAIT_WARE_ENTER
                break
            case '2':
                OrderState.WARE_ENTERED
                break
            case '3':
                OrderState.WARE_LEAVED
                break
            case '4':
                OrderState.STATION_ENTERED
                break
            case '5':
                OrderState.STATION_LEAVED
                break
            case '6':
                OrderState.STATION_RETURN_ENTERED
                break
            case '7':
                OrderState.STATION_RETURN_LEAVED
                break
            case '8':
                OrderState.WARE_RETURN_ENTERED
                break
            case '9':
                OrderState.DEPLOY_WAIT_ENTER
                break
            case '10':
                OrderState.DEPLOY_STATION_ENTERED
                break
            case '11':
                OrderState.DEPLOY_STATION_ENTERED
                break
            default:
                throw new Exception("订单状态不正确")
        }  
    }
    OrderState(description) {
        this.description = description
    }

    String toString() {
        description
    }
}
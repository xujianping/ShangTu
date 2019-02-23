package com.util.enums

/**
 * 订单历史明细
 * Created by IntelliJ IDEA.
 * User: hww
 * Date: 12-5-9
 * Time: 下午4:16
 * To change this template use File | Settings | File Templates.
 */
public enum HistoryType {
    ORDER_COMPLETE("补全信息"),
    WARE_ENTER_CONFIRM("货品确认入库"),
    WARE_LEAVED_CONFIRM("货品确认出库"),
    STATION_ENTER_CONFIRM("站点确认入库"),
    STATION_LEAVED_CONFIRM("站点确认出库"),
    DEPLOY_WARE_ENTER_CONFIRM("直调货品确认入库"),
    DEPLOY_WARE_LEAVED_CONFIRM("直调货品确认出库"),
    DEPLOY_STATION_ENTER_CONFIRM("直调站点确认入库"),
    DEPLOY_STATION_LEAVED_CONFIRM("直调站点确认出库"),
    DISPATCH_POSTER("分配快递员"),
    UPDATE_POSTER("修改快递员"),
    SUBMIT_REJECT("提交拒收"),
    ERROR_END("异常终结"),
    FINISH_COLLECTED("妥投确认"),
    ORDER_UPDATE("修改订单信息"),
    SUBMIT_SCANER("提报异常"),
    OVER_SCANER("处理异常")

    private final String description

    HistoryType(description) {
        this.description = description
    }

    String toString() {
        description
    }
}
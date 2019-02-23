package com.util.enums

/**
 * 批次类型
 * Created by IntelliJ IDEA.
 * User: hww
 * Date: 12-5-9
 * Time: 上午11:49
 * To change this template use File | Settings | File Templates.
 *   RO:接收订单批次
 *   WI:入库批次
 *   WL:出库批次
 *
 */
public enum BatchType {
    WI("WI"),//库房入库
    WL("WL"),//库房出库
    SI("SI"),//站点入库
    SL("SL"),//站点出库
    SRI("SRI"),//站点退货入库
    SRL("SRL"),//站点退货出库
    WRI("WRI"),//库房退货入库
    WRL("WRL"),//库房退货出库
    RO("RO"),//退货出库
    DL("DL")//直调站点出库
    private final String description

    BatchType(description) {
        this.description = description
    }

    String toString() {
        description
    }
}
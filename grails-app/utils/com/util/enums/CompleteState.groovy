package com.util.enums

/**
 * Created by Administrator on 2015/1/8.
 * 完成状态
 */
public enum CompleteState {
    ON_WAY('在途'),
    COMPLETED('妥投已完成'),
    REJECTED('拒收已完成'),
    ABNORMAL_FINISHED('异常终结')

    private final String description

    static CompleteState getType(String id){
        switch(id){
            case '0':
                CompleteState.ON_WAY
                break
            case '1':
                CompleteState.COMPLETED
                break
            case '2':
                CompleteState.REJECTED
                break
            case '3':
                CompleteState.ABNORMAL_FINISHED
                break
            default:
                throw new Exception("完成状态不正确")
        }
    }

    CompleteState(description) {
        this.description = description
    }
    String toString() {
        description
    }
}
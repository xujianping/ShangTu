package com.util

/**
 * Created by IntelliJ IDEA.
 * User: hww
 * Date: 12-5-4
 * Time: 下午2:00
 * To change this template use File | Settings | File Templates.
 */
class JSONData {
    def data
    def totalCount
    boolean success = true
    def alertMsg
    def soundMsg
    def stationCode
    def stationName
    def remarkMsg

    String toString() {
        "{success:" + success + ",alertMsg:'" + alertMsg +"',soundMsg:'" + soundMsg + "',remarkMsg:'"+ remarkMsg +"'}"
    }
}


package com.util

import com.xujp.dj.Station


/**
 * Created by IntelliJ IDEA.
 * User: hww
 * Date: 12-5-18
 * Time: 下午10:40
 * To change this template use File | Settings | File Templates.
 */
class Menu {
    Long id
    String text
    Boolean leaf
    Boolean checked
    List<Menu> children = []
    String cls

    /**
     *
     * @param station
     * @param selectType ALL：所有都有多选框，SELECTEDLEAF:子节点有多选框 ,NOTSELECT:无多选框
     */
    public Menu(Station station, String selectType){
        id =  station.id
        text = station.stationName
        checked = false
        if(station.children.empty){
            cls ='file'
            leaf = true
            switch (selectType){
                case 'ALL':
                    checked = false
                    break;
                case 'SELECTEDLEAF':
                    checked = false
                    break
                case 'NOTSELECT':
                    break
            }
        }else{
            cls ='folder'
            leaf = false
            switch (selectType){
                case 'ALL':
                    checked = false
                    break
                case 'SELECTEDLEAF':
                    break
                case 'NOTSELECT':
                    break
            }
            station.children.each {
                def menu = new Menu(it,selectType)
                children.add(menu)
            }
        }
    }
}


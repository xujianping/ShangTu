package com.xujp.dj


import com.xujp.dj.auth.Action
import com.xujp.dj.auth.RequestMap
import com.xujp.dj.auth.User
import grails.plugin.springsecurity.SpringSecurityUtils

import java.text.SimpleDateFormat

/**
 * 登陆
 */
class MainController {
    def springSecurityService
    def orderService
    def dataSource
    def sdfymd = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss')

    def index = {
        User
        def user = springSecurityService.currentUser
        log.info "用户【${user.username}】登录成功!登录IP为:${request.getRemoteAddr()}"
        def actions = new HashSet<Action>()
        SpringSecurityUtils.principalAuthorities.each {
            actions.addAll RequestMap.findAllByConfigAttributeLike("%${it.authority}%")*.action
        }
        def systemParamGroup = SystemParamGroup.findByGroupName("系统设置")
        def systemParams = SystemParam?.findAllByGroup(systemParamGroup)
        def map = [:]
        systemParams?.each { systemParam ->
            map."${systemParam.paramCode}" = "${systemParam.paramValue}"
        }

        def currentStation = user.station
        def stationIds = []
        orderService.getSelfChildIdsByStation(currentStation).split(",").each {
            stationIds << it.toLong()
        }
        if (!session.getValue('user')) {
            session.putValue("user", user)
        }
        if (!session.getValue('currentStation')) {
            session.putValue("currentStation", currentStation)
        }
        if (!session.getValue('stationIds')) {
            session.putValue("stationIds", stationIds)
        }
        if (!session.getValue('sysParms')) {
            session.putValue("sysParms", map)
        }
        render(view: '/main', model: [user: user, actions: actions.sort { [it.sortNum, it.groupName, it.title] }])
    }


}

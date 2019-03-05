package com.xujp.dj.auth


import com.xujp.dj.auth.User
import grails.converters.JSON

class PassWordEditController {
    def springSecurityService
    def index = {
        render(view: "/passWordEdit/index", params: params)
    }


    /**
     * 保存
     */
    def save = {
        User CurrentUser = springSecurityService.getCurrentUser()
        def password = springSecurityService.encodePassword(CurrentUser?.password)

        def jsonData = [success: true]
        if (params?.passWord){
            params.passWord = springSecurityService.encodePassword(params.passWord)
            if (params.passWord.equals(CurrentUser.password)){
                try{
                    CurrentUser?.password = springSecurityService.encodePassword(params?.newPassWord)
                    CurrentUser.save(flush: true)
                }catch (Exception e){
                    log.info(e)
                    jsonData = [success: false]
                    render jsonData as JSON
                    return
                }
                jsonData = [success: true]
                render jsonData as JSON
            } else{
                jsonData = [success: false,alertMsg: "初始密码错误，请联系管理员"]
                render jsonData as JSON
            }

        } else{
            jsonData = [success: false, alertMsg: "密码输入为空，没有修改"]
            render jsonData as JSON
            return
        }
        render jsonData as JSON;
    }
}

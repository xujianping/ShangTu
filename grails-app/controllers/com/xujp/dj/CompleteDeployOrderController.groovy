package com.xujp.dj

import com.util.JSONData
import dj.BusinessException

class CompleteDeployOrderController {
    def orderService

    def index() { }

    /**
     * 补全订单信息
     */
    def save = {
        def jsonData = new JSONData()
//        try {
//            if (request instanceof MultipartHttpServletRequest) {
//                MultipartHttpServletRequest multipartHttpServletRequest = (MultipartHttpServletRequest) request
//                def file = (CommonsMultipartFile) multipartHttpServletRequest.getFile('orderFile')
//                def msg = orderService.completeDeployOrder(file.inputStream)
//                jsonData = new JSONData([success: true, alertMsg: "上传订单成功！${msg}"])
//                if(!file.inputStream){
//                    file.inputStream.close()
//                }
//            }
//        }catch (BusinessException e){
//            log.error(e.getMessage())
//            jsonData = new JSONData([success: false, alertMsg: e.message])
//        }catch (Exception e) {
//            log.error(e.printStackTrace())
//            jsonData = new JSONData([success: false, alertMsg: '未知错误!请检查上传文件。'])
//        }
        render jsonData
    }
}

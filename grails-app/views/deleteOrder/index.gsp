<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 12-11-20
  Time: 上午9:38
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="ext"/>
    <link rel="stylesheet" href="${resource(dir:'css',file:'ext_icon.css')}"/>
    <g:javascript src="common.js"/>
    <g:javascript src="ext-lang-zh_CN.js"/>
    <style type="text/css" >
    .resultError{
        color:red;
    }
    </style>
    <script type="text/javascript">
        Ext.onReady(function(){
            Ext.tip.QuickTipManager.init();
            var mainForm = Ext.create('Ext.form.Panel',{
                margin: '40 4 10',
                bodyPadding: '8 0 0 0',
                autoHeight:true,
                border:0,
                renderTo: Ext.getBody(),
                layout:{
                    type:'table',
                    columns:5
                },
                items:[
                    {
                        fieldLabel:'删除订单',
                        xtype:'textarea',
                        id:'freightNo',
                        name:'freightNo',
                        width: 400,
                        height:220,
                        labelStyle:'margin-top:90 ;width:100',
                        style:"margin-left: 60;margin-top:20;",
                        blank:false
                    },
                    {
                        xtype:'textarea',
                        id:'resultErrorInfo',
                        height:220,
                        width:440,
                        fieldLabel: '处理结果',
                        labelStyle:'margin-top:90 ;width:100',
                        style:"margin-left: 60;margin-top:20;",
                        readOnly:true
                    }
                ],
                buttonAlign:'center',
                buttons:[
                    {
                        iconCls:'acceptIcon',
                        margin:'40 0 0 0',
                        text:'提交',
                        handler:function () {
                            Ext.getCmp("resultErrorInfo").setValue('');
                            var freightNos = Ext.getCmp('freightNo').getValue();
                            if (!freightNos ) {
                                Ext.getCmp("resultErrorInfo").setValue('');
                                Ext.MessageBox.show({title:'错误:',msg:'"订单号为空，请填写！' , width:350,height:200, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                return;
                            }
                            if (freightNos.split("\r\n").length > 999) {
                                Ext.MessageBox.show({title:'错误:',msg:'批量订单每次操作不能超过1000条！' , width:350,height:200, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                return;
                            }else{
                                Ext.MessageBox.confirm("标题", "是否确认提交？", function (btn) {
                                    if(btn =='yes'){
                                        var myMask = new Ext.LoadMask(Ext.getBody(), {
                                            msg:'正在删除，请稍后！',
                                            removeMask:true
                                        });
                                        myMask.show();
                                        Ext.Ajax.request({
                                            url:'<g:createLink action="remove"/>',
                                            method:'POST',
                                            params:{freightNos:freightNos},
                                            timeout:18000,
                                            success:function (r) {
                                                myMask.hide();
                                                var result = Ext.JSON.decode(r.responseText);
                                                if(result.success){
                                                    Ext.MessageBox.show({title:'提示:', msg:"批量删除成功!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                                    Ext.getCmp("resultErrorInfo").setValue('');
                                                    Ext.getCmp("freightNo").setValue('');
                                                }else{
                                                    Ext.getCmp("resultErrorInfo").setValue('');
                                                    Ext.getCmp("resultErrorInfo").setValue(result.alertMsg);
                                                }
                                            },
                                            failure:function (r) {
                                                myMask.hide();
                                                Ext.MessageBox.show({title:'提示:', msg:"网络响应失败,请刷新页面重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                            }
                                        });
                                    }
                                });
                            }
                        }
                    },
                    {
                        text:'清空',
                        iconCls:'deleteIcon',
                        margin:'20 0 0 10',
                        handler:function () {
                            mainForm.form.reset();//清空表单
                        }
                    }
                ]
            });
            mainForm.show();
        });
    </script>
</head>
<body>

</body>
</html>
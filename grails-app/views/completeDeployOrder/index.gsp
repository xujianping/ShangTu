<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2015/1/12
  Time: 11:48
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="ext"/>
    <link rel="stylesheet" href="${resource(dir:'css',file:'ext_icon.css')}"/>
    <g:javascript src="common.js"></g:javascript>
    <g:javascript src="dateTimePicker.js"></g:javascript>
    <g:javascript src="dateTimeField.js"></g:javascript>
    <g:javascript src="ext-lang-zh_CN.js"></g:javascript>
    <script type="text/javascript">
        Ext.onReady(function () {
            Ext.tip.QuickTipManager.init();

            var importForm =  Ext.create('Ext.form.Panel', {
                height: 120,
                frame:true,
                margin:5,
                width:document.body.clientWidth-10,
                bodyPadding: 10,
                title: '上传订单文件',
                renderTo:Ext.getBody(),
                style:'padding:10px 10px 0',
                buttonAlign:'center',
                buttons:[
                    {
                        text:'上传',
                        iconCls:'acceptIcon',
                        disabled:false,
                        handler:function () {

                            if(importForm.form.isValid()){
                                importForm.form.submit({
                                    method:'POST',
                                    clientValidation : true,
                                    type:'submit',
                                    waitTitle : '请稍候',
                                    waitMsg : '正在上传中......',
                                    url: '<g:createLink  action="save" />',
                                    success: function(fp, o) {
                                        importForm.form.findField('orderFile').setRawValue('');
                                        Ext.MessageBox.show({title:'提示:', msg:o.result.alertMsg, width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                    },failure:function(fp,o){
                                        importForm.form.findField('orderFile').setRawValue('');
                                        Ext.MessageBox.show({title:'提示:', msg:o.result.alertMsg, width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                    }
                                });
                            }
                        }
                    },
                    {
                        text:'清空',
                        iconCls:'deleteIcon',
                        handler:function () {
                            importForm.form.reset();//清空表单
                            importForm.form.findField('orderFile').setRawValue('');
                        }
                    },
                    {
                        xtype:'button',
                        text:'下载模板文件',
                        iconCls:'downloadIcon',
                        handler:function () {
                            window.open('../exportTempl/ImportDeployOrder.xls')
                        }
                    }
                ],
                items: [
                    {
                        xtype: 'filefield',
                        msgTarget: 'side',
                        fieldLabel: '订单文件',
                        buttonText:'选择文件',
                        name:'orderFile',
                        allowBlank: false,
                        anchor: '40%'
                    }
                ]
            });
            importForm.show();
        });
    </script>
</head>

<body>

</body>
</html>
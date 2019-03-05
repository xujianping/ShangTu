<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 12-8-27
  Time: 下午1:55
  To change this template use File | Settings | File Templates.
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
        var userForm =  Ext.create('Ext.form.Panel', {
            border:1,
            frame : true,
            title:'密码修改',
            width:document.body.clientWidth*0.99,
            height: document.body.clientHeight*0.91,
           margin:10,
            x:2,
            y:3,
            renderTo:'searchDiv',
            defaultType:'textfield',
            items: [
                {
                    x: document.body.clientWidth*0.32,
                    y: 20,
                    fieldLabel: '原密码',
                    allowBlank:false,
                    name:'passWord',
                    inputType : 'password'
                },{
                    x: document.body.clientWidth*0.32,
                    y:30,
                    fieldLabel: '新密码',
                    allowBlank:false,
                    name:'newPassWord',
                    inputType : 'password'
                },{
                    x: document.body.clientWidth*0.32,
                    y:40,
                    fieldLabel: '新密码',
                    allowBlank:false,
                    name:'againPassWord',
                    inputType:'password'
                },{
                    xtype: 'button',
                    x: document.body.clientWidth*0.35,
                    y:55,
                    width:80,
                    iconCls:'acceptIcon',
                    text:'提交',
                    handler:function () {
                       if(userForm.form.isValid()){
                           if(userForm.getValues().newPassWord !=userForm.getValues().againPassWord){
                               Ext.Msg.alert('信息', '两次密码输入不一致，请检查!');
                               return false;
                           }
                           Ext.MessageBox.wait("正在保存数据,稍后......");
                           userForm.form.submit({
                               url:'<g:createLink action="save"/>',
                               success:function (form, action) {
                                   Ext.MessageBox.hide();
                                   Ext.MessageBox.show({title:'提示:', msg:'修改信息成功!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                   userForm.form.reset();//清空表单
                               },
                               failure:function (form, action) {
                                   Ext.MessageBox.hide();
                                   if(!action.hasOwnProperty("result"))
                                       Ext.MessageBox.show({title:'提示:', msg:'修改信息失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                   else
                                       Ext.MessageBox.show({title:'提示:',msg:action.result.alertMsg , width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                               }
                           });
                       }
                    }
                },{
                    xtype: 'button',
                    x: document.body.clientWidth*0.32+70,
                    y:55,
                    width:80,
                    iconCls:'wrenchIcon',
                    text:'清空',
                    handler:function () {
                        userForm.form.reset();
                    }
                }
            ]
        });
        userForm.show();
    });

    </script>
</head>
<body>
    <div id="searchDiv" ></div>
</body>
</html>
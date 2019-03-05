<html>
<head>
    <meta name="layout" content="ext"/>
    <title><g:message code='sys.name'/></title>
    <script type="text/javascript">
        Ext.onReady(function () {
            Ext.tip.QuickTipManager.init();
            var loginForm = Ext.create('Ext.form.Panel', {
                //collapsible : true,// 是否可以展开
                height:130,
                width:420,
                frame:false,
                style:'background:#fff;',
                waitMsgTarget:true,
                items:[

                    {
                        xtype:'textfield',
                        id:'username',
                        fieldLabel:'用户名',
                        allowBlank:false,
                        name:"${usernameParameter ?: 'username'}",
                        minLength:4,
                        width:260,
                        x:70,
                        y:30
                    },
                    {
                        xtype:'textfield',
                        fieldLabel:'密&nbsp;&nbsp;&nbsp;码',
                        allowBlank:false,
                        name:"${passwordParameter ?: 'password'}",
                        id:'password',
                        inputType: 'password',
                        width:260,
                        x:70,
                        y:60,
                        listeners:{
                            specialkey:function (field, e) {
                                if (e.getKey() == Ext.EventObject.ENTER) {
                                    if (loginForm.form.isValid()) {
                                        Ext.MessageBox.wait("登录中,稍后......");
                                        var formValue = loginForm.form.getValues();
                                        Ext.Ajax.request({
                                            url:'${postUrl ?: '/login/authenticate'}',
                                            method:'POST',
                                            params:formValue,
                                            success:function (r) {
                                                Ext.MessageBox.hide();
                                                var result = Ext.JSON.decode(r.responseText);
                                                if (result.success == true) {
                                                    window.location = '<g:createLink  controller="main"/>';
                                                } else {
                                                    Ext.MessageBox.show({title:'提示:', msg:'登录失败!' + result.alertMsg, width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                                }
                                            },
                                            failure:function (r) {
                                                Ext.MessageBox.hide();
                                                Ext.MessageBox.show({title:'提示:', msg:'连接服务器失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                            }
                                        });
                                    }
                                }
                            }
                        }
                    }
                ]
            });
            var win = Ext.create('Ext.window.Window', {
                height:275,
                width:433,
                closable:false,
                collapsible:false,
                buttonAlign:'center',
                style:'background:#fff;',
                draggable:false,
                resizable:false,
                buttons:[
                    {
                        text:'登录',
                        iconCls:'acceptIcon',
                        handler:function () {
                            if (loginForm.form.isValid()) {
                                Ext.MessageBox.wait("登录中,稍后......");
                                var formValue = loginForm.form.getValues();
                                Ext.Ajax.request({
                                    url:'${postUrl ?: '/login/authenticate'}',
                                    method:'POST',
                                    params:formValue,
                                    success:function (r) {
                                        Ext.MessageBox.hide();
                                        var result = Ext.JSON.decode(r.responseText);
                                        if (result.success == true) {
                                            window.location = '<g:createLink  controller="main"/>';
                                        } else {
                                            Ext.MessageBox.show({title:'提示:', msg:'登录失败!' + result.alertMsg, width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                        }
                                    },
                                    failure:function (r) {
                                        Ext.MessageBox.hide();
                                        Ext.MessageBox.show({title:'提示:', msg:'连接服务器失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                    }
                                });
                            }
                        }
                    },
                    {
                        text:'重置',
                        iconCls:'deleteIcon',
                        handler:function(){
                            loginForm.form.reset();
                        }
                    },
                    {
                        text:'语音安装',
                        iconCls:'downloadIcon',
                        handler:function () {
                            window.open('<g:createLink  controller="login" action="download"/>')
                            Ext.MessageBox.wait("正在下载,请稍后......");
                            setTimeout("javascript:Ext.MessageBox.hide();", 3000);

                        }
                    }
                ],
                title:'欢迎登录<g:message code="sys.name"/>',

                items:[
                    {
                        xtype:'container',
                        height:80,
                        style:'background:#fff;',
                        html:'<img src="${resource(dir:'images',file:'logo.png')}" style="height:60px;margin:8px;">'
                    },
                    loginForm
                ]
            });
            win.show();
            Ext.getCmp('userNameId').focus(false, 150);
        });
    </script>
</head>

<body>
<div style="width: 100%;height: 100%;background-image:src ='${resource(dir:'images',file:'bg1.png')}'"></div>
</body>
</html>

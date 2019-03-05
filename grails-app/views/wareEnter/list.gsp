<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2015/1/9
  Time: 11:13
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<g:javascript src="jquery-1.6.3.min.js"/>
<meta name="layout" content="ext"/>
<link rel="stylesheet" href="${resource(dir: 'css', file: 'ext_icon.css')}"/>
<g:javascript src="common.js"/>
<g:javascript src="dateTimePicker.js"></g:javascript>
<g:javascript src="dateTimeField.js"></g:javascript>
<g:javascript src="ext-lang-zh_CN.js"/>
<g:javascript src="jquery-barcode-2.0.2.min.js"/>
<style type="text/css">
.resultError {
    color: red;
}
</style>

<script type="text/javascript">
    Ext.onReady(function () {
        Ext.tip.QuickTipManager.init();

        var g_speaker;
        try {
            if (!g_speaker) {
                g_speaker = new ActiveXObject("Sapi.SpVoice");
            }
        } catch (e) {
            Ext.MessageBox.show({title:'注意:', msg:'初始化语音模块失败!' + e, width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
            g_speaker = null;
        };

        var enteredNum = 0
        var trueNum = 0
        var wareEnterForm = Ext.create('Ext.form.Panel', {
            height: 210,
            iframe:true,
            width:document.body.clientWidth-10,
            frame : true,
            bodyPadding: 10,
            margin:2,
            layout:{
                type:'table',
                columns:5
            },
            items:[
                {
                    colspan:3,
                    fieldLabel:'订单号',
                    id:'freightNoId',
                    name:'freightNo',
                    xtype:'textfield',
                    minLength:4,
                    height:52,
                    style:'padding:6px 0px 0;',
                    labelStyle:'font-size:20px;line-height:100%;padding-right:3px;',
                    fieldStyle:'font-size:40px;line-height:100%;',
                    allowBlank:false,
                    width:400,
                    margin:'0 20 20 0',
                    listeners:{
                        specialkey:function (field, e) {
                            if (e.getKey() == Ext.EventObject.ENTER) {
                                var freightNo = wareEnterForm.form.getValues().freightNo;
                                if (freightNo.length > 3) {
                                    var myMask = new Ext.LoadMask(Ext.getBody(), {msg:'正在保存，请稍后！', removeMask:true });
                                    myMask.show();
                                    this.setDisabled(true)

                                    Ext.Ajax.request({
                                        url:'<g:createLink action="save"/>',
                                        params:{freightNo:freightNo},
                                        success:function (r) {
                                            myMask.hide();
                                            Ext.getCmp("freightNoId").setDisabled(false)
                                            Ext.getCmp("freightNoId").focus();
                                            var result = Ext.JSON.decode(r.responseText);
                                            myMask.hide();
                                            enteredNum ++ ;
                                            Ext.getCmp("enteredNum").setValue(enteredNum);
                                            if (result.success) {
                                                try {
                                                    g_speaker.Speak("成功", 1);
                                                } catch (e) {
                                                }
                                                trueNum ++;
                                                Ext.getCmp("trueNum").setValue(trueNum);
                                                Ext.getCmp("resultInfo").removeCls("resultError");
                                                Ext.getCmp("resultInfo").setText("结果：" + result.alertMsg);
                                                Ext.getCmp('freightNoId').setValue("");
                                            } else {
                                                myMask.hide();
                                                try {
                                                    g_speaker.Speak(result.soundMsg, 1);
                                                } catch (e) {
                                                }
                                                Ext.getCmp("resultInfo").addCls("resultError");
                                                Ext.getCmp("resultInfo").setText("结果：" + result.alertMsg);
                                                Ext.getCmp('freightNoId').setValue("");
                                            }
                                        },
                                        failure:function (r) {
                                            myMask.hide();
                                            Ext.getCmp("resultInfo").addCls("resultError");
                                            Ext.getCmp("freightNoId").setDisabled(false)
                                            Ext.getCmp("freightNoId").focus();
                                            Ext.MessageBox.show({title:'提示:', msg:"货品入库失败,请重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                            return
                                        }
                                    });
                                } else {
                                    Ext.getCmp('freightNoId').setValue("");
                                    Ext.getCmp("resultInfo").setText("结果：订单号长度不正确");
                                    return false;
                                }
                            }
                        }
                    }
                },
                {
                    colspan:2,
                    height:30,
                    xtype:'label',
                    id:'resultInfo',
                    text:'结果:无',
                    style:'font-size:22px;padding:10px 20px;margin-top:5px;margin-bottom:20px;'
                },
                {
                    colspan:2,
                    fieldLabel:'扫描单数',
                    id:'enteredNum',
                    xtype:'textfield',
                    labelStyle:'font-size:20px;line-height:100%;padding-right:3px',
                    fieldStyle:'font-size:20px;line-height:100%;',
                    height:30,
                    editable:false,
                    allowBlank:false,
                    disabled:false,
                    readOnly:true,
                    value:0,
                    width:180,
                    margin:'0 20 20 0'
                },
                {
                    colspan:2,
                    fieldLabel:'成功单数',
                    id:'trueNum',
                    xtype:'textfield',
                    labelStyle:'font-size:20px;line-height:100%;padding-right:3px;color:red',
                    fieldStyle:'font-size:20px;line-height:100%;',
                    height:30,
                    editable:false,
                    allowBlank:false,
                    disabled:false,
                    readOnly:true,
                    value:0,
                    width:180,
                    margin:'0 20 20 0'

                },
                {
                    xtype:'button',
                    text:'清零',
                    iconCls:'buildingIcon',
                    style:'padding:10px 10px;font-size:30px;height:50px;',
                    width:100,
                    listeners:{
                        click:function (field, e) {
                            Ext.getCmp("enteredNum").setValue(0);
                            Ext.getCmp("trueNum").setValue(0);
                        }
                    }
                }
            ]
        });

        var wareBeachEnterForm = Ext.create('Ext.form.Panel', {
            bodyStyle :"overflow-x:auto;overflow-y:hidden",
            border:0,
            padding:20,
            layout:{
                type:'table',
                columns:5
            },
            items:[
                {
                    xtype:'fieldcontainer',
                    colspan:2,
                    width:166,
                    margin:'0 20 20 0',
                    items:[
                        {
                            xtype:'textarea',
                            labelWidth:100,
                            height:150,
                            width:340,
                            fieldLabel:'批量订单',
                            labelStyle:'font-size:20px;line-height:100%;padding-top:58px',
                            id:'freightNos',
                            name:'freightNos'

                        },
                        {
                            xtype:'button',
                            width:100,
                            iconCls:'acceptIcon',
                            margin:'10 0 0 170',
                            text:'提交',
                            listeners:{
                                'click':function () {
                                    Ext.getCmp("resultSuccInfos").setValue("结果：");
                                    Ext.getCmp("resultErrorInfo").setValue('');
                                    var freightNos = Ext.getCmp('freightNos').getValue();
                                    if (!freightNos) {
                                        Ext.getCmp("resultSuccInfos").setValue("结果：无订单信息不能提交！");
                                        Ext.getCmp("resultErrorInfo").setValue('');
                                        return;
                                    }
                                    if (freightNos.split("\r\n").length > 1000) {
                                        Ext.Msg.alert("信息", "批量订单每次操作不能超过1000条!");
                                        return;
                                    }
                                    var myMask = new Ext.LoadMask(Ext.getBody(), {
                                        msg:'正在保存，请稍后！',
                                        removeMask:true
                                    });
                                    myMask.show();
                                    Ext.Ajax.request({
                                        url:'<g:createLink action="enterBathOrder"/>',
                                        params:{freightNos:freightNos},
                                        timeout:180000,
                                        success:function (r) {
                                            myMask.hide();
                                            var result = Ext.JSON.decode(r.responseText);
                                            var failureInfos = ''
                                            var m = 0;
                                            for (var i = 0; i < result.length; i++) {
                                                if (result[i].success == false) {
                                                    failureInfos += result[i].alertMsg + "\r\n"
                                                    m++
                                                }
                                            }
                                            if (m == 0) {
                                                Ext.getCmp("resultSuccInfos").setValue("结果：全部成功！");
                                                Ext.getCmp("resultErrorInfo").setValue('');
                                                Ext.getCmp('freightNos').setValue("");
                                            } else {
                                                Ext.getCmp("resultErrorInfo").setValue(failureInfos);
                                                Ext.getCmp("resultSuccInfos").setValue("结果：本批扫描【" + eval(result.length - m) + "】单成功!【" + m + "】单失败!");
                                                Ext.getCmp('freightNos').setValue("");
                                            }
                                        },
                                        failure:function (r) {
                                            myMask.hide();
                                            Ext.MessageBox.show({title:'提示:', msg:"批量扫描失败,请重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                        }
                                    });
                                }
                            }
                        }
                    ]
                },
                {
                    colspan:3,
                    xtype:'fieldcontainer',
                    layout:'anchor',
                    flex:-1,
                    width:500,
                    margin:'-30 0 0 200',
                    items:[
                        {
                            anchor:'90%',
                            width:450,
                            id:'resultSuccInfos',
                            xtype:'displayfield',
                            fieldStyle:'font-size:18px;',
                            value:'结果：'
                        },
                        {
                            anchor:'90%',
                            width:450,
                            id:'resultErrorInfo',
                            xtype:'textarea',
                            height:130,
                            readOnly:true,
                            fieldStyle:'color:red;font-size:22px;line-height:120%;'
                        }
                    ]
                }
            ]
        });

        //主框架
        var tabs = Ext.createWidget('tabpanel', {
            activeTab:0,
            width:document.body.clientWidth - 4,
            height:document.body.clientHeight - 10,
            renderTo:Ext.getBody(),
            style:'padding:2px',
            autoHeight:true,
            items:[
                {
                    title:'单个入库',
                    xtype:'container',
                    items:wareEnterForm
                },
                {
                    title:'批量入库',
                    xtype:'container',
                    items:wareBeachEnterForm
                }
            ]
        });
        Ext.getCmp('freightNoId').focus(false, 100);
        tabs.show();



    });
</script>
</head>

<body>
</body>
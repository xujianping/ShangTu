<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="layout" content="ext"/>
<link rel="stylesheet" href="${resource(dir: 'css', file: 'ext_icon.css')}"/>
<g:javascript src="common.js"/>
<g:javascript src="ext-lang-zh_CN.js"/>
<style type="text/css">
.resultError {
    color: red;
}
</style>

<script type="text/javascript">
    Ext.onReady(function () {
        Ext.tip.QuickTipManager.init();
        var stationData = [];
        <g:each in="${stations}">
        stationData.push([${it.id}, '${it.nameAndCode}']);
        </g:each>
        //出库批次
        var batchNoData = [];
        <g:each in="${batchNoData}">
        batchNoData.push(['${it}', '${it}']);
        </g:each>

        var g_speaker;
        try {
            if (!g_speaker) {
                g_speaker = new ActiveXObject("Sapi.SpVoice");
            }
        } catch (e) {
            Ext.MessageBox.show({title: '注意:', msg: '初始化语音模块失败!' + e, width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
            g_speaker = null;
        }

        var wareLeaveForm = Ext.create('Ext.form.Panel', {
            border: 0,
            margin: '20 0 0 20',
            padding: 5,
            width: document.body.clientWidth - 10,
            height: document.body.clientHeight - 10,
            autoScroll: true,
            layout: {
                type: 'table',
                columns: 1
            },
            renderTo: Ext.getBody(),
            items: [
                {
                    xtype: 'combobox',
                    fieldLabel: '目标站名',
                    hiddenName: 'stationId',
                    id: 'stationId',
                    editable: true,
                    allowBlank: false,
                    emptyText: '请选择...', //为空时的提示
                    triggerAction: 'all', //每次都弹出所有可选项
                    forceSelection: true, //只有选择项是合法的
                    selectOnFocus: true, //获得焦点时选中输入域文本
                    store: new Ext.data.ArrayStore({
                        fields: ['id', 'nameAndCode'],
                        data: stationData
                    }),
                    valueField: 'id',
                    displayField: 'nameAndCode',
                    labelStyle: 'font-size:16px;line-height:100%;padding-right:3px;',
                    fieldStyle: 'font-size:32px;height:40px;line-height:100%;',
                    colspan: 2,
                    height: 50,
                    width: 480
                },
                {
                    labelStyle: 'font-size:16px;line-height:100%;padding-right:3px;',
                    fieldStyle: 'font-size:32px;height:40px;line-height:100%;',
                    colspan: 2,
                    height: 50,
                    width: 480,
                    xtype: 'combobox',
                    fieldLabel: '出库批次',
                    name: 'batchNo',
                    id: 'batchNo',
                    queryMode: 'local', //本地数据
                    allowBlank: true,
                    editable: false,
                    multiSelect: false,
                    store: new Ext.data.ArrayStore({
                        fields: ['key', 'name'],
                        data: batchNoData
                    }),
                    valueField: 'key',
                    displayField: 'name'
                },
                {
                    fieldLabel: '出库包裹',
                    id: 'packingNo',
                    name: 'packingNo',
                    xtype: 'textfield',
                    minLength: 4,
                    style: 'padding:10px 0px 0;',
                    labelStyle: 'font-size:16px;line-height:100%;padding-right:3px;',
                    fieldStyle: 'font-size:40px;line-height:100%;',
                    height: 48,
                    width: 480,
                    allowBlank: false
                },
                {
                    fieldLabel: '订单号',
                    id: 'freightNoId',
                    name: 'freightNo',
                    xtype: 'textfield',
                    minLength: 4,
                    style: 'padding:10px 0px 0;',
                    labelStyle: 'font-size:16px;line-height:100%;padding-right:3px;',
                    fieldStyle: 'font-size:40px;line-height:100%;',
                    height: 48,
                    allowBlank: false,
                    width: 480,
                    listeners: {
                        specialkey: function (field, e) {
                            if (e.getKey() == Ext.EventObject.ENTER) {
                                var freightNo = wareLeaveForm.form.getValues().freightNo;
                                var batchNo = Ext.getCmp('batchNo').value;
                                var packingNo = Ext.getCmp('packingNo').value;
                                var stationId = Ext.getCmp('stationId').value;
                                if (stationId == '') {
                                    Ext.getCmp('freightNoId').setValue("");
                                    Ext.getCmp("resultInfo").addCls("resultError");
                                    Ext.getCmp("resultInfo").setText("结果：出库站点必须选择!");
                                    //Ext.MessageBox.show({title:'提示:', msg:'出库站点必须选择!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                    return;
                                }
                                if (batchNo == undefined || batchNo == '' || batchNo.length <= 3) {
                                    Ext.getCmp('freightNoId').setValue("");
                                    Ext.getCmp("resultInfo").addCls("resultError");
                                    Ext.getCmp("resultInfo").setText("结果：出库批次号必须填写!");
                                    //Ext.MessageBox.show({title:'提示:', msg:'出库站点必须选择!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                    return;
                                }
                                if (packingNo == undefined || packingNo == '' || packingNo.length <= 3) {
                                    Ext.getCmp('freightNoId').setValue("");
                                    Ext.getCmp("resultInfo").addCls("resultError");
                                    Ext.getCmp("resultInfo").setText("结果：出库包裹号必须填写!");
                                    //Ext.MessageBox.show({title:'提示:', msg:'出库站点必须选择!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                    return;
                                }
                                if (freightNo == undefined || freightNo == '' || freightNo.length <= 3) {
                                    Ext.getCmp('freightNoId').setValue("");
                                    Ext.getCmp("resultInfo").addCls("resultError");
                                    Ext.getCmp("resultInfo").setText("结果：订单号长度不正确!")
                                    // Ext.MessageBox.show({title:'提示:', msg:'订单号长度不正确!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                    return;
                                }
                                var myMask = new Ext.LoadMask(Ext.getBody(), {msg: '正在保存，请稍后！', removeMask: true });
                                myMask.show();
                                this.setDisabled(true)

                                Ext.Ajax.request({
                                    url: '<g:createLink action="save"/>',
                                    params: {freightNo: freightNo, stationId: stationId, batchNo: batchNo, packingNo: packingNo},
                                    success: function (r) {
                                        myMask.hide();
                                        Ext.getCmp("freightNoId").setDisabled(false)
                                        Ext.getCmp("freightNoId").focus();
                                        Ext.getCmp('freightNoId').setValue("");

                                        var result = Ext.JSON.decode(r.responseText);
                                        if (result.success) {
                                            try {
                                                g_speaker.Speak("成功", 1);
                                            } catch (e) {
                                            }
                                            Ext.getCmp("resultInfo").removeCls("resultError");
                                            Ext.getCmp("resultInfo").setText("结果：" + result.alertMsg);
                                            // Ext.MessageBox.show({title:'提示:', msg:'保存信息成功!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                        } else {
                                            try {
                                                g_speaker.Speak(result.soundMsg, 1);
                                            } catch (e) {
                                            }
                                            Ext.getCmp("resultInfo").addCls("resultError");
                                            Ext.getCmp("resultInfo").setText("结果：" + result.alertMsg);
                                        }
                                    },
                                    failure: function (r) {
                                        myMask.hide();
                                        Ext.getCmp("freightNoId").setDisabled(false)
                                        Ext.getCmp("freightNoId").focus();
                                        Ext.getCmp('freightNoId').setValue("");

                                        Ext.getCmp("resultInfo").addCls("resultError");
                                        Ext.getCmp("resultInfo").setText("结果：保存失败,请重试!");
                                    }
                                });

                            }
                        }
                    }
                },
                {
                    height: 30,
                    xtype: 'label',
                    id: 'resultInfo',
                    text: '结果:无',
                    style: 'font-size:36px;padding:10px 100px;margin-top:10px;margin-bottom:80px;'
                }
            ]
        });
        wareLeaveForm.show();
        Ext.getCmp('freightNoId').focus(false, 100);
    });
</script>
</head>

<body>

</body>
</html>
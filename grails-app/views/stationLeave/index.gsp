<%--
  Created by IntelliJ IDEA.
  User: hww
  Date: 12-5-18
  Time: 下午9:19
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
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
    font-size: 28px;
    margin-left: 20px;
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
            Ext.MessageBox.show({title: '注意:', msg: '初始化语音模块失败!' + e, width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
            g_speaker = null;
        }

        var posterId
        //数据字段
        var dataFields = [
            'id',
            'freightNo',
            'orderType',
//            'posterName',
            'customer',
            'mobileNo',
            'receivable',
//            'payable',
            'companyName',
            'goodsName',
            'address'
        ];

        var columns = [
            {text: "id", width: 98, dataIndex: 'id', hidden: true},
            {text: "订单号", width: 98, dataIndex: 'freightNo', sortable: true},
            {text: "订单类型", width: 70, dataIndex: 'orderType', sortable: true},
            {text: "公司", width: 120, dataIndex: 'companyName', sortable: true},
            {text: "收货人", width: 70, dataIndex: 'customer', sortable: true},
//            {text: "快递员", width: 70, dataIndex: 'posterName', sortable: true},
            {text: "收货地址", flex: 1, dataIndex: 'address', sortable: true} ,
            {text: "应收金额", width: 60, dataIndex: 'receivable', sortable: true},
//            {text: "应退金额", width: 60, dataIndex: 'payable', sortable: true},
            {text: "商品名", width: 180, dataIndex: 'goodsName', sortable: true}
        ]

        var inScanningStore = Ext.create('Ext.data.Store', {
            fields: dataFields,
            idProperty: 'id',
            autoLoad: false
        });

        var stationDatas = [];
        <g:each in="${stations}">
        stationDatas.push([${it.id}, '${it.stationName}']);
        </g:each>

        var inGrid = Ext.create('Ext.grid.Panel', {
            columns: [
                Ext.create('Ext.grid.RowNumberer', {header: 'NO', width: 28}),
                columns
            ],
            store: inScanningStore,
            margin: '2 2',
            autoHeight: true,
            columnLines: true,
            height: document.body.clientHeight - 200,
            buttonAlign: 'center',
            buttons: [
                {
                    text: '清空列表',
                    iconCls: 'deleteIcon',
                    handler: function () {
                        Ext.MessageBox.confirm('操作', "确认清空数据？", function (btn) {
                            if (btn == "yes") {
                                inScanningStore.removeAll();
                            }
                        });
                    }
                },
                {
                    text: '打印配送单',
                    iconCls: 'printerIcon',
                    handler: function () {
                        var count = inScanningStore.count();
//                        if (!posterId ||posterId == undefined || posterId == null || posterId == "") {
//                            Ext.MessageBox.show({title: '提示:', msg: "打印失败！先选择快递员【与列表投递人员一致】。", width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
//                            return;
//                        }
                        if (count != 0) {
                            var ids = '';
                            inScanningStore.each(function (record) {
                                ids += record.get("id") + ',';
                            });
                            ids += '0';
                            window.open('<g:createLink action="print" controller="printDeliveryList"/>?ids=' + ids );
                        } else {
                            Ext.MessageBox.show({title: '提示:', msg: "打印失败！无数据。", width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                        }
                    }
                }
            ],
            title: '已扫描订单',
            listeners: {
                scrollershow: function (scroller) {
                    if (scroller && scroller.scrollEl) {
                        scroller.clearManagedListeners();
                        scroller.mon(scroller.scrollEl, 'scroll', scroller.onElScroll, scroller);
                    }
                }
            }
        })

        var posterStore = Ext.create('Ext.data.Store', {
            proxy: {
                type: 'ajax',
                url: '<g:createLink action="getPosterByStation"/>',
                reader: {
                    type: 'json',
                    root: 'data'
                }
            },
            fields: ['id', 'posterName'],
            remoteSort: true,
            autoLoad: false
        });
        var batchPosterStore = Ext.create('Ext.data.Store', {
            proxy: {
                type: 'ajax',
                url: '<g:createLink action="getPosterByStation"/>',
                reader: {
                    type: 'json',
                    root: 'data'
                }
            },
            fields: ['id', 'posterName'],
            remoteSort: true,
            autoLoad: false
        });
        var singleForm = Ext.create('Ext.form.Panel', {
            id:'singleForm',
            height:80,
            border:0,
            bodyPadding:6,
            autoScroll :true,
            margin: '4 6',
            layout: {
                type: 'table',
                columns: 4
            },
            defaultType: 'textfield',
            items: [
//                {
//                    colspan: 2,
//                    xtype: 'combobox',
//                    fieldLabel: '站名',
//                    name: 'stationId',
//                    hiddenName: 'stationId',
//                    style: "margin-left: 20",
//                    id: 'stationId',
//                    height: 28,
//                    editable: true,
//                    allowBlank: false,
//                    emptyText: '必须选择站点',
//                    fieldStyle: 'font-size:18px;line-height:100%;',
//                    queryMode: 'local',
//                    store: new Ext.data.ArrayStore({
//                        fields: ['id', 'stationName'],
//                        data: stationDatas
//                    }),
//                    valueField: 'id',
//                    displayField: 'stationName',
//                    listeners: {
//                        select: function (combo, record, index) {
//                            var stationId = Ext.getCmp("stationId").value;
//                            if (stationId == undefined || stationId == "" || stationId == null) {
//                                Ext.MessageBox.show({title: "信息", msg: "请先选择站点", buttons: Ext.Msg.OK, icon: Ext.MessageBox.ERROR})
//                                return
//                            }
//                            var posterObj = Ext.getCmp("posterId");
//                            posterObj.clearValue();
//                            posterObj.store.load({params: {stationId: stationId}});
//                        }
//                    }
//                },
//                {
//                    colspan: 2,
//                    xtype: 'combobox',
//                    fieldLabel: '选择快递员',
//                    hiddenName: 'posterId',
//                    name:'posterId',
//                    id: 'posterId',
//                    height: 28,
//                    editable: true,
//                    allowBlank: false,
//                    style: "margin-left: 20",
//                    valueField: 'id',
//                    displayField: 'posterName',
//                    queryMode: 'local',
//                    store: posterStore,
//                    listConfig: {
//                        loadMask: false
//                    },
//                    listeners: {
//                        "focus": function () {
//                            var stationId = Ext.getCmp("stationId").value;
//                            if (stationId == undefined || stationId == "" || stationId == null) {
//                                Ext.MessageBox.show({title: "信息", msg: "请先选择站点", buttons: Ext.Msg.OK, icon: Ext.MessageBox.ERROR})
//                                return
//                            }
//                        }
//                    }
//                },
                {
                    colspan: 2,
                    fieldLabel: '订单号',
                    height: 38,
                    width: 380,
                    id: 'freightNo',
                    name: 'freightNo',
                    style: "margin-left: 20",
                    fieldStyle: 'font-size:26px;line-height:100%;',
                    listeners: {
                        specialkey: function (field, e) {
                            if (e.getKey() == Ext.EventObject.ENTER) {
                                var freightNo = Ext.getCmp('singleForm').form.getValues().freightNo;
//                                 posterId = Ext.getCmp("posterId").value;
//                                var stationId = Ext.getCmp("stationId").value;
                                var tag = true;
//                                if (stationId == undefined || stationId == "" || stationId == null || posterId == undefined || posterId == "" || posterId == null) {
//                                    tag = false;
//                                }

                                if (tag) {
                                    if (freightNo == undefined || freightNo.length < 4) {
                                        Ext.getCmp("resultInfo").addCls("resultError");
                                        Ext.getCmp("resultInfo").setText("结果：请检查订单长度！");
                                        Ext.getCmp('freightNo').setValue("");
                                        return false;
                                    }
                                    var myMask = new Ext.LoadMask(Ext.getBody(), {
                                        msg: '正在保存，请稍后！',
                                        removeMask: true
                                    });
                                    myMask.show();
                                    this.setDisabled(true)

                                    Ext.Ajax.request({
                                        url: '<g:createLink action="save"/>',
                                        params: {freightNo: freightNo},
                                        timeout:120000,
                                        success: function (r) {
                                            myMask.hide();
                                            var result = Ext.JSON.decode(r.responseText);
                                            Ext.getCmp('freightNo').setValue("");
                                            Ext.getCmp("freightNo").setDisabled(false)
                                            Ext.getCmp("freightNo").focus();

                                            if (result.success) {
                                                try {
                                                    g_speaker.Speak("成功", 1);
                                                } catch (e) {
                                                }
                                                Ext.getCmp("resultInfo").removeCls("resultError");
                                                Ext.getCmp("resultInfo").setText("结果：" + result.alertMsg);

                                                var hasFrerihtNo = false
                                                inScanningStore.each(function (record) {
                                                    if (record.get("freightNo") == result.data.freightNo) {
                                                        hasFrerihtNo = true
                                                        inScanningStore.remove(record);
                                                        return;
                                                    }
                                                });
                                                if (!hasFrerihtNo)
                                                    inScanningStore.add(result.data);
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
                                            Ext.getCmp('freightNo').setValue("");
                                            Ext.getCmp("freightNo").setDisabled(false)
                                            Ext.getCmp("freightNo").focus();
                                            Ext.MessageBox.show({title: '提示:', msg: "站点出库失败,请重试!", width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                        }
                                    });
                                } else {
                                    Ext.MessageBox.show({title: '提示:', msg: '请检查站点或快递员不能为空!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                }
                            }
                        }
                    }
                },
                {
                    colspan: 2,
                    xtype: 'label',
                    cls: 'resultError',
                    id: 'resultInfo',
                    html: '请输入运单号开始出库',
                    style: "margin-left:20",
                    style: 'font-size:26px;'
                }
            ]
        });
        var batchForm = Ext.create('Ext.form.Panel', {
            height:150,
            border:0,
            bodyPadding:6,
            autoScroll:true,
            margin:'4 6',
            layout: 'hbox',
            items: [
//                {
//                    xtype: 'fieldcontainer',
//                    width: 240,
//                    layout: 'absolute',
//                    defaults: {
//                        x :10
//                    },
//                    items:[
//                        {
//                            y : 15,
//                            xtype:'combobox',
//                            fieldLabel:'站名',
//                            hiddenName:'batchStationId',
//                            id:'batchStationId',
//                            name:'batchStationId',
//                            labelWidth: 80,
//                            height: 28,
//                            editable:true,
//                            allowBlank:false,
//                            emptyText:'必须选择站点',
//                            fieldStyle:'font-size:18px;line-height:100%;',
//                            queryMode:'local',
//                            valueField:'id',
//                            displayField:'stationName',
//                            store:new Ext.data.ArrayStore({
//                                fields:['id', 'stationName'],
//                                data:stationDatas
//                            }),
//                            listeners: {
//                                select: function (combo, record, index) {
//                                    var stationBatchId = Ext.getCmp("batchStationId").value;
//                                    if (stationBatchId == undefined || stationBatchId == "" || stationBatchId == null) {
//                                        Ext.MessageBox.show({title: "信息", msg: "请先选择站点", buttons: Ext.Msg.OK, icon: Ext.MessageBox.ERROR})
//                                        return
//                                    }
//                                    var posterObj = Ext.getCmp("batchPosterId");
//                                    posterObj.clearValue();
//                                    posterObj.store.load({params: {stationId: stationBatchId}});
//                                }
//                            }
//                        },
//                        {
//                            y : 80,
//                            xtype: 'combobox',
//                            fieldLabel: '选择快递员',
//                            hiddenName: 'batchPosterId',
//                            name:'batchPosterId',
//                            id: 'batchPosterId',
//                            height: 28,
//                            labelWidth: 80,
//                            editable: true,
//                            allowBlank: false,
//                            fieldStyle:'font-size:18px;line-height:100%;',
//                            valueField: 'id',
//                            displayField: 'posterName',
//                            queryMode: 'local',
//                            store: batchPosterStore,
//                            listConfig: {
//                                loadMask: false
//                            },
//                            listeners: {
//                                "focus": function () {
//                                    var stationId = Ext.getCmp("batchStationId").value;
//                                    if (stationId == undefined || stationId == "" || stationId == null) {
//                                        Ext.MessageBox.show({title: "信息", msg: "请先选择站点", buttons: Ext.Msg.OK, icon: Ext.MessageBox.ERROR})
//                                        return
//                                    }
//                                }
//                            }
//                        }
//                    ]
//                },
                {
                    xtype:'textarea',
                    width: 340,
                    labelWidth: 80,
                    height : 130,
                    anchor: '90%',
                    fieldLabel: '批量订单',
                    labelStyle:'weight:800;margin-top:40;font-size:16',
                    id : 'freightNos',
                    name: 'freightNos'
                },
                {
                    xtype: 'fieldcontainer',
                    width: 130,
                    layout: 'absolute',
                    defaults: {
                        x :40
                    },
                    items: [{
                        xtype : 'button',
                        width: '70',
                        y : 40,
                        iconCls:'acceptIcon',
                        text :'出库',
                        listeners:{
                            'click':function(){
                                inScanningStore.removeAll();
//                                var stationId = Ext.getCmp("batchStationId").value;
//                                if (stationId == undefined || stationId == "" || stationId == null) {
//                                    Ext.MessageBox.show({title: "信息", msg: "站点不能为空！", buttons: Ext.Msg.OK, icon: Ext.MessageBox.ERROR})
//                                    return
//                                }
//                                 posterId = Ext.getCmp("batchPosterId").value;
//                                if (posterId == undefined || posterId == "" || posterId == null) {
//                                    Ext.MessageBox.show({title: "信息", msg: "必须选择投递员", buttons: Ext.Msg.OK, icon: Ext.MessageBox.ERROR})
//                                    return
//                                }
                                var freightNos = Ext.getCmp('freightNos').getValue();
                                if(!freightNos){
                                    Ext.getCmp("resultSuccInfos").setValue("结果：无数据不能提交！" );
                                    Ext.getCmp("resultErrorInfo").setValue('');
                                    return;
                                }
                                if(freightNos.split("\r\n").length>1000){
                                    Ext.getCmp("resultSuccInfos").addCls("resultError");
                                    Ext.Msg.alert("信息", "批量订单每次操作不能超过1000条!");
                                    return;
                                }
                                var myMask = new Ext.LoadMask(Ext.getBody(), {
                                    msg:'正在查询，请稍后！',
                                    removeMask:true
                                });
                                myMask.show();
                                Ext.Ajax.request({
                                    url:'<g:createLink action="batchSave"/>',
                                    params:{freightNos:freightNos},
                                    timeout:120000,
                                    success:function (r) {
                                        myMask.hide();
                                        var result = Ext.JSON.decode(r.responseText);
                                        if(result.success) {
                                            Ext.getCmp('freightNos').setValue('')
                                            Ext.getCmp("resultErrorInfo").setValue(result.alertMsg);
                                            Ext.getCmp("resultSuccInfos").setValue("结果：总共【"+ result.totalCount +"】包,成功【"+ result.remarkMsg +"】单!" )
                                            var hasFrerihtNo = false ;
                                            for(i =0 ; i < result.data.length;i++){
                                                inScanningStore.each(function(record){
                                                    if(record.get("freightNo")==result.data[i].freightNo)
                                                    {
                                                        hasFrerihtNo = true
                                                        return;
                                                    }
                                                });
                                                if(!hasFrerihtNo)
                                                    inScanningStore.add(result.data[i]);
                                            }
                                        }else{
                                            Ext.getCmp("resultSuccInfos").setValue("结果：【出库失败】")
                                            Ext.getCmp("resultErrorInfo").setValue(result.alertMsg);
                                        }

                                    },
                                    failure:function (r) {
                                        myMask.hide();
                                        Ext.MessageBox.show({title:'提示:', msg:"请求超时,请重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                    }
                                });
                            }
                        }
                    }]
                },
                {
                    xtype: 'fieldcontainer',
                    layout: 'anchor',
                    flex  : 1,
                    items:[{
                        anchor: '99%',
                        id:'resultSuccInfos',
                        xtype:'displayfield',
                        fieldStyle:'font-size:22px;',
                        value:'结果：'
                    },{
                        anchor: '99%',
                        id:'resultErrorInfo',
                        xtype:'textarea',
                        height: 90,
                        readOnly:true,
                        fieldStyle:'color:red;font-size:18px;line-height:120%;'
                    }]
                }]
        });
        var tabs = Ext.createWidget('tabpanel', {
            activeTab: 0,
            autoHeight:true,
            width:document.body.clientWidth - 30,
            margin:'4 6',
            defaults :{
                bodyPadding: 10,
                closable: false
            },
            items: [
                {
                    title: '单条出库',
                    xtype: 'container',
                    anchor: '100%',
                    autoScroll:true,
                    items: singleForm
                },{
                    title: '批量出库',
                    xtype: 'container',
                    anchor: '100%',
                    autoScroll:true,
                    items: batchForm
                }]
        });
        var panel = Ext.create('Ext.panel.Panel', {
            style: 'margin: 4',
            layout: {
                type: 'column'
            },
            renderTo: Ext.getBody(),
            items: [
                tabs,
                {
                    xtype: 'container',
                    layout: 'column',
                    width: document.body.clientWidth - 30,
                    bodyPadding: 10,
                    margin: '4 6',
                    defaults: {
                        layout: 'anchor',
                        defaults: {
                            anchor: '100%'
                        }
                    },
                    items: [
                        {
                            columnWidth: 1,
                            items: [inGrid]
                        }
                    ]
                }
            ]
        });

        panel.show();

    });
</script>
</head>

<body>
</body>
</html>
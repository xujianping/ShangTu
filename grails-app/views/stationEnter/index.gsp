<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="layout" content="ext"/>
<link rel="stylesheet" href="${resource(dir: 'css', file: 'ext_icon.css')}"/>
<g:javascript src="common.js"></g:javascript>
<g:javascript src="dateTimePicker.js"></g:javascript>
<g:javascript src="dateTimeField.js"></g:javascript>
<g:javascript src="ext-lang-zh_CN.js"></g:javascript>

<style type="text/css">
.resultError {
    color: red;
    font-size: 22px;
}
.resultStyle{
    color: blue;
    font-size: 20px;
    font-weight: 900;
    border: dashed 2px red;
    height:40;
    padding: 6px;
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
        }
        var isOpenWin = false;
        var orderPackageWin;
        var orderPackageWindow = function (titleInfo, formInfo, buttons) {
            if (!isOpenWin) {
                orderPackageWin = Ext.create('widget.window', {
                    title: titleInfo,
                    closable: true,
                    closeAction: 'hide',
                    pageY: 30, // 页面定位Y坐标
                    pageX: document.body.clientWidth / 4.2, // 页面定位X坐标
                    constrain: true,
                    collapsible: true, // 是否可收缩
                    width: document.body.clientWidth * 0.618,
                    height: document.body.clientHeight - 240,
                    layout: 'fit',
                    maximizable: true, // 设置是否可以最大化
                    iconCls: 'imageIcon',
                    bodyStyle: 'padding: 5px;',
                    //animateTarget : Ext.getBody(),
                    border: true,
                    buttonAlign: 'center',
                    items: formInfo,
                    buttons: buttons,
                    listeners: {
                        "show": function () {
                            isOpenWin = true;
                        },
                        "hide": function () {
                            isOpenWin = false;
                        },
                        "close": function () {
                            isOpenWin = false;
                        }
                    }
                });
                orderPackageWin.show();
            }
        }

        //分包数据store
        var orderPackageStore = Ext.create('Ext.data.Store', {
            proxy:{
                type:'ajax',
                url:'<g:createLink  action="orderPackageInfo"/>',
                reader:{
                    type:'json',
                    root:'data'
                }
            },
            fields:['packageNo', 'wareEnterDate', 'wareLeaveDate', 'stationEnterDate', 'stationLeaveDate'
            ],
            autoLoad:false
        });
        //分包表格数据
        var orderPackageGrid = Ext.create('Ext.grid.Panel', {
            store:orderPackageStore,
            columns:[
                {text:"分包号", width:140, dataIndex:'packageNo', sortable:false},
                {text:"库房入库日期", width:130, dataIndex:'wareEnterDate', sortable:false},
                {text:"库房出库日期", width:130, dataIndex:'wareLeaveDate', sortable:false},
                {text:"站点入库日期", width:130, dataIndex:'stationEnterDate', sortable:false},
                {text:"站点出库日期", width:130, dataIndex:'stationLeaveDate', sortable:false}
            ],
            margin:'2 2',
            frame:true,
            columnLines:true,
            listeners: {
                scrollershow: function (scroller) {
                    if (scroller && scroller.scrollEl) {
                        scroller.clearManagedListeners();
                        scroller.mon(scroller.scrollEl, 'scroll', scroller.onElScroll, scroller);
                    }
                }
            }
        });

        //数据字段
        var dataFields = [
            'id',
            'freightNo',
            'customer',
            'mobileNo',
            'company',
            'address'
        ];

        var noScanningStore = Ext.create('Ext.data.Store', {
            proxy:{
                type:'ajax',
                url:'<g:createLink action="getNotScanningOrder"/>',
                actionMethods:{read:'POST'},
                reader:{
                    type:'json',
                    root:'data',
                    totalProperty:'totalCount'
                },
                simpleSortMode:true
            },
            fields:dataFields,
            idProperty:'id',
            autoLoad:false
        });

        var inScanningStore = Ext.create('Ext.data.Store', {
            fields:dataFields,
            idProperty:'id',
            autoLoad:false
        });

        var columns = [
            {text:"订单号", width:95, dataIndex:'freightNo', sortable:true},
            {text:"公司", width:80, dataIndex:'company', sortable:true, renderer:function (value) {
                if (value == null) return value; else return value.companyName;
            }},
            {text:"收件人", width:48, dataIndex:'customer', sortable:true},
            {text:"地址", flex:1, dataIndex:'address', sortable:true}
        ]

        var tbar = Ext.create('Ext.Toolbar', {
            items:[
                {
                    text:'查看待扫数据',
                    iconCls:'page_findIcon',
                    handler:function () {
                        var stationId = Ext.getCmp("stationId").value;
                        var batchNo = Ext.getCmp("batchNo").value;
                        var packNo = Ext.getCmp("packNo").value;
                        var showAbel =  Ext.getCmp("showAbel").value;
                        var tag = true;
                        if (stationId == undefined||stationId == ""||stationId == null||batchNo == undefined||batchNo == ""||batchNo == null||packNo == undefined||packNo == ""||packNo == null) {
                            tag = false;
                        }
                        if (tag) {
                            noScanningStore.load( {params:{stationId:stationId, batchNo:batchNo, packNo:packNo,showAbel:showAbel}});
                        } else {
                            Ext.MessageBox.show({title:'提示:', msg:"请填写完整后再查询！!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                        }
                    }
                },
                {
                    text:'清空数据',
                    iconCls:'wrenchIcon',
                    handler:function () {
                        noScanningStore.removeAll();
                    }
                }
            ]
        });

        var grid = Ext.create('Ext.grid.Panel', {
            columns:[
                Ext.create('Ext.grid.RowNumberer', {header:'NO', width:26}),
                columns
            ],
            tbar:tbar,
            store:noScanningStore,
            height:document.body.clientHeight - 190,
            // bodyPadding: 2,
            margin:'2 2',
            columnLines:true,
            autoHeight:true,
            title:'待扫描订单',
            listeners:{
                'itemdblclick':function (view, record, item, index, e) {
                    var selectedKey = record.get("id");
                    orderPackageStore.load({params:{orderId:selectedKey}});
                    orderPackageWindow('分包详情', orderPackageGrid, "");
                } ,
                scrollershow: function (scroller) {
                    if (scroller && scroller.scrollEl) {
                        scroller.clearManagedListeners();
                        scroller.mon(scroller.scrollEl, 'scroll', scroller.onElScroll, scroller);
                    }
                }
            }
        });

        var intbar = Ext.create('Ext.Toolbar', {
            items:[
                {
                    text:'清空已扫数据',
                    iconCls:'wrenchIcon',
                    handler:function () {
                        inScanningStore.removeAll();
                    }
                }
            ]
        });

        var inGrid = Ext.create('Ext.grid.Panel', {
            columns:[
                Ext.create('Ext.grid.RowNumberer', {header:'NO', width:26}),
                columns
            ],
            tbar:intbar,
            store:inScanningStore,
            margin:'2 2',
            autoHeight:true,
            columnLines:true,
            height:document.body.clientHeight - 190,
            title:'已扫描订单' ,
            listeners: {
                scrollershow: function (scroller) {
                    if (scroller && scroller.scrollEl) {
                        scroller.clearManagedListeners();
                        scroller.mon(scroller.scrollEl, 'scroll', scroller.onElScroll, scroller);
                    }
                }
            }
        })
        var batchNoData = [];
        <g:each in="${bathNos}">
        batchNoData.push(['${it.key}', '${it.value}']);
        </g:each>

        var packStore = Ext.create('Ext.data.Store', {
            proxy:{
                type:'ajax',
                url:'<g:createLink action="getPackNo"/>',
                reader:{
                    type:'json',
                    root:'data'
                }
            },
            fields:['packKey', 'pachValue'],
            autoLoad:false
        });

        var stationDatas = [];
        <g:each in="${stations}">
        stationDatas.push([${it.id}, '${it.stationName}']);
        </g:each>

        var panel = Ext.create('Ext.panel.Panel', {
            height:document.body.clientHeight - 20,
            width:document.body.clientWidth - 10,
            bodyPadding:4,
            style:'margin: 4',
            layout:{
                type:'column'
            },
            renderTo:Ext.getBody(),
            items:[
                {
                    xtype:'form',
                    id:'stationEnterForm',
                    width:document.body.clientWidth - 30,
                    height:160,
                    autoFill:false,
                    autoHeight:true,
                    title:'查询条件',
                    bodyPadding:6,
                    autoScroll :true,
                    margin:'4 6',
                    layout:{
                        type:'table',
                        columns:8
                    },
                    defaultType:'textfield',
                    items:[
                        {
                            colspan:2,
                            xtype:'combobox',
                            fieldLabel:'入站名',
                            hiddenName:'stationId',
                            id:'stationId',
                            height:28,
                            editable:true,
                            allowBlank:false,
                            emptyText:'必须选择站点',
                            fieldStyle:'font-size:18px;line-height:100%;',
                            labelStyle:'width:40px',
                            transform:'stationSelect'
                        },
                        {
                            colspan:2,
                            xtype:'combobox',
                            fieldLabel:'出库批次',
                            height:28,
                            margin:'0 10 0 10',
                            name:'batchNo',
                            id:'batchNo',
                            allowBlank:false,
                            emptyText:'必须选择出库批次',
                            labelStyle:'width:70px',
                            fieldStyle:'font-size:18px;line-height:100%;',
                            editable:true,
                            queryMode:'local',
                            valueField:'beachKey',
                            displayField:'beachValue',
                            store:new Ext.data.ArrayStore({
                                fields:['beachKey', 'beachValue'],
                                data:batchNoData
                            }),
                            listeners: {
                                select: function (combo, record, index) {
                                    var stationId = Ext.getCmp("stationId").value;
                                    var batchNo = Ext.getCmp("batchNo").value;
                                    if (stationId == undefined||stationId == ""||stationId == null) {
                                        Ext.MessageBox.show({title:"信息", msg:"请先选择站点", buttons:Ext.Msg.OK, icon:Ext.MessageBox.ERROR})
                                        return
                                    }
                                    if (batchNo == undefined ||batchNo == "" || batchNo == null) {
                                        Ext.MessageBox.show({title:"信息", msg:"请先选择出库批次", buttons:Ext.Msg.OK, icon:Ext.MessageBox.ERROR})
                                        return
                                    }
                                    var packNoObj = Ext.getCmp("packNo");
                                    packNoObj.clearValue();
                                    packNoObj.store.load({params:{stationId:stationId, batchNo:batchNo}})
                                }
                            }
                        },
                        {
                            colspan:2,
                            fieldLabel:'包裹号',
                            labelStyle:'width:40px',
                            fieldStyle:'line-height:100%;',
                            xtype:'combobox',
                            height:28,
                            id:'packNo',
                            name:'packNo',
                            allowBlank:false,
                            editable:true,
                            queryMode:'local',
                            emptyText:'必须选择包裹号',
                            fieldStyle:'font-size:18px;line-height:100%;',
                            valueField:'packKey',
                            displayField:'pachValue',
                            store:packStore,
                            listConfig: {
                                loadMask: false
                            },
                            listeners:{
                                "focus":function () {
                                    var stationId = Ext.getCmp("stationId").value;
                                    var batchNo = Ext.getCmp("batchNo").value;
                                    if (stationId == undefined||stationId == ""||stationId == null) {
                                        Ext.MessageBox.show({title:"信息", msg:"请先选择站点", buttons:Ext.Msg.OK, icon:Ext.MessageBox.ERROR})
                                        return
                                    }
                                    if (batchNo == undefined ||batchNo == "" || batchNo == null) {
                                        Ext.MessageBox.show({title:"信息", msg:"请先选择出库批次", buttons:Ext.Msg.OK, icon:Ext.MessageBox.ERROR})
                                        return
                                    }
                                    //this.clearValue();
                                    //this.store.load({params:{stationId:stationId, batchNo:batchNo}})
                                }
                            }
                        },
                        {
                            colspan:1,
                            fieldLabel:'是否显示数据',
                            name:'showAbel',
                            id:'showAbel',
                            xtype:'checkbox',
                            inputValue:true,
                            allowBlank:true
                        },
                        {
                            colspan:1,
                            xtype:'button',
                            width:70,
                            iconCls:'acceptIcon',
                            text:'查询',
                            style:"margin-left: 40",
                            handler:function () {
                                var stationId = Ext.getCmp("stationId").value;
                                var batchNo = Ext.getCmp("batchNo").value;
                                var packNo = Ext.getCmp("packNo").value;
                                var showAbel =  Ext.getCmp("showAbel").value;
                                var tag = true;
                                if (stationId == undefined||stationId == ""||stationId == null||batchNo == undefined||batchNo == ""||batchNo == null||packNo == undefined||packNo == ""||packNo == null) {
                                    tag = false;
                                }
                                if (tag) {
                                    if(showAbel) {
                                        noScanningStore.load({callback:function () {
                                            Ext.getCmp("resultInfo").setText("结果：待扫" + noScanningStore.getCount() + '单!');
                                        },
                                            params:{stationId:stationId, batchNo:batchNo, packNo:packNo,showAbel:showAbel}
                                        });
                                    }else{
                                        var myMask = new Ext.LoadMask(Ext.getBody(), {msg:'正在查询，请稍后！', removeMask:true });
                                        myMask.show();
                                        Ext.Ajax.request({
                                            url:'<g:createLink action="getNotScanningOrder"/>',
                                            params:{stationId:stationId, batchNo:batchNo,packNo:packNo},
                                            success:function (r) {
                                                myMask.hide();
                                                var result = Ext.JSON.decode(r.responseText);
                                                if (result.success) {
                                                    totalCount = result.totalCount
                                                    if(totalCount==0){
                                                        Ext.getCmp("resultInfo").addCls("resultError");
                                                        Ext.getCmp("resultInfo").setText("结果：本包已扫完！");
                                                    } else{
                                                        Ext.getCmp("resultInfo").setText("结果：待扫" +totalCount + '单！');
                                                    }
                                                } else {
                                                    Ext.getCmp("resultInfo").addCls("resultError");
                                                    Ext.getCmp("resultInfo").setText("查询错误，请重新查询！");
                                                    return
                                                }
                                            },
                                            failure:function (r) {
                                                myMask.hide();
                                                Ext.getCmp("freightNo").setDisabled(false)
                                                Ext.getCmp("freightNo").focus();
                                                Ext.MessageBox.show({title:'提示:', msg:"请求超时,请重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                            }
                                        })
                                    }


                                } else {
                                    Ext.MessageBox.show({title:'提示:', msg:"请填写完整后再查询！!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                }
                            }
                        },
                        {
                            colspan:3,
                            fieldLabel:'订单号',
                            height:38,
                            width:340,
                            margin:'20 10 0 0',
                            name:'freightNo',
                            id:'freightNo',
                            labelStyle:'width:40px',
                            fieldStyle:'font-size:26px;line-height:100%;',
                            listeners:{
                                specialkey:function (field, e) {
                                    if (e.getKey() == Ext.EventObject.ENTER) {
                                        var freightNo = Ext.getCmp("stationEnterForm").form.getValues().freightNo;
                                        var stationId = Ext.getCmp("stationId").value;
                                        var batchNo = Ext.getCmp("batchNo").value;
                                        var packNo = Ext.getCmp("packNo").value;
                                        var tag = true;
                                        if (stationId == undefined||stationId == ""||stationId == null||batchNo == undefined||batchNo == ""||batchNo == null||packNo == undefined||packNo == ""||packNo == null) {
                                            tag = false;
                                        }

                                        if (tag) {
                                            if(freightNo==undefined ||freightNo.length < 4 ){
                                                Ext.getCmp("resultInfo").addCls("resultError");
                                                Ext.getCmp("resultInfo").setText("结果：请检查订单长度！");
                                                Ext.getCmp('freightNo').setValue("");
                                                return false ;
                                            }
                                            var myMask = new Ext.LoadMask(Ext.getBody(), {msg:'正在保存，请稍后！', removeMask:true });
                                            myMask.show();
                                            Ext.getCmp("freightNo").setDisabled(true)
                                            Ext.Ajax.request({
                                                url:'<g:createLink action="save"/>',
                                                params:{freightNo:freightNo, stationId:stationId, batchNo:batchNo, packNo:packNo},
                                                success:function (r) {
                                                    myMask.hide();
                                                    Ext.getCmp("freightNo").setDisabled(false)
                                                    Ext.getCmp("freightNo").focus();
                                                    var result = Ext.JSON.decode(r.responseText);
                                                    if (result.success) {
                                                        try {
                                                            g_speaker.Speak(result.soundMsg, 1);
                                                        } catch (e) {
                                                        }
                                                        Ext.getCmp("resultInfo").setText("结果：" + result.alertMsg);
                                                        Ext.getCmp('freightNo').setValue("");
                                                        inScanningStore.add(result.data);
                                                        noScanningStore.each(function (record) {
                                                            if (record.get("freightNo") == result.data.freightNo) {
                                                                noScanningStore.remove(record);
                                                            }
                                                        });
                                                    } else {
                                                        try {
                                                            g_speaker.Speak(result.soundMsg, 1);
                                                        } catch (e) {
                                                        }
                                                        Ext.getCmp("resultInfo").addCls("resultError");
                                                        Ext.getCmp("resultInfo").setText("结果：" + result.alertMsg);
                                                        Ext.getCmp('freightNo').setValue("");
                                                        return
                                                    }
                                                },
                                                failure:function (r) {
                                                    myMask.hide();
                                                    try {
                                                        g_speaker.Speak("请求超时", 1);
                                                    } catch (e) {
                                                    }
                                                    Ext.getCmp("freightNo").setDisabled(false);
                                                    Ext.getCmp("freightNo").focus();
                                                    Ext.MessageBox.show({title:'提示:', msg:"请求失败,请重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                                }
                                            });
                                        } else {
                                            try {
                                                g_speaker.Speak("请填写完整后再入库操作!", 1);
                                            } catch (e) {
                                            }
                                            Ext.MessageBox.show({title:'提示:', msg:'请填写完整后再入库操作!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                        }
                                    }
                                }
                            }
                        },
                        {
                            colspan:3,
                            xtype:'label',
                            cls:'resultStyle',
                            id:'resultInfo',
                            html:'先查询待扫描数据后再入库',
                            style:'font-size:24px;'
                        }
                    ]
                },
                {
                    xtype:'container',
                    layout:'column',
                    width:document.body.clientWidth - 30,
                    bodyPadding:10,
                    margin:'4 6',
                    defaults:{
                        layout:'anchor',
                        defaults:{
                            anchor:'100%'
                        }
                    },
                    items:[
                        {
                            columnWidth:.5,
                            items:[grid]
                        },
                        {
                            columnWidth:.5,
                            items:[inGrid]
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
<div id='searchDiv'></div>
<g:select name="stationId" id="stationSelect" from="${stations}" optionKey="id" optionValue="stationName"
          noSelection="['': '']"/>
<div id="tableDiv"></div>
</body>
</html>
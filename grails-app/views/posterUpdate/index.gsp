<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="layout" content="ext"/>
<link rel="stylesheet" href="${resource(dir: 'css', file: 'ext_icon.css')}"/>
<g:javascript src="common.js"></g:javascript>
<g:javascript src="dateTimePicker.js"></g:javascript>
<g:javascript src="dateTimeField.js"></g:javascript>
<g:javascript src="ext-lang-zh_CN.js"></g:javascript>
<style>
.resultError {
    color: red;
    font-size: 28px;
}
</style>

<script type="text/javascript">

    Ext.onReady(function () {
        Ext.tip.QuickTipManager.init();

        //数据字段
        var dataFields = [
            'id',
            'orderType',
            'freightNo',
            'customer',
            'address',
            'companyName',
            'goodsName',
            'posterName'
        ];

        //表格显示及数据绑定
        var columnHeads = [
            Ext.create('Ext.grid.RowNumberer', {header:'NO', width:28}),
            {text:"ID", dataIndex:'id',hidden:true},
            {text:"单号", flex:10, dataIndex:'freightNo', sortable:true},
            {text:"订单类型", flex:5, dataIndex:'orderType', sortable:true},
            {text:"顾客", flex:5, dataIndex:'customer', sortable:true},
            {text:"地址", flex:20, dataIndex:'address', sortable:true},
            {text:"公司", flex:10, dataIndex:'companyName', sortable:true},
            {text:"商品名称", flex:5, dataIndex:'goodsName', sortable:true},
            {text:"原投递员",flex:10 , dataIndex:'posterName', sortable:true}
        ];

        //创建数据源
        var orderStore = Ext.create('Ext.data.Store', {
            proxy:{
                type:'ajax',
                url:'<g:createLink action="list"/>',
                actionMethods:{read:'POST'},
                reader:{
                    type:'json',
                    root: 'data'
                },
                simpleSortMode:true
            },
            fields:dataFields,
            idProperty:'id',
            autoLoad:false
        });

        var uploadWin;
        //表格数据
        var grid = Ext.create('Ext.ListView', {
            region: 'center',
            title: '已扫描订单',
            margin: '0 0 2 0',
            autoFill:false,
            height:document.body.clientHeight-22,
            width:document.body.clientWidth-10,
            store:orderStore,
            columns:columnHeads,
            columnLines:true,
            multiSelect:true,
            buttonAlign:'center',
            buttons:[{
                xtype: 'button',
                iconCls: 'acceptIcon',
                text    : '修改',
                listeners: {
                    'click':function(){
                        var count = orderStore.count();
                        if(count<1){
                            Ext.MessageBox.show({title:'提示:', msg:"无数据不能提交!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                        }else if(count> 1000){
                            Ext.MessageBox.show({title:'提示:', msg:"一次提交不能超过1000条!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                        }else{
                            if (!posterForm.form.getValues().poster) {
                                Ext.MessageBox.show({title:'提示:', msg:'请选择投递员!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                return;
                            }
                            Ext.MessageBox.confirm('操作', "有【"+count+"】条记录将修改投递员，确认请交？", function(btn){
                                if(btn=="yes"){
                                    var ps = posterForm.form.getValues();
                                    var ids = new Array()
                                    orderStore.each(function(record){
                                        ids.push(record.get("id"))
                                    });
                                    ps.ids = ids.join(',');
                                    var myMask = new Ext.LoadMask(Ext.getBody(), {
                                        msg:'正在保存，请稍后！',
                                        removeMask:true
                                    });
                                    myMask.show();

                                    Ext.Ajax.request({
                                        url:'<g:createLink action="confirm"/>',
                                        params:ps,
                                        success:function (r) {
                                            myMask.hide();
                                            var result = Ext.JSON.decode(r.responseText);
                                            if (result.success) {
                                                Ext.MessageBox.show({title:'提示:', msg:result.alertMsg, width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                                orderStore.removeAll();
                                                singleForm.form.reset();
                                                batchForm.form.reset();
                                            }else {
                                                Ext.MessageBox.show({title:'提示:', msg:result.alertMsg, width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                            }
                                        },
                                        failure:function (r) {
                                            myMask.hide();
                                            Ext.MessageBox.show({title:'提示:', msg:"请求失败，请重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                        }
                                    });
                                }
                            });
                        }
                    }
                }
            },{
                text:'删除',
                iconCls:'edit1Icon',
                handler:function () {
                    var selection = grid.selModel.getSelection();
                    if (selection == undefined || selection == null || selection == "") {
                        Ext.MessageBox.show({title:'提示:', msg:'必须选择一条记录!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                    }else{
                        orderStore.remove(selection)
                    }
                }
            },{
                text:'清空列表',
                iconCls:'deleteIcon',
                handler:function () {
                    Ext.MessageBox.confirm('操作', "确认清空数据？", function(btn){
                        if(btn=="yes"){
                            orderStore.removeAll();
                        }
                    });
                }
            }],
            listeners: {
                scrollershow: function (scroller) {
                    if (scroller && scroller.scrollEl) {
                        scroller.clearManagedListeners();
                        scroller.mon(scroller.scrollEl, 'scroll', scroller.onElScroll, scroller);
                    }
                }
            }
        });

        var singleForm = Ext.create('Ext.form.Panel', {
            bodyPadding: '18 0 0 0',
            height: 130,
            layout: {
                type: 'hbox'
            },
            defaultType: 'textfield',
            items: [{
                fieldLabel: '单号',
                id: 'freightNo',
                name: 'freightNo',
                enableKeyEvents: true,
                height: 62,
                width: 550,
                labelSeparator:'',
                labelAlign: 'right',
                labelWidth: 120,
                labelStyle: 'font-size:48px;line-height:120%;padding-right:3px;',
                fieldStyle: 'font-size:48px;line-height:120%;',
                listeners:{
                    'keydown':function(text,e,opts){
                        if(e.getKey()==Ext.EventObject.ENTER){
                            var freightNo = Ext.getCmp('freightNo').getValue();
                            if (freightNo.length <= 4) {
                                Ext.MessageBox.show({title:'提示:', msg:'请检查运单长度!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                singleForm.down('textfield').setValue("");
                                return;
                            }
                            var myMask = new Ext.LoadMask(Ext.getBody(), {
                                msg:'正在查询，请稍后！',
                                removeMask:true
                            });
                            myMask.show();
                            Ext.Ajax.request({
                                url:'<g:createLink action="scanningOrder"/>',
                                params:{freightNo:freightNo},
                                success:function (r) {
                                    singleForm.down('textfield').setValue("");
                                    myMask.hide();
                                    var result = Ext.JSON.decode(r.responseText);
                                    if (result.success) {
                                        Ext.getCmp("resultInfo").removeCls("resultError");
                                        Ext.getCmp("resultInfo").setText("结果：" + result.alertMsg);
                                        var hasFrerihtNo = false
                                        orderStore.each(function (record) {
                                            if (record.get("freightNo") ==  result.data.freightNo) {
                                                hasFrerihtNo = true
                                                return;
                                            }
                                        });
                                        if (!hasFrerihtNo)
                                            orderStore.add(result.data);
                                    } else {
                                        Ext.getCmp("resultInfo").addCls("resultError");
                                        Ext.getCmp("resultInfo").setText("结果：" + result.alertMsg);
                                    }
                                },
                                failure:function (r) {
                                    singleForm.down('textfield').setValue("");
                                    myMask.hide();
                                    Ext.MessageBox.show({title:'提示:', msg:"输入失败,请重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                }
                            });
                        }
                    }
                }
            },{
                xtype:'label',
                cls:'resultError',
                id:'resultInfo',
                html:'',
                style:"margin-left:30;font-size:22px;"
            }]
        });

        var batchForm = Ext.create('Ext.form.Panel', {
            bodyPadding: '14 2 2 30',
            height: 130,
            layout: 'hbox',
            items: [{
                xtype:'textarea',
                labelWidth: 80,
                height : 98,
                width: 320,
                fieldStyle: 'font-size:22px;line-height:120%;',
                fieldLabel: '批量订单',
                id : 'freightNos',
                name: 'freightNos'
            },{
                xtype: 'fieldcontainer',
                width: 166,
                layout: 'absolute',
                defaults: {
                    x :40
                },
                items: [{
                    xtype : 'button',
                    width: '70',
                    y : 40,
                    iconCls:'acceptIcon',
                    text :'查询',
                    listeners:{
                        'click':function(){
                            var freightNos = Ext.getCmp('freightNos').getValue();
                            if(!freightNos){
                                Ext.getCmp("resultSuccInfos").setValue("结果：" );
                                Ext.getCmp("resultErrorInfo").setValue('');
                                return;
                            }
                            if(freightNos.split("\r\n").length>1000){
                                Ext.Msg.alert("信息", "批量订单每次操作不能超过1000条!");
                                return;
                            }
                            var myMask = new Ext.LoadMask(Ext.getBody(), {
                                msg:'正在保存，请稍后！',
                                removeMask:true
                            });
                            myMask.show();
                            Ext.Ajax.request({
                                url:'<g:createLink action="scanningBathOrder"/>',
                                params:{freightNos:freightNos},
                                success:function (r) {
                                    myMask.hide();
                                    var result = Ext.JSON.decode(r.responseText);
                                    var failureInfos=''
                                    var m=0;
                                    for(var i=0;i<result.length;i++){
                                        if (result[i].success) {
                                            m++;
                                            var hasFrerihtNo = false
                                            orderStore.each(function(record){
                                                if(record.get("freightNo")==result[i].data.freightNo)
                                                {
                                                    hasFrerihtNo = true
                                                    return;
                                                }
                                            });
                                            if(!hasFrerihtNo)
                                                orderStore.add(result[i].data);
                                        } else {
                                            failureInfos += result[i].alertMsg + "\r\n"
                                        }
                                    }
                                    if(m==result.length){
                                        Ext.getCmp("resultSuccInfos").setValue("结果：本批扫描成功！" );
                                        Ext.getCmp("resultErrorInfo").setValue('');
                                    }else{
                                        Ext.getCmp("resultErrorInfo").setValue(failureInfos);
                                        Ext.getCmp("resultSuccInfos").setValue("结果：本批扫描【"+ m +"】单成功!【"+ eval(freightNos.split("\r\n").length-m) +"】单失败!" )
                                    }
                                },
                                failure:function (r) {
                                    myMask.hide();
                                    Ext.MessageBox.show({title:'提示:', msg:"批量扫描失败,请重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                }
                            });
                        }
                    }
                }]
            },{
                xtype: 'fieldcontainer',
                layout: 'anchor',
                flex  : 1,
                items:[{
                    anchor: '90%',
                    id:'resultSuccInfos',
                    xtype:'displayfield',
                    fieldStyle:'font-size:22px;',
                    value:'结果：'
                },{
                    anchor: '90%',
                    id:'resultErrorInfo',
                    xtype:'textarea',
                    height: 62,
                    readOnly:true,
                    fieldStyle:'color:red;font-size:22px;line-height:120%;'
                }]
            }]
        });

        var tabs = Ext.createWidget('tabpanel', {
            activeTab: 0,
           autoHeight:true,
            margin: '0 0 4 0',
            defaults :{
                bodyPadding: 10,
                closable: false
            },
            items: [
            {
                title: '输入订单',
                xtype: 'container',
                anchor: '100%',
                items: singleForm
            },{
                title: '批量导入',
                xtype: 'container',
                anchor: '100%',
                items: batchForm
            }]
        });

        var posterForm = Ext.create('Ext.form.Panel', {
            title: '选择投递员',
            margin: '0 0 4 0',
            bodyPadding: '22 0 0 0',
            height: 90,
            defaultType: 'textfield',
            layout: {
                type: 'hbox'
            },
            defaults:{
                labelSeparator:'',
                labelAlign: 'right'
            },
            items: [{
                xtype     : 'combobox',
                name: 'poster',
                id:'poster',
                editable:false,
                queryMode:'local',
                store:new Ext.data.ArrayStore({
                    fields:['value', 'text'],
                    data: Ext.JSON.decode('${params.posters}')
                }),
                valueField:'value',
                displayField:'text',
                fieldLabel: '投递员'
            }]
        });

        Ext.create('Ext.container.Viewport', {
            layout: 'border',
            padding: 5,
            style:'background-color:transparent',
            renderTo: Ext.getBody(),
            items: [{
                xtype:'container',
                region:'north',
                items:[tabs,posterForm]
            }, grid]
        }).show();
    });
</script>

</head>

<body>
</body>
</html>

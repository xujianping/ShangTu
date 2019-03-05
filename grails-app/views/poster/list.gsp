<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="layout" content="ext"/>
<link rel="stylesheet" href="${resource(dir: 'css', file: 'ext_icon.css')}"/>
<g:javascript src="common.js"></g:javascript>
<g:javascript src="dateTimePicker.js"></g:javascript>
<g:javascript src="dateTimeField.js"></g:javascript>
<g:javascript src="ext-lang-zh_CN.js"></g:javascript>

<script type="text/javascript">
    Ext.onReady(function () {
        Ext.tip.QuickTipManager.init();
        var stationData = [];
        <g:each in="${stations}">
        stationData.push([${it.id}, '${it.stationName}']);
        </g:each>
        //查询form
        var posterSeachForm = new Ext.FormPanel({
            //collapsible : true,// 是否可以展开
            labelWidth:120,
            frame:true,
            bodyStyle:'padding:5px 80px 0',
            waitMsgTarget:true,
            //reader : _jsonFormReader,
            defaults:{
                width:document.body.clientWidth / 2.5 - 120
            },
            defaultType:'textfield',

            items:[

                {
                    fieldLabel:'配送员名',
                    name:'posterName',
                    allowBlank:true
                },
                {
                    fieldLabel:'POS登录ID',
                    name:'posLoginNo',
                    allowBlank:true
                }
            ]
        });


        //新增,修改form
        var posterForm = new Ext.FormPanel({
            //collapsible : true,// 是否可以展开
            labelWidth:120, // label settings here cascade unless overridden
            frame:true,
            bodyStyle:'padding:5px 80px 0',
            waitMsgTarget:true,
            //reader : _jsonFormReader,
            defaults:{
                width:document.body.clientWidth / 2.5 - 120
            },
            defaultType:'textfield',
            items:[
                {
                    fieldLabel:'id',
                    name:'id',
                    hidden:true,
                    hideLabel:true,
                    allowBlank:true
                },
                {
                    fieldLabel:'配送员名',
                    name:'posterName',
                    id:'posterName',
                    allowBlank:false
                },
                {
                    fieldLabel:'pos密码',
                    name:'posPwd',
                    id:'posPwd',
                    minLength:4
                }
                ,
                {
                    fieldLabel:'手机号',
                    name:'mobileNo',
                    allowBlank:true,
                    vtype:'cellphone',
                    minLength:7
                } ,
                {
                    xtype:'combobox',
                    fieldLabel:'卸包点',
                    name:'station.id',
                    id:'station',
                    allowBlank:false,
                    editable:false,
                    queryMode:'local',
                    store:new Ext.data.ArrayStore({
                        fields:['id', 'stationName'],
                        data:stationData
                    }),
                    valueField:'id',
                    displayField:'stationName'
                },
                {
                    fieldLabel:'是否有效',
                    name:'enabled',
                    xtype:'checkbox',
                    inputValue:true,
                    allowBlank:true
                }

            ]
        });

        var isOpenWin = false;
        var posterWin;

        //查询窗口
        var posterWindow = function (titleInfo, formInfo, buttons) {
            if (!isOpenWin) {
                posterWin = Ext.create('widget.window', {
                    title:titleInfo,
                    closable:true,
                    closeAction:'hide',
                    pageY:30, // 页面定位Y坐标
                    pageX:document.body.clientWidth / 4.2, // 页面定位X坐标
                    constrain:true,
                    collapsible:true, // 是否可收缩
                    width:document.body.clientWidth / 2,
                    height:document.body.clientHeight - 70,
                    layout:'fit',
                    maximizable:true, // 设置是否可以最大化
                    iconCls:'imageIcon',
                    bodyStyle:'padding: 5px;',
                    //animateTarget : Ext.getBody(),
                    border:true,
                    buttonAlign:'center',
                    items:formInfo,
                    buttons:buttons,
                    listeners:{
                        "show":function () {
                            isOpenWin = true;
                        },
                        "hide":function () {
                            isOpenWin = false;
                        },
                        "close":function () {
                            isOpenWin = false;
                        }
                    }
                });
                posterWin.show();
            }
        }

        //数据字段
        var dataFields = [
            'id',
            'enabled',
            'posterName',
            'mobileNo',
            'posLoginNo',
            'posPwd',
            'station'
        ];

        //表格显示及数据绑定
        var columnHeads = [
            {text:"POS登录ID", width:160, dataIndex:'posLoginNo', sortable:true},
            {text:"配送员名", width:160, dataIndex:'posterName', sortable:true},
            {text:"手机号", width:180, dataIndex:'mobileNo', sortable:true},
            {text:"是否有效", width:150, dataIndex:'enabled', sortable:true, renderer:setYesOrNo},
            {text:"所属站点", width:200, dataIndex:'station', sortable:true}
        ];


        var tbar = Ext.create('Ext.Toolbar', {
            items:[
                {
                    text:'查询',
                    iconCls:'page_findIcon',
                    handler:function () {
                        var buttons =
                                [
                                    {
                                        text:'查询',
                                        iconCls:'page_findIcon',
                                        disabled:false,
                                        handler:function () {
                                            if (posterSeachForm.form.isValid()) {
                                                Ext.MessageBox.wait("正在查询数据,稍后......");
                                                bbar.moveFirst();
                                                //posterStore.load({params:posterSeachForm.form.getValues()});
                                                Ext.MessageBox.hide();
                                                posterWin.hide();
                                            }
                                            else {
                                                Ext.Msg.alert("信息", "请填写完成再提交!");
                                            }
                                        }
                                    },
                                    {
                                        text:'清空',
                                        iconCls:'wrenchIcon',
                                        handler:function () {
                                            posterSeachForm.form.reset();//清空表单
                                        }
                                    }
                                ];
                        posterWindow('查询poster', posterSeachForm, buttons);
                    }
                },
                {
                    text:'新增',
                    iconCls:'page_addIcon',
                    handler:function () {
                        var buttons =
                                [
                                    {
                                        text:'保存',
                                        iconCls:'acceptIcon',
                                        disabled:false,
                                        handler:function () {
                                            if (posterForm.form.isValid()) {
                                                var posterName = Ext.getCmp('posterName').getValue();
                                                if(posterName.length >5){
                                                    alert("投递员名称不能超过5位");
                                                    return ;
                                                }

                                                Ext.MessageBox.wait("正在保存数据,稍后......");
                                                posterForm.form.submit({
                                                    url:'<g:createLink action="save"/>',
                                                    success:function (form, action) {
                                                        Ext.MessageBox.hide();
                                                        Ext.MessageBox.show({title:'提示:', msg:'新增信息成功!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                                        posterForm.form.reset();//清空表单
                                                        posterSeachForm.form.reset();
                                                        posterWin.hide();
                                                        posterStore.load({params:posterSeachForm.form.getValues()});
                                                    },
                                                    failure:function (form, action) {
                                                        Ext.MessageBox.hide();
                                                        if (!action.hasOwnProperty("result"))
                                                            Ext.MessageBox.show({title:'提示:', msg:'新增信息失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                                        else
                                                            Ext.MessageBox.show({title:'提示:', msg:action.result.alertMsg, width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                                    }
                                                });
                                            }
                                            else {
                                                Ext.MessageBox.show({title:'提示:', msg:'请填写完成再提交!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                            }
                                        }
                                    },
                                    {
                                        text:'清空',
                                        iconCls:'wrenchIcon',
                                        handler:function () {
                                            posterForm.form.reset();//清空表单
                                        }
                                    }
                                ];
                        posterForm.form.reset();//清空表单
                        posterWindow('新增poster', posterForm, buttons);
                    }
                },
                {
                    text:'修改',
                    iconCls:'page_edit_1Icon',
                    handler:function () {
                        var buttons =
                                [
                                    {
                                        text:'保存',
                                        iconCls:'acceptIcon',
                                        disabled:false,
                                        handler:function () {
                                            if (posterForm.form.isValid()) {
                                                var posterName = Ext.getCmp('posterName').getValue();
                                                if(posterName.length >5){
                                                    alert("投递员名称不能超过5位");
                                                    return ;
                                                }
                                                Ext.MessageBox.wait("正在保存数据,稍后......");
                                                posterForm.form.submit({
                                                    url:'<g:createLink action="save"/>',
                                                    success:function (form, action) {
                                                        Ext.MessageBox.hide();
                                                        Ext.MessageBox.show({title:'提示:', msg:'修改信息成功!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                                        posterForm.form.reset();//清空表单
                                                        posterSeachForm.form.reset();
                                                        posterWin.hide();
                                                        posterStore.load({params:posterSeachForm.form.getValues()});
                                                    },
                                                    failure:function (form, action) {
                                                        Ext.MessageBox.hide();
                                                        if (!action.hasOwnProperty("result"))
                                                            Ext.MessageBox.show({title:'提示:', msg:'修改信息失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                                        else
                                                            Ext.MessageBox.show({title:'提示:', msg:action.result.alertMsg, width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                                    }
                                                });
                                            }
                                            else {
                                                Ext.Msg.alert('信息', '请填写完成再提交!');
                                            }
                                        }
                                    },
                                    {
                                        text:'清空',
                                        iconCls:'wrenchIcon',
                                        handler:function () {
                                            posterForm.form.reset();//清空表单
                                        }
                                    }
                                ];

                        posterForm.form.reset();//清空表单
                        posterWindow('修改poster', posterForm, buttons);
                        loadData('<g:createLink action="show"/>');
                    }
                },
                {
                    text:'删除',
                    iconCls:'page_delIcon',
                    handler:function () {
                        var selection = posterGrid.selModel.getSelection();

                        if (selection == undefined || selection == null || selection == "") {
                            //Ext.MessageBox.alert('提示','请选择一条记录!');
                            Ext.MessageBox.show({
                                title:'提示:',
                                msg:'必须选择一条记录!',
                                width:300,
                                buttons:Ext.MessageBox.OK,
                                icon:Ext.MessageBox.ERROR
                            });
                            return;
                        }

                        Ext.MessageBox.confirm("删除:", "确定删除该条数据?", function (e) {
                            if (e == "yes") {
                                var selectedKey = selection[0].get("id");
                                Ext.Ajax.request({
                                    url:'<g:createLink action="delete"/>',
                                    params:{ id:selectedKey},
                                    success:function (r) {
                                        var result = Ext.JSON.decode(r.responseText);
                                        if (result.success) {
                                            Ext.MessageBox.show({title:'提示:', msg:'删除信息成功!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                        } else {
                                            Ext.MessageBox.show({title:'提示:', msg:result.alertMsg, width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                        }
                                        posterStore.load({params:posterSeachForm.form.getValues()});
                                    },
                                    failure:function (r) {
                                        var result = Ext.JSON.decode(r.responseText);
                                        Ext.MessageBox.show({title:'提示:', msg:"删除失败,请重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                        posterStore.load({params:posterSeachForm.form.getValues()});
                                    }
                                });
                            }
                        });
                    }
                }
            ]
        });

        //创建数据源
        var posterStore = Ext.create('Ext.data.Store', {
            pageSize:10,
            proxy:{
                type:'ajax',
                url:'<g:createLink action="list"/>',
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
            autoLoad:true
        });


        //每页显示条数下拉选择框
        var pagesize_combo = new Ext.form.ComboBox({
            name:'pagesize',
            triggerAction:'all',
            mode:'local',
            store:new Ext.data.ArrayStore({
                fields:['value', 'text'],
                data:[
                    ['10', '10'],
                    ['15', '15'],
                    ['20', '20'],
                    ['25', '25'],
                    ['50', '50'],
                    ['100', '100'],
                    ['250', '250'],
                    ['500', '500']
                ]
            }),
            valueField:'value',
            displayField:'text',
            value:'10',
            editable:false,
            width:45,
            listeners:{
                select:function (combo, record, eOpts) {
                    posterStore.pageSize = parseInt(combo.getValue());
                    bbar.updateInfo();
                    bbar.moveFirst();
                    posterStore.load();
                }
            }
        });

        var bbar = Ext.create('Ext.PagingToolbar', {
            store:posterStore,
            displayInfo:true,
            displayMsg:'当前显示 {0} - {1} 条  , 共 {2} 条',
            emptyMsg:"没有符合条件的记录",
            items:["&nbsp;每页", pagesize_combo, '条']
        });

        //表格数据
        var posterGrid = Ext.create('Ext.grid.Panel', {
            autoFill:false,
            height:document.body.clientHeight - 22,
            width:document.body.clientWidth - 10,
            store:posterStore,
            tbar:tbar,
            columns:[Ext.create('Ext.grid.RowNumberer', {header:'NO', width:32}), columnHeads],
            margin:'5 5',
            title:'配送员列表',
            renderTo:Ext.getBody(),
            columnLines:true,
            bbar:bbar,
            listeners: {
                scrollershow: function (scroller) {
                    if (scroller && scroller.scrollEl) {
                        scroller.clearManagedListeners();
                        scroller.mon(scroller.scrollEl, 'scroll', scroller.onElScroll, scroller);
                    }
                }
            }
        });


        //下页提交提交查询条件
        posterStore.on('beforeload', function (store, options) {
            Ext.apply(store.proxy.extraParams, posterSeachForm.form.getValues());
        });


        //表格双击事件（查看单条数据明细）
        posterGrid.addListener('itemdblclick', function () {
            posterWindow('详细poster', posterForm, "");
            loadData('<g:createLink action="show"/>');
        }, this);

        function loadData(url) {
            var selection = posterGrid.selModel.getSelection();

            if (selection == undefined || selection == null || selection == "") {
                Ext.MessageBox.show({title:'提示:', msg:'必须选择一条记录!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                posterWin.hide();
                return;
            }
            var selectedKey = selection[0].get("id");//returns array of selected rows ids only

            if (selectedKey != undefined && selectedKey != null && selectedKey != "") {
                posterForm.form.load({
                    waitMsg:'正在加载数据请稍后......', //提示信息
                    waitTitle:'提示', //标题
                    url:url,
                    params:{id:selectedKey},
                    method:'POST', //请求方式
                    success:function (form, action) {
                        Ext.getCmp('posPwd').setValue("");
                        if (action.result.data.station) {
                            Ext.getCmp('station').setValue(action.result.data.station.id);
                        }
                    },
                    failure:function (form, action) {//加载失败的处理函数
                        Ext.MessageBox.show({title:'提示:', msg:'数据加载失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                        posterWin.hide();
                    }
                });
            } else {
                Ext.MessageBox.show({title:'提示:', msg:'数据加载失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                posterWin.hide();
            }
        }

    });
</script>

</head>

<body>
<div id='posterDiv'></div>

</body>
</html>
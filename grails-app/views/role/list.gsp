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
        var columnsData = [];
        <g:each in="${detailsType}" >
        columnsData.push(['${it.key}', '${it.value}']);
        </g:each>
        var promptsData = [];
        <g:each in="${ejectPrompts}" >
        promptsData.push(['${it.key}', '${it.value}']);
        </g:each>
        var authStore = Ext.create('Ext.data.TreeStore', {
            proxy:{
                type:'ajax',
                url:'<g:createLink action="actions"/>'
            },
            sorters:[
                {
                    property:'id'
                },
                {
                    property:'text'
                }
            ]
        });

        var tree = Ext.create('Ext.tree.Panel', {
            store:authStore,
            rootVisible:false,
            name:'actions',
            useArrows:true,
            frame:true,
            height:document.body.clientHeight - 250,
            title:'权限'
        });

        //新增,修改form
        var roleForm = new Ext.FormPanel({
            //collapsible : true,// 是否可以展开
            labelWidth:120, // label settings here cascade unless overridden
            frame:true,
            bodyStyle:'padding:5px 10px 0px 20px',
            waitMsgTarget:true,
            //reader : _jsonFormReader,
            defaults:{
                width:document.body.clientWidth / 2 -80
            },
            autoScroll:true,
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
                    fieldLabel:'角色名',
                    name:'name',
                    allowBlank:false,
                    minLength:2
                },
                {
                    fieldLabel:'角色代码(ROLE_)',
                    name:'authority',
                    allowBlank:false,
                    minLength:5
                },
                {
                    xtype:'combobox',
                    name:'columns',
                    id:'columns',
                    editable:false,
                    multiSelect:true,
                    queryMode:'local',
                    store:new Ext.data.ArrayStore({
                        fields:['id', 'text'],
                        data:columnsData
                    }),
                    valueField:'id',
                    displayField:'text',
                    fieldLabel:'导出列设置'
                },
                {
                    xtype:'combobox',
                    name:'prompts',
                    id:'prompts',
                    editable:false,
                    multiSelect:true,
                    queryMode:'local',
                    store:new Ext.data.ArrayStore({
                        fields:['id', 'text'],
                        data:promptsData
                    }),
                    valueField:'id',
                    displayField:'text',
                    fieldLabel:'弹出提示'
                },
                tree

            ]
        });

        var isOpenWin = false;
        var roleWin;

        //查询窗口
        var roleWindow = function (titleInfo, formInfo, buttons) {
            if (!isOpenWin) {
                roleWin = Ext.create('widget.window', {
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
                roleWin.show();
            }
        }

        //数据字段
        var dataFields = [
            'id',
            'authority',
            'name',
            'columns',
            'prompts'
        ];

        //表格显示及数据绑定
        var columnHeads = [
            {text:"角色名", width:140, dataIndex:'name', sortable:true},
            {text:"角色代码", width:180, dataIndex:'authority', sortable:true} ,
            {text:"导出列设置", flex:0.5, dataIndex:'columns', sortable:false, renderer:function (ids) {
                if (!ids) return '';
                var ret = [];
                var val = ids.split(',');
                for (var i = 0; i < val.length; i++) {
                    for (var j = 0; j < columnsData.length; j++) {
                        if (columnsData[j][0] == val[i]) {
                            ret.push(columnsData[j][1])
                        }
                    }
                }
                return ret.join(",");
            }},
            {text:"弹出提示设置", flex:0.5, dataIndex:'prompts', sortable:false, renderer:function (ids) {
                if (!ids) return '';
                var ret = [];
                var val = ids.split(',');
                for (var i = 0; i < val.length; i++) {
                    for (var j = 0; j < promptsData.length; j++) {
                        if (promptsData[j][0] == val[i]) {
                            ret.push(promptsData[j][1])
                        }
                    }
                }
                return ret.join(",");
            }}
        ];


        var tbar = Ext.create('Ext.Toolbar', {
            items:[
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
                                            if (roleForm.form.isValid()) {
                                                Ext.MessageBox.wait("正在保存数据,稍后......");
                                                var actions = [];
                                                var selections = tree.getChecked();
                                                for (var i = 0; i < selections.length; i++) {
                                                    actions.push(selections[i].get("id"))
                                                }
                                                roleForm.form.submit({
                                                    url:'<g:createLink action="save"/>',
                                                    params:{
                                                        actions:actions
                                                    },
                                                    success:function (form, action) {
                                                        Ext.MessageBox.hide();
                                                        Ext.MessageBox.show({title:'提示:', msg:'新增信息成功!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                                        roleForm.form.reset();//清空表单
                                                        roleWin.hide();
                                                        roleStore.load();
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
                                            roleForm.form.reset();//清空表单
                                        }
                                    }
                                ];
                        roleForm.form.reset();//清空表单
                        roleWindow('新增role', roleForm, buttons);
                        authStore.load({params:{role:'-1'}});
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
                                            if (roleForm.form.isValid()) {
                                                Ext.MessageBox.wait("正在保存数据,稍后......");
                                                var actions = [];
                                                var selections = tree.getChecked();
                                                for (var i = 0; i < selections.length; i++) {
                                                    actions.push(selections[i].get("id"))
                                                }
                                                roleForm.form.submit({
                                                    url:'<g:createLink action="save"/>',
                                                    params:{
                                                        actions:actions
                                                    },
                                                    success:function (form, action) {
                                                        Ext.MessageBox.hide();
                                                        Ext.MessageBox.show({title:'提示:', msg:'修改信息成功!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                                        roleForm.form.reset();//清空表单
                                                        roleWin.hide();
                                                        roleStore.load();
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
                                            roleForm.form.reset();//清空表单
                                        }
                                    }
                                ];

                        roleForm.form.reset();//清空表单
                        roleWindow('修改role', roleForm, buttons);
                        loadData('<g:createLink action="show"/>');
                    }
                },
                {
                    text:'删除',
                    iconCls:'page_delIcon',
                    handler:function () {
                        var selection = roleGrid.selModel.getSelection();

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
                                        roleStore.load();
                                    },
                                    failure:function (r) {
                                        var result = Ext.JSON.decode(r.responseText);
                                        Ext.MessageBox.show({title:'提示:', msg:"删除失败,请重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                        roleStore.load();
                                    }
                                });
                            }
                        });
                    }
                }
            ]
        });

        //创建数据源
        var roleStore = Ext.create('Ext.data.Store', {
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
                    roleStore.pageSize = parseInt(combo.getValue());
                    bbar.updateInfo();
                    bbar.moveFirst();
                    roleStore.load();
                }
            }
        });

        var bbar = Ext.create('Ext.PagingToolbar', {
            store:roleStore,
            displayInfo:true,
            displayMsg:'当前显示 {0} - {1} 条  , 共 {2} 条',
            emptyMsg:"没有符合条件的记录",
            items:["&nbsp;每页", pagesize_combo, '条']
        });

        //表格数据
        var roleGrid = Ext.create('Ext.grid.Panel', {
            autoFill:false,
            height:document.body.clientHeight-22,
            width:document.body.clientWidth-10,
            store:roleStore,
            tbar:tbar,
            columns:[Ext.create('Ext.grid.RowNumberer', {header:'NO', width:32}), columnHeads],
            margin:'4 4',
            title:'角色列表',
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
        roleStore.on('beforeload', function (store, options) {
            Ext.apply(store.proxy.extraParams);
        });


        //表格双击事件（查看单条数据明细）
        roleGrid.addListener('itemdblclick', function () {
            roleWindow('详细role', roleForm, "");
            loadData('<g:createLink action="show"/>');
        }, this);

        function loadData(url) {
            var selection = roleGrid.selModel.getSelection();

            if (selection == undefined || selection == null || selection == "") {
                Ext.MessageBox.show({title:'提示:', msg:'必须选择一条记录!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                roleWin.hide();
                return;
            }
            var selectedKey = selection[0].get("id");//returns array of selected rows ids only

            if (selectedKey != undefined && selectedKey != null && selectedKey != "") {
                authStore.load({params:{role:selection[0].get("authority")}});
                roleForm.form.load({
                    waitMsg:'正在加载数据请稍后......', //提示信息
                    waitTitle:'提示', //标题
                    url:url,
                    params:{id:selectedKey},
                    method:'POST', //请求方式
                    failure:function (form, action) {//加载失败的处理函数
                        Ext.MessageBox.show({title:'提示:', msg:'数据加载失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                        roleWin.hide();
                    }, success:function (form, action) {
                        Ext.getCmp('columns').clearValue();
                        if (action.result.data.columns) {
                            Ext.getCmp('columns').setValue(action.result.data.columns.split(','));
                        }
                        Ext.getCmp('prompts').clearValue();
                        if (action.result.data.prompts) {
                            Ext.getCmp('prompts').setValue(action.result.data.prompts.split(','));
                        }
                    }
                });
            } else {
                Ext.MessageBox.show({title:'提示:', msg:'数据加载失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                roleWin.hide();
            }
        }

    });
</script>

</head>

<body>
<div id='roleDiv'></div>

</body>
</html>
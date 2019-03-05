
<%@ page import="com.xujp.dj.Company" %>
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

            //查询form
            var companySeachForm = new Ext.FormPanel({
                //collapsible : true,// 是否可以展开
                labelWidth:120,
                frame:true,
                bodyStyle:'padding:5px 80px 0',
                waitMsgTarget:true,
                //reader : _jsonFormReader,
                defaults:{
                    width:document.body.clientWidth / 2.5 - 150
                },
                defaultType:'textfield',

                items:[
                    
                    {
                        fieldLabel:'公司名称',
                        name:'companyName',
                        allowBlank:true
                    }
                    ,

                    {
                        fieldLabel:'公司简称',
                        name:'cutName',
                        allowBlank:true
                    }
                    ,

                    {
                        fieldLabel:'公司代码',
                        name:'companyCode',
                        allowBlank:true
                    }
                    
                ]
            });


            //新增,修改form
            var companyForm = new Ext.FormPanel({
                //collapsible : true,// 是否可以展开
                labelWidth:120, // label settings here cascade unless overridden
                frame:true,
                bodyStyle:'padding:5px 80px 0',
                waitMsgTarget:true,
                //reader : _jsonFormReader,
                defaults:{
                    width:document.body.clientWidth / 2.5 - 150
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
                        fieldLabel:'公司名称',
                        name:'companyName',
                        allowBlank:false
                    }
                    ,

                    {
                        fieldLabel:'公司简称',
                        name:'cutName',
                        allowBlank:true
                    }
                    ,

                    {
                        fieldLabel:'公司代码',
                        name:'companyCode',
                        allowBlank:true
                    }
                    
                ]
            });

            var isOpenWin = false;
            var companyWin;

            //查询窗口
            var companyWindow = function (titleInfo, formInfo, buttons) {
                if (!isOpenWin) {
                    companyWin = Ext.create('widget.window', {
                        title:titleInfo,
                        closable:true,
                        closeAction:'hide',
                        pageY:30, // 页面定位Y坐标
                        pageX:document.body.clientWidth /4.2, // 页面定位X坐标
                        constrain:true,
                        collapsible:true, // 是否可收缩
                        width:document.body.clientWidth / 2,
                        height:document.body.clientHeight - 270,
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
                    companyWin.show();
                }
            }

            //数据字段
            var dataFields = [
                'id',
'companyName',
'cutName',
'companyCode'
            ];

            //表格显示及数据绑定
            var columnHeads = [
                 {text:"id", width:120, dataIndex:'id', sortable:true,hidden:true}
                ,
 {text:"公司名称", width:120, dataIndex:'companyName', sortable:true}
                ,
 {text:"公司简称", width:120, dataIndex:'cutName', sortable:true}
                ,
 {text:"公司代码", width:120, dataIndex:'companyCode', sortable:true}
                
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
                                                if (companySeachForm.form.isValid()) {
                                                    Ext.MessageBox.wait("正在查询数据,稍后......");
                                                    bbar.moveFirst();
                                                    companyStore.load(companySeachForm.form.getValues());
                                                    Ext.MessageBox.hide();
                                                    companyWin.hide();
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
                                                companySeachForm.form.reset();//清空表单
                                            }
                                        }
                                    ];
                            companyWindow('查询公司', companySeachForm, buttons);
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
                                                if (companyForm.form.isValid()) {
                                                    Ext.MessageBox.wait("正在保存数据,稍后......");
                                                    companyForm.form.submit({
                                                        url:'<g:createLink action="save"/>',
                                                        success:function (form, action) {
                                                            Ext.MessageBox.hide();
                                                            Ext.MessageBox.show({title:'提示:', msg:'新增信息成功!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                                            companyForm.form.reset();//清空表单
                                                            companySeachForm.form.reset();
                                                            companyWin.hide();
                                                            companyStore.load(companySeachForm.form.getValues());
                                                        },
                                                        failure:function (form, action) {
                                                            Ext.MessageBox.hide();
                                                            if(!action.hasOwnProperty("result"))
                                                                Ext.MessageBox.show({title:'提示:', msg:'新增信息失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                                            else
                                                                Ext.MessageBox.show({title:'提示:', msg:action.result.alertMsg , width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
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
                                                companyForm.form.reset();//清空表单
                                            }
                                        }
                                    ];
                            companyForm.form.reset();//清空表单
                            companyWindow('新增公司', companyForm, buttons);
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
                                                if (companyForm.form.isValid()) {
                                                    Ext.MessageBox.wait("正在保存数据,稍后......");
                                                    companyForm.form.submit({
                                                        url:'<g:createLink action="save"/>',
                                                        success:function (form, action) {
                                                            Ext.MessageBox.hide();
                                                            Ext.MessageBox.show({title:'提示:', msg:'修改信息成功!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                                            companyForm.form.reset();//清空表单
                                                            companySeachForm.form.reset();
                                                            companyWin.hide();
                                                            companyStore.load(companySeachForm.form.getValues());
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
                                                else {
                                                    Ext.Msg.alert('信息', '请填写完成再提交!');
                                                }
                                            }
                                        },
                                        {
                                            text:'清空',
                                            iconCls:'wrenchIcon',
                                            handler:function () {
                                                companyForm.form.reset();//清空表单
                                            }
                                        }
                                    ];

                            companyForm.form.reset();//清空表单
                            companyWindow('修改公司', companyForm, buttons);
                            loadData('<g:createLink action="show"/>');
                        }
                    },
                    {
                        text:'删除',
                        iconCls:'page_delIcon',
                        handler:function () {
                            var selection = companyGrid.selModel.getSelection();

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
                                            Ext.MessageBox.show({title:'提示:', msg:'删除信息成功!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                            companyStore.load(companySeachForm.form.getValues());
                                        },
                                        failure:function (r) {
                                            var result = Ext.JSON.decode(r.responseText);
                                            if(!result.hasOwnProperty("alertMsg"))
                                                Ext.MessageBox.show({title:'提示:', msg:"删除失败,请重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                            else
                                                Ext.MessageBox.show({title:'提示:', msg:result.alertMsg, width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                            companyStore.load(companySeachForm.form.getValues());
                                        }
                                    });
                                }
                            });
                        }
                    }
                ]
            });

            //创建数据源
            var companyStore = Ext.create('Ext.data.Store', {
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
                        companyStore.pageSize = parseInt(combo.getValue());
                        bbar.updateInfo();
                        bbar.moveFirst();
                        companyStore.load();
                    }
                }
            });

            var bbar = Ext.create('Ext.PagingToolbar', {
                store:companyStore,
                displayInfo:true,
                displayMsg:'当前显示 {0} - {1} 条  , 共 {2} 条',
                emptyMsg:"没有符合条件的记录",
                items:["&nbsp;每页", pagesize_combo, '条']
            });

            //表格数据
            var companyGrid = Ext.create('Ext.grid.Panel', {
                autoFill:false,
                autoHeight:true,
                heigth:500,
                store:companyStore,
                tbar:tbar,
                columns:[Ext.create('Ext.grid.RowNumberer', {header:'NO', width:34}), columnHeads],
                margin:'4 4',
                title:'公司管理',
                renderTo:Ext.getBody(),
                columnLines:true,
                bbar:bbar
            });


            //下页提交提交查询条件
            companyStore.on('beforeload', function (store, options) {
                Ext.apply(store.proxy.extraParams, companySeachForm.form.getValues());
            });


            //表格双击事件（查看单条数据明细）
            companyGrid.addListener('itemdblclick', function () {
                companyWindow('详细公司', companyForm, "");
                loadData('<g:createLink action="show"/>');
            }, this);

            function loadData(url) {
                var selection = companyGrid.selModel.getSelection();

                if (selection == undefined || selection == null || selection == "") {
                    Ext.MessageBox.show({title:'提示:', msg:'必须选择一条记录!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                    companyWin.hide();
                    return;
                }
                var selectedKey = selection[0].get("id");//returns array of selected rows ids only

                if (selectedKey != undefined && selectedKey != null && selectedKey != "") {
                    companyForm.form.load({
                        waitMsg:'正在加载数据请稍后......', //提示信息
                        waitTitle:'提示', //标题
                        url:url,
                        params:{id:selectedKey},
                        method:'POST', //请求方式
                        failure:function (form, action) {//加载失败的处理函数
                            Ext.MessageBox.show({title:'提示:', msg:'数据加载失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                            companyWin.hide();
                        }
                    });
                } else {
                    Ext.MessageBox.show({title:'提示:', msg:'数据加载失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                    companyWin.hide();
                }
            }

        });
    </script>

</head>

<body>
<div id='companyDiv'></div>

</body>
</html>
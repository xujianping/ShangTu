<%@ page import="com.xujp.dj.Company" %>
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
        //查询form
        var userSeachForm = new Ext.FormPanel({
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
                    fieldLabel:'登录名',
                    name:'username',
                    allowBlank:true
                }
                ,
                {
                    fieldLabel:'真名',
                    name:'realname',
                    allowBlank:true
                }

            ]
        });

        var comboBoxTree = Ext.create("Ext.ux.ComboBoxTree", {
            id:'station.id',
            name:'station.id',
            hiddenName:'station.id',
            storeUrl:'<g:createLink action="station" controller="common" params="[stationId:'',selectType:'NOTSELECT']" />',
            //anchor: '40%',
            fieldLabel:'选择站点',
            editable:false,
            rootId:'0',
            rootText:'物流部',
            selectClick:true
        });
        comboBoxTree.createPicker();

        Ext.define("roleModel", {
            extend:"Ext.data.Model",
            fields:[
                {name:"id", type:"int"},
                {name:"name", type:"string"}
            ]
        });

        var roleStore = Ext.create("Ext.data.Store", {
            model:"roleModel",
            proxy:{
                url:'<g:createLink action="roles" controller="common"/>',
                type:"ajax"
            },
            autoLoad:true
        });

        var roleComboBox = Ext.create("Ext.form.field.ComboBox", {
            name:'roles',
            fieldLabel:'角色',
            store:roleStore,
            valueField:"id",
            displayField:"name",
            editable:false,
            multiSelect:true,
            triggerAction:'all'
        });

        var companyData = [];
        <g:each in="${Company.list([sort: 'companyName'])}">
        companyData.push([${it.id}+':${it.companyName}', '${it.companyName}']);
        </g:each>

        //新增,修改form
        var userForm = new Ext.FormPanel({
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
                    fieldLabel:'登录名',
                    name:'username',
                    allowBlank:false,
                    minLength:4
                }
                ,
                {
                    fieldLabel:'登录密码',
                    name:'password',
                    allowBlank:false,
                    minLength:4
                }
                ,
                {
                    fieldLabel:'真实姓名',
                    name:'realname',
                    allowBlank:false,
                    minLength:2
                },
                comboBoxTree,
                roleComboBox,
                {
                    xtype:'combobox',
                    name:'phoneColumns',
                    id:'phoneColumns',
                    editable:false,
                    multiSelect:true,
                    queryMode:'local',
                    store:new Ext.data.ArrayStore({
                        fields:['id', 'companyName'],
                        data:companyData
                    }),
                    valueField:'id',
                    displayField:'companyName',
                    fieldLabel:'电话导出设置'
                },
                /*
                 {
                 fieldLabel:'所属站点',
                 name:'station',
                 allowBlank:true
                 } */
                {
                    fieldLabel:'是否库管',
                    name:'manager',
                    xtype:'checkbox',
                    allowBlank:true,
                    inputValue:'true'
                },
                {
                    fieldLabel:'是否有效',
                    xtype:'checkbox',
                    name:'enabled',
                    allowBlank:true,
                    inputValue:'true'
                }
            ]
        });

        var isOpenWin = false;
        var userWin;

        //查询窗口
        var userWindow = function (titleInfo, formInfo, buttons) {
            if (!isOpenWin) {
                userWin = Ext.create('widget.window', {
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
                            //comboBoxTree.createPicker();
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
                userWin.show();
            }
        }

        //数据字段
        var dataFields = [
            'id',
            'username',
            'password',
            'station',
            'manager',
            'accountExpired',
            'accountLocked',
            'enabled',
            'passwordExpired',
            'realname',
            'roles',
            'phoneColumns'
        ];

        //表格显示及数据绑定
        var columnHeads = [
            {text:"登录名", width:150, dataIndex:'username', sortable:true},
            {text:"真名", width:150, dataIndex:'realname', sortable:true},
            {text:"所属站点", width:150, dataIndex:'station', sortable:true, renderer:function (value) {
                if (value == null) return value; else return value.name;
            }},
            {text:"是否库管", width:150, dataIndex:'manager', sortable:true, renderer:setYesOrNo},
            {text:"是否有效", width:150, dataIndex:'enabled', sortable:true, renderer:setEnabled},
            {text:"角色", width:200, dataIndex:'roles', sortable:false, renderer:function (val) {
                var ret = [];
                for (var i = 0; i < val.length; i++) {
                    ret.push(val[i].name);
                }
                return ret.join(",");
            }},
            {text:"电话导出设置", width:200, dataIndex:'phoneColumns', sortable:false, renderer:function (ids) {
                if (!ids) return '';
                var ret = [];
                var val = ids.split(',');
                for (var i = 0; i < val.length; i++) {
                    ret.push(val[i].substring(val[i].indexOf(':') + 1))
                }
                return ret.join(",");
            }}
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
                                            if (userSeachForm.form.isValid()) {
                                                Ext.MessageBox.wait("正在查询数据,稍后......");
                                                bbar.moveFirst();
                                                //userStore.load({params:userSeachForm.form.getValues()});
                                                Ext.MessageBox.hide();
                                                userWin.hide();
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
                                            userSeachForm.form.reset();//清空表单
                                        }
                                    }
                                ];
                        userWindow('查询user', userSeachForm, buttons);
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
                                            if (userForm.form.isValid()) {
                                                Ext.MessageBox.wait("正在保存数据,稍后......");
                                                userForm.form.submit({
                                                    url:'<g:createLink action="save"/>',
                                                    success:function (form, action) {
                                                        Ext.MessageBox.hide();
                                                        Ext.MessageBox.show({title:'提示:', msg:'新增信息成功!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                                        userForm.form.reset();//清空表单
                                                        userSeachForm.form.reset();
                                                        userWin.hide();
                                                        userStore.load({params:userSeachForm.form.getValues()});
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
                                            userForm.form.reset();//清空表单
                                        }
                                    }
                                ];
                        var pwd = userForm.getForm().findField('password');
                        pwd.allowBlank = false;
                        userForm.form.reset();//清空表单
                        userWindow('新增user', userForm, buttons);
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
                                            if (userForm.form.isValid()) {
                                                Ext.MessageBox.wait("正在保存数据,稍后......");
                                                userForm.form.submit({
                                                    url:'<g:createLink action="save"/>',
                                                    success:function (form, action) {
                                                        Ext.MessageBox.hide();
                                                        Ext.MessageBox.show({title:'提示:', msg:'修改信息成功!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                                        userForm.form.reset();//清空表单
                                                        userSeachForm.form.reset();
                                                        userWin.hide();
                                                        userStore.load({params:userSeachForm.form.getValues()});
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
                                            userForm.form.reset();//清空表单
                                        }
                                    }
                                ];
                        userForm.form.reset();//清空表单
                        userWindow('修改user', userForm, buttons);
                        loadData('<g:createLink action="show"/>', 'edit');
                    }
                },
                {
                    text:'删除',
                    iconCls:'page_delIcon',
                    handler:function () {
                        var selection = userGrid.selModel.getSelection();

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
                                        userStore.load({params:userSeachForm.form.getValues()});
                                    },
                                    failure:function (r) {
                                        var result = Ext.JSON.decode(r.responseText);
                                        Ext.MessageBox.show({title:'提示:', msg:"删除失败,请重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                        userStore.load({params:userSeachForm.form.getValues()});
                                    }
                                });
                            }
                        });
                    }
                }
            ]
        });

        //创建数据源
        var userStore = Ext.create('Ext.data.Store', {
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
                    userStore.pageSize = parseInt(combo.getValue());
                    bbar.updateInfo();
                    bbar.moveFirst();
                    userStore.load();
                }
            }
        });

        var bbar = Ext.create('Ext.PagingToolbar', {
            store:userStore,
            displayInfo:true,
            displayMsg:'当前显示 {0} - {1} 条  , 共 {2} 条',
            emptyMsg:"没有符合条件的记录",
            items:["&nbsp;每页", pagesize_combo, '条']
        });

        //表格数据
        var userGrid = Ext.create('Ext.grid.Panel', {
            height:document.body.clientHeight - 22,
            width:document.body.clientWidth - 10,
            store:userStore,
            tbar:tbar,
            columns:[Ext.create('Ext.grid.RowNumberer', {header:'NO', width:32}), columnHeads],
            margin:'5 5',
            title:'用户列表',
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
        userStore.on('beforeload', function (store, options) {
            Ext.apply(store.proxy.extraParams, userSeachForm.form.getValues());
        });


        //表格双击事件（查看单条数据明细）
        userGrid.addListener('itemdblclick', function () {
            userWindow('详细user', userForm, "");
            loadData('<g:createLink action="show"/>', 'show');
        }, this);

        function loadData(url, type) {
            var selection = userGrid.selModel.getSelection();

            if (selection == undefined || selection == null || selection == "") {
                Ext.MessageBox.show({title:'提示:', msg:'必须选择一条记录!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                userWin.hide();
                return;
            }
            var selectedKey = selection[0].get("id");//returns array of selected rows ids only

            if (selectedKey != undefined && selectedKey != null && selectedKey != "") {

                userForm.form.load({
                    waitMsg:'正在加载数据请稍后......', //提示信息
                    waitTitle:'提示', //标题
                    url:url,
                    params:{id:selectedKey},
                    method:'POST', //请求方式
                    failure:function (form, action) {//加载失败的处理函数
                        Ext.MessageBox.show({title:'提示:', msg:'数据加载失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                        userWin.hide();
                    }, success:function (form, action) {
                        if (action.result.data && action.result.data.station) {
                            comboBoxTree.setRawValue(action.result.data.station.stationName);
                            comboBoxTree.setValue(action.result.data.station.id);
                        }
                        if (type == 'edit' || type == 'show') {
                            var pwd = userForm.getForm().findField('password');
                            pwd.allowBlank = true;
                            pwd.setValue('');

                            if (action.result.roles && action.result.roles.length > 0) {
                                var idRst = [];
                                var nameRst = [];
                                for (var i = 0; i < action.result.roles.length; i++) {
                                    idRst.push(action.result.roles[i].id)
                                    nameRst.push(action.result.roles[i].name)
                                }
                                roleComboBox.setRawValue(nameRst);
                                roleComboBox.setValue(idRst);
                            }
                            Ext.getCmp('phoneColumns').clearValue();
                            if (action.result.data.phoneColumns) {
                                Ext.getCmp('phoneColumns').setValue(action.result.data.phoneColumns.split(','));
                            }
                        }
                    }
                });

            } else {
                Ext.MessageBox.show({title:'提示:', msg:'数据加载失败!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                userWin.hide();
            }
        }

    });
</script>

</head>

<body>
</body>
</html>
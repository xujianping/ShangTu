<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="layout" content="ext"/>
<link rel="stylesheet" href="${resource(dir: 'css', file: 'ext_icon.css')}"/>
<g:javascript src="common.js"></g:javascript>
<g:javascript src="ext-lang-zh_CN.js"></g:javascript>

<script type="text/javascript">

    Ext.onReady(function () {
        Ext.tip.QuickTipManager.init();

        var groupForm = Ext.create('Ext.form.Panel', {
            labelWidth: 120,
            frame: true,
            bodyStyle: 'padding:5px 80px 0',
            waitMsgTarget: true,
            defaults: {
                width: document.body.clientWidth / 2.5 - 120
            },
            defaultType: 'textfield',
            items: [
                {
                    name: 'id',
                    hidden: true,
                    allowBlank: true
                },
                {
                    fieldLabel: '分组名称',
                    name: 'groupName',
                    allowBlank: false
                }
            ]
        });

        var isOpenGroupWin = false;
        var groupWin;
        var groupWindow = function (titleInfo, formInfo, buttons) {
            if (!isOpenGroupWin) {
                groupWin = Ext.create('widget.window', {
                    title: titleInfo,
                    closable: true,
                    closeAction: 'hide',
                    pageY: 30, // 页面定位Y坐标
                    pageX: document.body.clientWidth / 4.2, // 页面定位X坐标
                    constrain: true,
                    collapsible: true, // 是否可收缩
                    width: document.body.clientWidth / 2,
                    height: document.body.clientHeight - 400,
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
                            isOpenGroupWin = true;
                        },
                        "hide": function () {
                            isOpenGroupWin = false;
                        },
                        "close": function () {
                            isOpenGroupWin = false;
                        }
                    }
                });
                groupWin.show();
            }
        }

        var groupSelect = Ext.create('Ext.form.field.ComboBox', {
            xtype: 'combobox',
            width: 150,
            name: 'groupSelect',
            editable: false,
            queryMode: 'local',
            store: new Ext.data.ArrayStore({
                fields: ['id', 'groupName'],
                autoLoad: false
            }),
            valueField: 'id',
            displayField: 'groupName',
            listeners: {
                'select': function (combo, records, eOpts) {
                    reloadParam();
                }
            }
        });

        function reloadSelect(sel, reload) {
            groupSelect.clearValue();
            Ext.Ajax.request({
                url: '<g:createLink action="listGroups"/>',
                success: function (r) {
                    var result = Ext.JSON.decode(r.responseText);
                    if (result.success) {
                        groupSelect.store.loadData(result.data);
                        if (sel) {
                            groupSelect.select(sel);
                            if (reload) reloadParam();
                        }
                    }
                }
            });
        }

        reloadSelect();

        var groupPanel = Ext.create('Ext.panel.Panel', {
            title: '参数分组',
            region: 'north',
            margin: '0 0 5 0',
            height: 80,
            layout: 'hbox',
            defaults: {
                margin: '8 0 0 5'
            },
            items: [groupSelect, {
                xtype: 'button',
                text: '新增',
                width: 70,
                iconCls: 'page_addIcon',
                handler: function () {
                    groupForm.form.reset();
                    groupWindow('新增分组', groupForm, [
                        {
                            text: '保存',
                            iconCls: 'acceptIcon',
                            handler: function () {
                                if (groupForm.form.isValid()) {
                                    Ext.MessageBox.wait("正在保存数据,稍后......");
                                    groupForm.form.submit({
                                        url: '<g:createLink action="groupSave"/>',
                                        success: function (form, action) {
                                            Ext.MessageBox.hide();
                                            Ext.MessageBox.show({title: '提示:', msg: '新增信息成功!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.INFO});
                                            reloadSelect(action.result.id, true);
                                            groupForm.form.reset();
                                            groupWin.hide();
                                        },
                                        failure: function (form, action) {
                                            Ext.MessageBox.hide();
                                            if (!action.hasOwnProperty("result"))
                                                Ext.MessageBox.show({title: '提示:', msg: '新增信息失败!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                            else
                                                Ext.MessageBox.show({title: '提示:', msg: action.result.alertMsg, width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                        }
                                    });
                                } else {
                                    Ext.MessageBox.show({title: '提示:', msg: '请填写完成再提交!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                }
                            }
                        },
                        {
                            text: '清空',
                            iconCls: 'wrenchIcon',
                            handler: function () {
                                groupForm.form.reset();//清空表单
                            }
                        }
                    ]);
                }
            }, {
                xtype: 'button',
                text: '修改',
                width: 70,
                iconCls: 'page_edit_1Icon',
                handler: function () {
                    if (!groupSelect.getValue()) {
                        Ext.MessageBox.show({title: '提示:', msg: '必须选择一条记录!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                        return;
                    }
                    groupWindow('修改分组', groupForm, [
                        {
                            text: '保存',
                            iconCls: 'acceptIcon',
                            handler: function () {
                                if (groupForm.form.isValid()) {
                                    Ext.MessageBox.wait("正在保存数据,稍后......");
                                    groupForm.form.submit({
                                        url: '<g:createLink action="groupSave"/>',
                                        success: function (form, action) {
                                            Ext.MessageBox.hide();
                                            Ext.MessageBox.show({title: '提示:', msg: '修改信息成功!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.INFO});
                                            reloadSelect(form.findField('id').getValue());
                                            form.reset();
                                            groupWin.hide();
                                        },
                                        failure: function (form, action) {
                                            Ext.MessageBox.hide();
                                            if (!action.hasOwnProperty("result"))
                                                Ext.MessageBox.show({title: '提示:', msg: '修改信息失败!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                            else
                                                Ext.MessageBox.show({title: '提示:', msg: action.result.alertMsg, width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                        }
                                    });
                                } else {
                                    Ext.MessageBox.show({title: '提示:', msg: '请填写完成再提交!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                }
                            }
                        },
                        {
                            text: '清空',
                            iconCls: 'wrenchIcon',
                            handler: function () {
                                groupForm.form.reset();//清空表单
                            }
                        }
                    ]);
                    groupForm.form.load({
                        waitMsg: '正在加载数据请稍后......', //提示信息
                        waitTitle: '提示', //标题
                        url: '<g:createLink action="groupShow"/>',
                        params: {id: groupSelect.getValue()},
                        method: 'POST', //请求方式
                        failure: function (form, action) {//加载失败的处理函数
                            Ext.MessageBox.show({title: '提示:', msg: '数据加载失败!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                            groupWin.hide();
                        }
                    });
                }
            }, {
                xtype: 'button',
                text: '删除',
                width: 70,
                iconCls: 'page_delIcon',
                handler: function () {
                    var selId = groupSelect.getValue();
                    if (!selId) {
                        Ext.MessageBox.show({title: '提示:', msg: '必须选择一条记录!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                        return;
                    }

                    Ext.MessageBox.confirm("删除:", "分组下的参数也会删除，确定删除该条数据?", function (e) {
                        if (e == "yes") {
                            Ext.Ajax.request({
                                url: '<g:createLink action="groupDelete"/>',
                                params: { id: selId},
                                success: function (r) {
                                    var result = Ext.JSON.decode(r.responseText);
                                    if (result.success) {
                                        Ext.MessageBox.show({title: '提示:', msg: '删除信息成功!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.INFO});
                                        reloadSelect();
                                        paramStore.loadData([]);
                                    } else {
                                        Ext.MessageBox.show({title: '提示:', msg: result.alertMsg, width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                    }
                                },
                                failure: function (r) {
                                    Ext.MessageBox.show({title: '提示:', msg: "删除失败,请重试!", width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                }
                            });
                        }
                    });
                }
            }]
        });

        //数据字段
        var dataFields = [
            'id',
            'paramCode',
            "paramValue",
            'paramDesc'
        ];

        //表格显示及数据绑定
        var columnHeads = [
            {text: "参数名称", width: 150, dataIndex: 'paramCode', sortable: true},
            {text: "参数值", width: 280, dataIndex: 'paramValue', sortable: true, renderer: function (value) {
                if (value.split("@")[1] == "c73a37c8-ef7f-40e4-b9de-8b2f8103844") {
                    return value.split("@")[0];
                } else {
                    return value;
                }
            }},
            {text: "参数说明", flex: 1, dataIndex: 'paramDesc', sortable: true}
        ];

        var paramForm = Ext.create('Ext.form.Panel', {
            labelWidth: 120,
            frame: true,
            bodyStyle: 'padding:5px 80px 0',
            waitMsgTarget: true,
            defaults: {
                width: document.body.clientWidth / 2.5 - 120
            },
            defaultType: 'textfield',
            items: [
                {
                    name: 'id',
                    hidden: true,
                    allowBlank: true
                },
                {
                    fieldLabel: '参数名称',
                    name: 'paramCode',
                    allowBlank: false
                },
                {
                    fieldLabel: '参数值',
                    name: 'paramValue',
                    allowBlank: false
                },
                {
                    fieldLabel: '参数描述',
                    name: 'paramDesc',
                    allowBlank: true
                }
            ]
        });
        var paramWin;
        var isOpenParamWin = false;

        function paramWindow(titleInfo, formInfo, buttons) {
            if (!isOpenGroupWin) {
                paramWin = Ext.create('widget.window', {
                    title: titleInfo,
                    closable: true,
                    closeAction: 'hide',
                    pageY: 30, // 页面定位Y坐标
                    pageX: document.body.clientWidth / 4.2, // 页面定位X坐标
                    constrain: true,
                    collapsible: true, // 是否可收缩
                    width: document.body.clientWidth / 2,
                    height: document.body.clientHeight - 270,
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
                            isOpenParamWin = true;
                        },
                        "hide": function () {
                            isOpenParamWin = false;
                        },
                        "close": function () {
                            isOpenParamWin = false;
                        }
                    }
                });
                paramWin.show();
            }
        }


        var paramFormUser = Ext.create('Ext.form.Panel', {
            labelWidth: 120,
            frame: true,
            bodyStyle: 'padding:5px 80px 0',
            waitMsgTarget: true,
            defaults: {
                width: document.body.clientWidth / 2.5 - 120
            },
            defaultType: 'textfield',
            items: [
                {
                    name: 'id',
                    hidden: true,
                    allowBlank: true
                },
                {
                    fieldLabel: '参数名称',
                    xtype: 'combobox',
                    name: 'paramCode',
                    id: 'authorization_param',
                    allowBlank: false,
                    queryMode: 'local', //本地数据
                    editable: false,
                    store: Ext.create("Ext.data.Store", {
                        fields: ["id", "name"],
                        data: [
                            { "id": "userName", "name": "用户名" },
                            { "id": "passWord", "name": "密码" }
                        ]
                    }),
                    valueField: 'id',
                    displayField: 'name'
                },
                {
                    fieldLabel: '参数值',
                    name: 'paramValue',
                    id: 'authorization_value',
                    allowBlank: false
                },
                {
                    fieldLabel: '参数描述',
                    name: 'paramDesc',
                    allowBlank: true
                }
            ]
        });
        var paramWinUser;
        var isOpenParamWinUser = false;

        function paramWindowUser(titleInfo, formInfo, buttons) {
            if (!isOpenParamWinUser) {
                paramWinUser = Ext.create('widget.window', {
                    title: titleInfo,
                    closable: true,
                    closeAction: 'hide',
                    pageY: 30, // 页面定位Y坐标
                    pageX: document.body.clientWidth / 4.2, // 页面定位X坐标
                    constrain: true,
                    collapsible: true, // 是否可收缩
                    width: document.body.clientWidth / 2,
                    height: document.body.clientHeight - 70,
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
                            isOpenParamWinUser = true;
                        },
                        "hide": function () {
                            isOpenParamWinUser = false;
                        },
                        "close": function () {
                            isOpenParamWinUser = false;
                        }
                    }
                });
                paramWinUser.show();
            }
        }

        var tbar = Ext.create('Ext.Toolbar', {
            items: [
                {
                    text: '新增',
                    iconCls: 'page_addIcon',
                    handler: function () {
                        if (!groupSelect.getValue()) {
                            Ext.MessageBox.show({title: '提示:', msg: '必须选择一条分组记录!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                            return;
                        }
                        var groupSelectParames = new Array();
                        groupSelectParames = groupSelect.getRawValue().split("@");
                        if (groupSelectParames.length == 2 && groupSelectParames[1] == "登录账户信息") {
                            paramFormUser.form.reset();
                            paramWindowUser('新增参数', paramFormUser, [
                                {
                                    text: '保存',
                                    iconCls: 'acceptIcon',
                                    handler: function () {
                                        var gId = groupSelect.getValue();
                                        if (paramFormUser.form.isValid()) {
                                            Ext.MessageBox.wait("正在保存数据,稍后......");
                                            paramFormUser.form.submit({
                                                url: '<g:createLink action="paramSave"/>',
                                                params: {gId: gId},
                                                success: function (form, action) {
                                                    Ext.MessageBox.hide();
                                                    Ext.MessageBox.show({title: '提示:', msg: '新增信息成功!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.INFO});
                                                    paramFormUser.form.reset();
                                                    paramWinUser.hide();
                                                    reloadParam();
                                                },
                                                failure: function (form, action) {
                                                    Ext.MessageBox.hide();
                                                    if (!action.hasOwnProperty("result"))
                                                        Ext.MessageBox.show({title: '提示:', msg: '新增信息失败!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                                    else
                                                        Ext.MessageBox.show({title: '提示:', msg: action.result.alertMsg, width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                                }
                                            });
                                        } else {
                                            Ext.MessageBox.show({title: '提示:', msg: '请填写完成再提交!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                        }
                                    }
                                },
                                {
                                    text: '清空',
                                    iconCls: 'wrenchIcon',
                                    handler: function () {
                                        paramFormUser.form.reset();//清空表单
                                    }
                                }
                            ]);
                        } else {
                            paramForm.form.reset();
                            paramWindow('新增参数', paramForm, [
                                {
                                    text: '保存',
                                    iconCls: 'acceptIcon',
                                    handler: function () {
                                        var gId = groupSelect.getValue();
                                        if (paramForm.form.isValid()) {
                                            Ext.MessageBox.wait("正在保存数据,稍后......");
                                            paramForm.form.submit({
                                                url: '<g:createLink action="paramSave"/>',
                                                params: {gId: gId},
                                                success: function (form, action) {
                                                    Ext.MessageBox.hide();
                                                    Ext.MessageBox.show({title: '提示:', msg: '新增信息成功!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.INFO});
                                                    paramForm.form.reset();
                                                    paramWin.hide();
                                                    reloadParam();
                                                },
                                                failure: function (form, action) {
                                                    Ext.MessageBox.hide();
                                                    if (!action.hasOwnProperty("result"))
                                                        Ext.MessageBox.show({title: '提示:', msg: '新增信息失败!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                                    else
                                                        Ext.MessageBox.show({title: '提示:', msg: action.result.alertMsg, width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                                }
                                            });
                                        } else {
                                            Ext.MessageBox.show({title: '提示:', msg: '请填写完成再提交!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                        }
                                    }
                                },
                                {
                                    text: '清空',
                                    iconCls: 'wrenchIcon',
                                    handler: function () {
                                        paramForm.form.reset();//清空表单
                                    }
                                }
                            ]);
                        }
                    }
                },
                {
                    text: '修改',
                    iconCls: 'page_edit_1Icon',
                    handler: function () {
                        var selection = grid.selModel.getSelection();
                        if (selection == undefined || selection == null || selection == "") {
                            Ext.MessageBox.show({title: '提示:', msg: '必须选择一条记录!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                            return;
                        }
                        var selectedKey = selection[0].get("id");
                        if (!groupSelect.getValue()) {
                            Ext.MessageBox.show({title: '提示:', msg: '必须选择一条分组记录!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                            return;
                        }
                        var groupSelectParames = new Array();
                        groupSelectParames = groupSelect.getRawValue().split("@");
                        if (groupSelectParames.length == 2 && groupSelectParames[1] == "登录账户信息") {
                            paramFormUser.form.reset();
                            paramWindowUser('修改参数', paramFormUser, [
                                {
                                    text: '保存',
                                    iconCls: 'acceptIcon',
                                    handler: function () {
                                        var gId = groupSelect.getValue();
                                        if (paramFormUser.form.isValid()) {
                                            Ext.MessageBox.wait("正在保存数据,稍后......");
                                            paramFormUser.form.submit({
                                                url: '<g:createLink action="paramSave"/>',
                                                params: {gId: gId},
                                                success: function (form, action) {
                                                    Ext.MessageBox.hide();
                                                    Ext.MessageBox.show({title: '提示:', msg: '修改信息成功!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.INFO});
                                                    paramFormUser.form.reset();
                                                    paramWinUser.hide();
                                                    reloadParam();
                                                },
                                                failure: function (form, action) {
                                                    Ext.MessageBox.hide();
                                                    if (!action.hasOwnProperty("result"))
                                                        Ext.MessageBox.show({title: '提示:', msg: '修改信息失败!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                                    else
                                                        Ext.MessageBox.show({title: '提示:', msg: action.result.alertMsg, width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                                }
                                            });
                                        } else {
                                            Ext.MessageBox.show({title: '提示:', msg: '请填写完成再提交!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                        }
                                    }
                                },
                                {
                                    text: '清空',
                                    iconCls: 'wrenchIcon',
                                    handler: function () {
                                        paramFormUser.form.reset();//清空表单
                                    }
                                }
                            ]);
                            paramFormUser.form.load({
                                waitMsg: '正在加载数据请稍后......', //提示信息
                                waitTitle: '提示', //标题
                                url: '<g:createLink action="paramShow"/>',
                                params: {id: selectedKey},
                                method: 'POST', //请求方式
                                success: function (form, action) {
                                    if (action.result.data.paramCode == "userName") {
                                        var authorization_name = action.result.data.paramValue.split("@")[0];
                                        Ext.getCmp("authorization_value").setValue(authorization_name)
                                    }
                                },
                                failure: function (form, action) {//加载失败的处理函数
                                    Ext.MessageBox.show({title: '提示:', msg: '数据加载失败!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                    paramWinUser.hide();
                                }
                            });
                        } else {
                            paramForm.form.reset();
                            paramWindow('修改参数', paramForm, [
                                {
                                    text: '保存',
                                    iconCls: 'acceptIcon',
                                    handler: function () {
                                        var gId = groupSelect.getValue();
                                        if (paramForm.form.isValid()) {
                                            Ext.MessageBox.wait("正在保存数据,稍后......");
                                            paramForm.form.submit({
                                                url: '<g:createLink action="paramSave"/>',
                                                params: {gId: gId},
                                                success: function (form, action) {
                                                    Ext.MessageBox.hide();
                                                    Ext.MessageBox.show({title: '提示:', msg: '修改信息成功!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.INFO});
                                                    paramForm.form.reset();
                                                    paramWin.hide();
                                                    reloadParam();
                                                },
                                                failure: function (form, action) {
                                                    Ext.MessageBox.hide();
                                                    if (!action.hasOwnProperty("result"))
                                                        Ext.MessageBox.show({title: '提示:', msg: '修改信息失败!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                                    else
                                                        Ext.MessageBox.show({title: '提示:', msg: action.result.alertMsg, width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                                }
                                            });
                                        } else {
                                            Ext.MessageBox.show({title: '提示:', msg: '请填写完成再提交!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                        }
                                    }
                                },
                                {
                                    text: '清空',
                                    iconCls: 'wrenchIcon',
                                    handler: function () {
                                        paramForm.form.reset();//清空表单
                                    }
                                }
                            ]);
                            paramForm.form.load({
                                waitMsg: '正在加载数据请稍后......', //提示信息
                                waitTitle: '提示', //标题
                                url: '<g:createLink action="paramShow"/>',
                                params: {id: selectedKey},
                                method: 'POST', //请求方式
                                failure: function (form, action) {//加载失败的处理函数
                                    Ext.MessageBox.show({title: '提示:', msg: '数据加载失败!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                    paramWin.hide();
                                }
                            });
                        }


                    }
                },
                {
                    text: '删除',
                    iconCls: 'page_delIcon',
                    handler: function () {
                        var selection = grid.selModel.getSelection();

                        if (selection == undefined || selection == null || selection == "") {
                            Ext.MessageBox.show({
                                title: '提示:',
                                msg: '必须选择一条记录!',
                                width: 300,
                                buttons: Ext.MessageBox.OK,
                                icon: Ext.MessageBox.ERROR
                            });
                            return;
                        }

                        Ext.MessageBox.confirm("删除:", "确定删除该条数据?", function (e) {
                            if (e == "yes") {
                                var selectedKey = selection[0].get("id");
                                Ext.Ajax.request({
                                    url: '<g:createLink action="paramDelete"/>',
                                    params: {id: selectedKey},
                                    success: function (r) {
                                        var result = Ext.JSON.decode(r.responseText);
                                        if (result.success) {
                                            Ext.MessageBox.show({title: '提示:', msg: '删除信息成功!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.INFO});
                                            reloadParam();
                                        } else {
                                            Ext.MessageBox.show({title: '提示:', msg: result.alertMsg, width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                        }
                                    },
                                    failure: function (r) {
                                        var result = Ext.JSON.decode(r.responseText);
                                        Ext.MessageBox.show({title: '提示:', msg: "删除失败,请重试!", width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                        reloadParam();
                                    }
                                });
                            }
                        });
                    }
                }
            ]
        });

        //创建数据源
        var paramStore = Ext.create('Ext.data.Store', {
            proxy: {
                type: 'ajax',
                url: '<g:createLink action="listParams"/>',
                actionMethods: {read: 'POST'},
                reader: {
                    type: 'json',
                    root: 'data'
                },
                simpleSortMode: true
            },
            fields: dataFields,
            idProperty: 'id',
            autoLoad: false
        });

        function reloadParam() {
            paramStore.load({
                params: {id: groupSelect.getValue()}
            });
        }

        //表格数据
        var grid = Ext.create('Ext.ListView', {
            region: 'center',
            title: '参数管理',
            autoFill: false,
            autoHeight: true,
            store: paramStore,
            columns: columnHeads,
            columnLines: true,
            multiSelect: false,
            buttonAlign: 'center',
            tbar: tbar,
            listeners: {
                scrollershow: function (scroller) {
                    if (scroller && scroller.scrollEl) {
                        scroller.clearManagedListeners();
                        scroller.mon(scroller.scrollEl, 'scroll', scroller.onElScroll, scroller);
                    }
                }
            }
        });

        Ext.create('Ext.container.Viewport', {
            layout: 'border',
            padding: 10,
            style: 'background-color:transparent',
            renderTo: Ext.getBody(),
            items: [groupPanel, grid]
        });
    });
</script>

</head>

<body>
</body>
</html>

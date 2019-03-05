<%@ page import="com.util.enums.StationType" %>
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

        function closeWin() {
            parent.Ext.getCmp('top_iframe').close();
        }
        var stationTypeData = [];
        <g:each in="${StationType.values()}">
        stationTypeData.push(['${it.name()}', '${it}']);
        </g:each>
        var buttons = null;
        <g:if test="${params.opType=='add'}">
        buttons = [
            {
                text: '保存',
                iconCls: 'acceptIcon',
                disabled: false,

                handler: function () {
                    if (functionForm.form.isValid()) {
                        Ext.MessageBox.wait("正在保存数据,稍后......");
                        functionForm.form.submit({
                            url: '<g:createLink action="save"/>',
                            success: function (form, action) {
                                Ext.MessageBox.hide();
                                Ext.MessageBox.show({title: '提示:', msg: '新增信息成功!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.INFO, fn: function () {
                                    functionForm.form.reset();//清空表单
                                    closeWin();
                                }});
                            },
                            failure: function (form, action) {
                                Ext.MessageBox.hide();
                                if (!action.hasOwnProperty("result"))
                                    Ext.MessageBox.show({title: '提示:', msg: '新增信息失败!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                else
                                    Ext.MessageBox.show({title: '提示:', msg: action.result.alertMsg, width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                            }
                        });
                    }
                    else {
                        Ext.MessageBox.show({title: '提示:', msg: '请填写完成再提交!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                    }
                }
            },
            {
                text: '清空',

                iconCls: 'wrenchIcon',
                handler: function () {
                    functionForm.form.reset();//清空表单
                }
            }
        ];
        </g:if>

        <g:if test="${params.opType=='edit'}">
        buttons = [
            {
                text: '保存',
                iconCls: 'acceptIcon',

                disabled: false,
                handler: function () {
                    if (functionForm.form.isValid()) {
                        Ext.MessageBox.wait("正在保存数据,稍后......");
                        functionForm.form.submit({
                            url: '<g:createLink action="save" />',
                            success: function (form, action) {
                                Ext.MessageBox.hide();
                                Ext.MessageBox.show({title: '提示:', msg: '修改信息成功!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.INFO, fn: function () {
                                    functionForm.form.reset();//清空表单
                                    closeWin();
                                }});
                            },
                            failure: function (form, action) {
                                Ext.MessageBox.hide();
                                if (!action.hasOwnProperty("result"))
                                    Ext.MessageBox.show({title: '提示:', msg: '修改信息失败!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                                else
                                    Ext.MessageBox.show({title: '提示:', msg: action.result.alertMsg, width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                            }
                        });
                    }
                    else {
                        Ext.MessageBox.show({title: '提示:', msg: '请填写完成再提交!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                    }
                }
            },
            {
                text: '清空',
                iconCls: 'wrenchIcon',

                handler: function () {
                    functionForm.form.reset();//清空表单
                }
            }
        ];
        </g:if>

        //新增,修改form
        var functionForm = new Ext.FormPanel({
            labelWidth: 100,
            defaults: {  width: 300 },
            frame: true,
            bodyStyle: 'padding:5px 5px 0',
            margin: '2 2',
            waitMsgTarget: true,
            defaultType: 'textfield',
            items: [
                <g:if test="${params.opType=='edit'}">
                {
                    fieldLabel: 'id',
                    name: 'id',
                    hidden: true,
                    value:${params.id},
                    hideLabel: true,
                    allowBlank: true
                },
                </g:if>
                <g:if test="${params.opType=='add'}">
                {
                    fieldLabel: '上级站点',
                    name: 'parent.id',
                    value:${params['parentId']},
                    hidden: true,
                    hideLabel: true,
                    allowBlank: false
                },
                </g:if>
                {
                    xtype: 'combobox',
                    fieldLabel: '站点类别',
                    name: 'stationType',
                    id: 'stationType',
                    allowBlank: true,
                    editable: false,
                    multiSelect: false,
                    queryMode: 'local',
                    store: new Ext.data.ArrayStore({
                        fields: ['id', 'stationTypeName'],
                        data: stationTypeData
                    }),
                    valueField: 'id',
                    displayField: 'stationTypeName'
                },
                {
                    fieldLabel: '站点名称',
                    name: 'stationName',
                    allowBlank: true
                },
                {
                    fieldLabel: '站点代码',
                    name: 'stationCode',
                    allowBlank: true
                },
                {
                    fieldLabel: '站点简称',
                    name: 'shortcut',
                    allowBlank: true
                },
                {
                    fieldLabel: '站点电话',
                    name: 'phone',
                    allowBlank: true
                }

            ]
            <g:if test="${params.opType=='edit'||params.opType=='add'}"> ,buttonAlign: 'center', buttons: buttons
            </g:if>
        });

        function loadData(url) {
            functionForm.getForm().load({
                waitMsg: '正在加载数据请稍后......', //提示信息
                waitTitle: '提示', //标题
                url: url,
                params: {id: '${params["parent.id"]}'},
                method: 'POST', //请求方式
                failure: function (form, action) {//加载失败的处理函数
                    Ext.MessageBox.show({title: '提示:', msg: '数据加载失败!', width: 300, buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.ERROR});
                    closeWin();
                },
                success: function (form, action) {
                    for(i = 0 ;i<stationTypeData.length ; i++){
                        if(stationTypeData[i][1]==action.result.data.stationType.toString()){
                            Ext.getCmp("stationType").setRawValue(stationTypeData[i][0]);
                            Ext.getCmp("stationType").setValue(stationTypeData[i][0]);
                        }
                    }
                }
            });
        }

        var win = Ext.create('Ext.container.Viewport', {
            renderTo: Ext.getBody(),
            bodyStyle: 'padding: 5px;',
            items: [
                functionForm
            ]
        });
        win.show();

        <g:if test="${params.opType=='edit'||params.opType=='show'}">
        loadData('<g:createLink action="show" params="[id : params.id]"/>');
        </g:if>

    });

</script>

</head>

<body>
</body>
</html>
<%@ page import="com.util.enums.CompleteState; com.util.enums.OrderState; com.util.enums.OrderType; com.xujp.dj.Company;com.xujp.dj.Order" %>
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
    .row-s .x-grid-cell {
        background-color: red !important;
    }

    .row-f .x-grid-cell {
        background-color: red !important;
    }
    </style>
    <script type="text/javascript">
        Ext.onReady(function () {
            Ext.tip.QuickTipManager.init();
            var winWidth = document.body.clientWidth * 0.618;

            var companyData = [];
            <g:each in="${Company.list([sort: 'companyName'])}">
            companyData.push([${it.id}, '${it.companyName}']);
            </g:each>
            var orderTypeData = [];
            <g:each in="${OrderType.values()}">
            orderTypeData.push(['${it.ordinal()}', '${it}']);
            </g:each>
            var orderStateData = [];
            <g:each in="${OrderState.values()}">
            orderStateData.push(['${it.ordinal()}', '${it}']);
            </g:each>
            var completeStateData = [];
            <g:each in="${CompleteState.values()}">
            completeStateData.push(['${it.ordinal()}', '${it}']);
            </g:each>
            var targetStation = Ext.create("Ext.ux.ComboBoxTree", {
                name: 'targetStationSearch',
                hiddenName: 'targetStationSearch',
                storeUrl: '<g:createLink action="station" controller="common" params="[stationId:station?.id,selectType:'NOTSELECT']" />',
                //anchor: '40%',
                fieldLabel: '目标站点',
                columnWidth: .33,
                margin: '5 5 5 5',
                editable: true,
                rootId: '${station?.id}',
                allowBlank: true,
                rootText: '${station?.stationName}',
                multiSelect: true,
                selectClick: true
            });

            var initialStation = Ext.create("Ext.ux.ComboBoxTree", {
                name: 'initialStationSearch',
                hiddenName: 'initialStationSearch',
                storeUrl: '<g:createLink action="station" controller="common" params="[stationId:0,selectType:'NOTSELECT']" />',
                //anchor: '40%',
                fieldLabel: '出发站点',
                columnWidth: .33,
                margin: '5 5 5 5',
                editable: true,
                rootId: 0,
                allowBlank: true,
                rootText: '操作中心',
                multiSelect: true,
                selectClick: true
            });


            //查询form
            var orderSeachForm = new Ext.FormPanel({
                //collapsible : true,// 是否可以展开
                frame: true,
                autoScroll: true,
                autoWidth: true,
                autoHeight: true,
                waitMsgTarget: true,
                defaultType: 'textfield',
                layout: 'column',
                items: [
                    {
                        columnWidth: .33,
                        xtype: 'textfield',
                        margin: '5 5 5 5',
                        fieldLabel: '运单号',
                        name: 'freightNoSearch',
                        allowBlank: true
                    },
                    {
                        columnWidth: .33,
                        xtype: 'textfield',
                        margin: '5 5 5 5',
                        fieldLabel: '承运商',
                        name: 'carrierSearch',
                        allowBlank: true
                    }
                    ,
                    {
                        columnWidth: .33,
                        xtype: 'textfield',
                        margin: '5 5 5 5',
                        fieldLabel: '承运商单号',
                        name: 'carrierFreightNoSearch',
                        allowBlank: true
                    }
                    ,
                    {
                        columnWidth: .33,
                        xtype: 'combobox',
                        fieldLabel: '运单类型',
                        name: 'orderTypeSearch',
                        id: 'orderTypeSearch',
                        allowBlank: true,
                        editable: false,
                        multiSelect: true,
                        queryMode: 'local',
                        store: new Ext.data.ArrayStore({
                            fields: ['id', 'orderTypeName'],
                            data: orderTypeData
                        }),
                        valueField: 'id',
                        displayField: 'orderTypeName',
                        value: '${params?.searchOrderType}',
                        margin: '5 5 5 5'
                    },
                    {
                        columnWidth: .33,
                        xtype: 'textfield',
                        margin: '5 5 5 5',
                        fieldLabel: '收货人',
                        name: 'customerSearch',
                        allowBlank: true
                    }
                    ,
                    {
                        columnWidth: .33,
                        xtype: 'textfield',
                        margin: '5 5 5 5',
                        fieldLabel: '收货人电话',
                        name: 'phoneNoSearch',
                        allowBlank: true
                    }
                    ,
                    {
                        columnWidth: .99,
                        xtype: 'textfield',
                        margin: '5 5 5 5',
                        fieldLabel: '收货人地址',
                        name: 'addressSearch',
                        allowBlank: true
                    }
                    ,
                    {
                        columnWidth: .33,
                        xtype: 'textfield',
                        margin: '5 5 5 5',
                        fieldLabel: '收货店铺代码',
                        name: 'customerCodeSearch',
                        allowBlank: true
                    }
                    ,
                    {
                        columnWidth: .33,
                        xtype: 'textfield',
                        margin: '5 5 5 5',
                        fieldLabel: '操作性质',
                        name: 'operationTypeSearch',
                        allowBlank: true
                    }
                    ,
                    {
                        columnWidth: .33,
                        xtype: 'textfield',
                        margin: '5 5 5 5',
                        fieldLabel: '货品名称',
                        name: 'goodsNameSearch',
                        allowBlank: true
                    }
                    ,
                    {
                        columnWidth: .33,
                        xtype: 'textfield',
                        margin: '5 5 5 5',
                        fieldLabel: '体积',
                        name: 'volumeSearch',
                        regex: /^(([1-9]\d{0,9})|0)(\.\d{1,2})?$/, //email格式验证
                        regexText: "不是有效体积",
                        allowBlank: true
                    }
                    ,

                    {
                        columnWidth: .33,
                        xtype: 'textfield',
                        margin: '5 5 5 5',
                        fieldLabel: '重量',
                        regex: /^(([1-9]\d{0,9})|0)(\.\d{1,2})?$/, //email格式验证
                        regexText: "不是有效重量",
                        name: 'weightSearch',
                        allowBlank: true
                    },
                    {
                        columnWidth: .33,
                        xtype: 'combobox',
                        fieldLabel: '是否补全',
                        name: 'isCompleteSearch',
                        id: 'isCompleteSearch',
                        queryMode: 'local', //本地数据
                        editable: false,
                        value: '',
                        store: Ext.create("Ext.data.Store", {
                            fields: ["id", "name"],
                            data: [
                                {"id": "0", "name": "未补全"},
                                {"id": "1", "name": "已补全"}
                            ]
                        }),
                        valueField: 'id',
                        displayField: 'name',
                        margin: '5 5 5 5',
                        allowBlank: true
                    },
                    {
                        columnWidth: .99,
                        xtype: 'fieldset',
                        margin: '5 5 5 5',
                        layout: 'column',
                        title: '配送信息查询',
                        checkboxToggle: true,
                        items: [
                            {
                                columnWidth: .33,
                                xtype: 'combobox',
                                fieldLabel: '所属公司',
                                name: 'companySearch',
                                allowBlank: true,
                                editable: false,
                                multiSelect: true,
                                margin: '5 5 5 5',
                                queryMode: 'local',
                                store: new Ext.data.ArrayStore({
                                    fields: ['id', 'companyName'],
                                    data: companyData
                                }),
                                valueField: 'id',
                                displayField: 'companyName'
                            },
                            initialStation,
                            targetStation,
                            {
                                columnWidth: .33,
                                xtype: 'combobox',
                                fieldLabel: '运单状态',
                                name: 'orderStateSearch',
                                id: 'orderStateSearch',
                                allowBlank: true,
                                editable: false,
                                multiSelect: true,
                                queryMode: 'local',
                                store: new Ext.data.ArrayStore({
                                    fields: ['id', 'orderStateName'],
                                    data: orderStateData
                                }),
                                valueField: 'id',
                                displayField: 'orderStateName',
                                margin: '5 5 5 5'
                            },
                            {
                                columnWidth: .33,
                                xtype: 'combobox',
                                fieldLabel: '完成状态',
                                name: 'completeStateSearch',
                                id: 'completeStateSearch',
                                allowBlank: true,
                                editable: false,
                                multiSelect: true,
                                queryMode: 'local',
                                store: new Ext.data.ArrayStore({
                                    fields: ['id', 'completeStateName'],
                                    data: completeStateData
                                }),
                                valueField: 'id',
                                displayField: 'completeStateName',
                                margin: '5 5 5 5'
                            },
                            {
                                columnWidth: .33,
                                xtype: 'combobox',
                                fieldLabel: '是否完成',
                                name: 'isFinishedSearch',
                                id: 'isFinishedSearch',
                                queryMode: 'local', //本地数据
                                editable: false,
                                value: '',
                                store: Ext.create("Ext.data.Store", {
                                    fields: ["id", "name"],
                                    data: [
                                        {"id": "0", "name": "未完成"},
                                        {"id": "1", "name": "已完成"}
                                    ]
                                }),
                                valueField: 'id',
                                displayField: 'name',
                                margin: '5 5 5 5',
                                allowBlank: true
                            },
                            {
                                columnWidth: .31,
                                xtype: 'datetimefield',
                                name: 'beginWareEnterDate',
                                id: 'beginWareEnterDate',
                                value: '${params?.beginWareEnterDate}',
                                margin: '5 5 5 5',
                                format: 'Y-m-d H:i:s',
                                editable: false,
                                labelStyle: 'width:100',
                                fieldLabel: '库房入库日期',
                                listeners: {
                                    'focus': function () {
                                        this.setValue('${params.startDate}');
                                    }
                                }
                            },
                            {
                                margin: '5 5 5 5',
                                columnWidth: .03,
                                align: 'center',
                                xtype: 'label',
                                text: '-'
                            },
                            {
                                columnWidth: .16,
                                xtype: 'datetimefield',
                                name: 'endWareEnterDate',
                                id: 'endWareEnterDate',
                                value: '${params?.endWareEnterDate}',
                                margin: '5 5 5 5',
                                format: 'Y-m-d H:i:s',
                                editable: false,
                                listeners: {
                                    'focus': function () {
                                        this.setValue('${params.endDate}');
                                    }
                                }
                            },
                            {
                                columnWidth: .31,
                                xtype: 'datetimefield',
                                name: 'beginWareLeaveDate',
                                id: 'beginWareLeaveDate',
                                margin: '5 5 5 5',
                                format: 'Y-m-d H:i:s',
                                editable: false,
                                labelStyle: 'width:100',
                                fieldLabel: '库房出库日期',
                                listeners: {
                                    'focus': function () {
                                        this.setValue('${params.startDate}');
                                    }
                                }
                            },
                            {
                                margin: '5 5 5 5',
                                columnWidth: .03,
                                align: 'center',
                                xtype: 'label',
                                text: '-'
                            },
                            {
                                columnWidth: .16,
                                xtype: 'datetimefield',
                                name: 'endWareLeaveDate',
                                id: 'endWareLeaveDate',
                                margin: '5 5 5 5',
                                format: 'Y-m-d H:i:s',
                                editable: false,
                                listeners: {
                                    'focus': function () {
                                        this.setValue('${params.endDate}');
                                    }
                                }
                            },
                            {
                                columnWidth: .31,
                                xtype: 'datetimefield',
                                name: 'beginStationEnterDate',
                                id: 'beginStationEnterDate',
                                margin: '5 5 5 5',
                                format: 'Y-m-d H:i:s',
                                editable: false,
                                labelStyle: 'width:100',
                                fieldLabel: '站点入库日期',
                                listeners: {
                                    'focus': function () {
                                        this.setValue('${params.startDate}');
                                    }
                                }
                            },
                            {
                                margin: '5 5 5 5',
                                columnWidth: .03,
                                align: 'center',
                                xtype: 'label',
                                text: '-'
                            },
                            {
                                columnWidth: .16,
                                xtype: 'datetimefield',
                                name: 'endStationEnterDate',
                                id: 'endStationEnterDate',
                                margin: '5 5 5 5',
                                format: 'Y-m-d H:i:s',
                                editable: false,
                                listeners: {
                                    'focus': function () {
                                        this.setValue('${params.endDate}');
                                    }
                                }
                            },
                            {
                                columnWidth: .31,
                                xtype: 'datetimefield',
                                name: 'beginStationLeaveDate',
                                id: 'beginStationLeaveDate',
                                margin: '5 5 5 5',
                                format: 'Y-m-d H:i:s',
                                editable: false,
                                labelStyle: 'width:100',
                                fieldLabel: '站点出库日期',
                                listeners: {
                                    'focus': function () {
                                        this.setValue('${params.startDate}');
                                    }
                                }
                            },
                            {
                                margin: '5 5 5 5',
                                columnWidth: .03,
                                align: 'center',
                                xtype: 'label',
                                text: '-'
                            },
                            {
                                columnWidth: .16,
                                xtype: 'datetimefield',
                                name: 'endStationLeaveDate',
                                id: 'endStationLeaveDate',
                                margin: '5 5 5 5',
                                format: 'Y-m-d H:i:s',
                                editable: false,
                                listeners: {
                                    'focus': function () {
                                        this.setValue('${params.endDate}');
                                    }
                                }
                            },
                            {
                                columnWidth: .31,
                                xtype: 'datetimefield',
                                name: 'beginDeployEnterDate',
                                id: 'beginDeployEnterDate',
                                margin: '5 5 5 5',
                                format: 'Y-m-d H:i:s',
                                editable: false,
                                labelStyle: 'width:100',
                                fieldLabel: '直调入库日期',
                                listeners: {
                                    'focus': function () {
                                        this.setValue('${params.startDate}');
                                    }
                                }
                            },
                            {
                                margin: '5 5 5 5',
                                columnWidth: .03,
                                align: 'center',
                                xtype: 'label',
                                text: '-'
                            },
                            {
                                columnWidth: .16,
                                xtype: 'datetimefield',
                                name: 'endDeployEnterDate',
                                id: 'endDeployEnterDate',
                                margin: '5 5 5 5',
                                format: 'Y-m-d H:i:s',
                                editable: false,
                                listeners: {
                                    'focus': function () {
                                        this.setValue('${params.endDate}');
                                    }
                                }
                            },
                            {
                                columnWidth: .31,
                                xtype: 'datetimefield',
                                name: 'beginDeployLeaveDate',
                                id: 'beginDeployLeaveDate',
                                margin: '5 5 5 5',
                                format: 'Y-m-d H:i:s',
                                editable: false,
                                labelStyle: 'width:100',
                                fieldLabel: '直调出库日期',
                                listeners: {
                                    'focus': function () {
                                        this.setValue('${params.startDate}');
                                    }
                                }
                            },
                            {
                                margin: '5 5 5 5',
                                columnWidth: .03,
                                align: 'center',
                                xtype: 'label',
                                text: '-'
                            },
                            {
                                columnWidth: .16,
                                xtype: 'datetimefield',
                                name: 'endDeployLeaveDate',
                                id: 'endDeployLeaveDate',
                                margin: '5 5 5 5',
                                format: 'Y-m-d H:i:s',
                                editable: false,
                                listeners: {
                                    'focus': function () {
                                        this.setValue('${params.endDate}');
                                    }
                                }
                            }
                        ]
                    },
                    {
                        columnWidth: .33,
                        xtype: 'combobox',
                        fieldLabel: '是否异常',
                        name: 'isAbnormalSearch',
                        id: 'isAbnormalSearch',
                        queryMode: 'local', //本地数据
                        editable: false,
                        value: '',
                        store: Ext.create("Ext.data.Store", {
                            fields: ["id", "name"],
                            data: [
                                {"id": "0", "name": "正常"},
                                {"id": "1", "name": "异常"}
                            ]
                        }),
                        valueField: 'id',
                        displayField: 'name',
                        margin: '5 5 5 5',
                        allowBlank: true
                    },
                    {
                        columnWidth: .66,
                        xtype: 'textfield',
                        margin: '5 5 5 5',
                        fieldLabel: '异常原因',
                        name: 'abnormalReasionSearch',
                        allowBlank: true
                    },
                    {
                        columnWidth: .99,
                        xtype: 'textarea',
                        height: 100,
                        labelStyle: 'line-height:100%;padding-top:40px',
                        margin: '5 5 5 5',
                        fieldLabel: '多运单查询',
                        name: 'freightNos',
                        allowBlank: true
                    }


                ]
            });

            var searchWin = Ext.create('widget.window', {
                title: "运单查询",
                closable: true,
                closeAction: 'close',
                pageY: 30, // 页面定位Y坐标
                pageX: document.body.clientWidth / 4.2, // 页面定位X坐标
                constrain: true,
                collapsible: true, // 是否可收缩
                width: document.body.clientWidth * 0.80,
                height: document.body.clientHeight - 30,
                layout: 'fit',
                maximizable: true, // 设置是否可以最大化
                iconCls: 'imageIcon',
                bodyStyle: 'padding: 5px;',
                border: true,
                buttonAlign: 'center',
                items: orderSeachForm,
                buttons: [
                    {
                        text: '查询',
                        iconCls: 'page_findIcon',
                        disabled: false,
                        handler: function () {
                            if (orderSeachForm.form.isValid()) {
                                Ext.MessageBox.wait("正在查询数据,稍后......");
                                bbar.moveFirst();
                                Ext.MessageBox.hide();
                                searchWin.close();
                            }
                        }
                    },
                    {
                        text: '清空',
                        iconCls: 'wrenchIcon',
                        handler: function () {
                            orderSeachForm.form.reset();//清空表单
                        }
                    }
                ]
            });
            //新增,修改form
            var orderForm = new Ext.FormPanel({
                //collapsible : true,// 是否可以展开
                frame: true,
                margin: '2 2',
                autoScroll: true,
                autoWidth: true,
                autoHeight: true,
                //reader : _jsonFormReader,
                defaultType: 'textfield',
                layout: 'column',
                items: [

                    {
                        fieldLabel: 'id',
                        name: 'id',
                        hidden: true,
                        hideLabel: true,
                        allowBlank: true
                    },
                    {
                        columnWidth: .99,
                        xtype: 'fieldset',
                        layout: 'column',
                        title: '运单基础信息',
                        checkboxToggle: true,
                        items: [
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '运单号',
                                name: 'freightNo',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '运单类型',
                                name: 'orderType',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '公司',
                                name: 'company',
                                id: 'company',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '操作性质',
                                name: 'operationType',
                                allowBlank: true
                            },
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '出发站点',
                                id: 'initialStation',
                                name: 'initialStation',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '目标站点',
                                id: 'targetStation',
                                name: 'targetStation',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '收货店铺代码',
                                name: 'customerCode',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '收货人',
                                name: 'customer',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '收货人电话',
                                name: 'phoneNo',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '收货地址',
                                name: 'address',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '货品名称',
                                name: 'goodsName',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '发货城市',
                                name: 'startCity',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '收货城市',
                                name: 'endCity',
                                allowBlank: true
                            },
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '货品重量',
                                name: 'weight',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '货品体积',
                                name: 'volume',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '是否补全',
                                id: 'isComplete',
                                name: 'isComplete',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '应收款',
                                name: 'receivable',
                                allowBlank: true
                            }
                            ,

                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '箱数量',
                                name: 'boxNum',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '包数量',
                                name: 'packageNum',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '其他数量',
                                name: 'otherNum',
                                allowBlank: true
                            }
                        ]
                    },
                    {
                        columnWidth: .99,
                        xtype: 'fieldset',
                        layout: 'column',
                        title: '配送信息查询',
                        checkboxToggle: true,
                        items: [
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '运单状态',
                                name: 'orderState',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '完成状态',
                                name: 'completeState',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '是否完成',
                                name: 'isFinished',
                                id: 'isFinished',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '异常终结原因',
                                name: 'abnormalRemark',
                                allowBlank: true
                            }
                            ,
//                        {
//                            columnWidth: 0.5,
//                            xtype: 'textfield',
//                            margin: '5 5 5 5',
//                            fieldLabel: '收货日期',
//                            name: 'pickupDate',
//                            allowBlank: true
//                        }
//                        ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '中心入库日期',
                                name: 'wareEnterDate',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '中心出库日期',
                                name: 'wareLeaveDate',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '站点入库日期',
                                name: 'stationEnterDate',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '站点出库日期',
                                name: 'stationLeaveDate',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '直调入库日期',
                                name: 'deployEnterDate',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '直调出库日期',
                                name: 'deployLeaveDate',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '完成日期',
                                name: 'finishedDate',
                                allowBlank: true
                            },
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '承运商',
                                name: 'carrier',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '承运商单号',
                                name: 'carrierFreightNo',
                                allowBlank: true
                            },
                            {
                                columnWidth: 0.5,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '是否异常件',
                                id: 'isAbnormal',
                                name: 'isAbnormal',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.99,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '非本人签收情况',
                                name: 'completeName',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.99,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '异常原因',
                                name: 'abnormalReasion',
                                allowBlank: true
                            }
                            ,
                            {
                                columnWidth: 0.99,
                                xtype: 'textfield',
                                margin: '5 5 5 5',
                                fieldLabel: '异常处理描述',
                                name: 'remark2',
                                allowBlank: true
                            }
                        ]
                    }
                ]
            });
            //历史记录store
            var orderHistoryStore = Ext.create('Ext.data.Store', {
                proxy: {
                    type: 'ajax',
                    url: '<g:createLink action="orderHistoryInfo"/>',
                    reader: {
                        type: 'json',
                        root: 'data'
                    }
                },
                fields: ['dateCreated', 'operMsg', 'oper', 'sysSendTag', 'remark', 'orderInfo', 'enabled'],
                autoLoad: false
            });
            //历史记录表格数据
            var orderHistoryGrid = Ext.create('Ext.grid.Panel', {
                store: orderHistoryStore,
                autoScroll: true,
                columnLines: true,
                autoWidth: true,
                autoHeight: true,
                padding: '0 0 10 0',
                columns: [
                    {text: "创建日期", width: 140, dataIndex: 'dateCreated', sortable: false},
                    {text: "操作内容", width: 180, dataIndex: 'operMsg', sortable: false},
                    {
                        text: "操作人",
                        width: 150,
                        dataIndex: 'oper',
                        sortable: false,
                        renderer: function (value, metaData, record, colIndex, store, view) {
                            metaData.tdAttr = 'data-qtip="' + value + '"';
                            return value;
                        }
                    },
                    {
                        text: "备注",
                        width: 130,
                        dataIndex: 'remark',
                        sortable: false,
                        renderer: function (value, metaData, record, colIndex, store, view) {
                            metaData.tdAttr = 'data-qtip="' + value + '"';
                            return value;
                        }
                    },
                    {text: "是否有效", width: 58, dataIndex: 'enabled', sortable: false, renderer: setYesOrNo},
                    {text: "发送成功", width: 58, dataIndex: 'sysSendTag', sortable: false, renderer: setYesOrNo}
                ],
                listeners: {
                    scrollershow: function (scroller) {
                        if (scroller && scroller.scrollEl) {
                            scroller.clearManagedListeners();
                            scroller.mon(scroller.scrollEl, 'scroll', scroller.onElScroll, scroller);
                        }
                    }
                }
                //title:'ExtJS4 Grid示例',
            });

            var tabPanel = Ext.createWidget('tabpanel', {
                region: 'center',
                activeTab: 0, items: [
                    {
                        title: '运单信息',
                        autoScroll: true,
                        items: [orderForm]
                    },
                    {
                        title: '历史信息',
                        items: [orderHistoryGrid]
                    }
                ]
            });

            var isOpenWin = false;
            var orderWin;

            //查询窗口
            var orderWindow = function (titleInfo, formInfo, buttons) {
                if (!isOpenWin) {
                    orderWin = Ext.create('widget.window', {
                        title: titleInfo,
                        closable: true,
                        closeAction: 'hide',
                        pageY: 30, // 页面定位Y坐标
                        pageX: document.body.clientWidth / 4.2, // 页面定位X坐标
                        constrain: true,
                        collapsible: true, // 是否可收缩
                        width: document.body.clientWidth * 0.618,
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
                    orderWin.show();
                }
            }

            //数据字段
            var dataFields = [
                'id',
                'freightNo',
                'orderType',
                'initialStation',
                'targetStation',
                'customer',
                'customerCode',
                'phoneNo',
                'company',
                'companyCode',
                'goodsName',
                'receivable',
                'boxNum',
                'packageNum',
                'otherNum',
                'orderState',
                'completeState',
                'isComplete',
                'isFinished',
                'isAbnormal',
                'remark1',
                'completeName',
                'companyCode1'
            ];

            //表格显示及数据绑定
            var columnHeads = [
                {text: "id", width: 120, dataIndex: 'id', hidden: true, sortable: true}
                ,
                {
                    text: "运单号",
                    width: 120,
                    dataIndex: 'freightNo',
                    sortable: true,
                    summaryType: function (value, summaryData, dataIndex) {
                        return '总数:' + orderStore.getTotalCount();
                    }
                },
                {text: "运单类型", width: 70, dataIndex: 'orderType', sortable: true},
                {text: "发出店铺代码", width: 100, dataIndex: 'companyCode1', sortable: true}
                ,
                {text: "出发站点", width: 70, dataIndex: 'initialStation', sortable: true}
                ,
                {text: "目标站点", width: 70, dataIndex: 'targetStation', sortable: true}
                ,
                {text: "收货店铺代码", width: 90, dataIndex: 'customerCode', sortable: true}
                ,
                {text: "收货人", width: 70, dataIndex: 'customer', sortable: true}
                ,
                {text: "收货人电话", width: 90, dataIndex: 'phoneNo', sortable: true}
                ,
                {text: "公司", width: 70, dataIndex: 'company', sortable: true}
                ,
                {text: "公司代码", width: 90, dataIndex: 'companyCode', sortable: true}
                ,
                {text: "货品状态", width: 80, dataIndex: 'orderState', sortable: true}
                ,
                {text: "完成状态", width: 80, dataIndex: 'completeState', sortable: true}
                ,
                {text: "非本人签收", width: 80, dataIndex: 'completeName', sortable: true}
                ,
                {text: "是否完整", width: 70, dataIndex: 'isComplete', sortable: true, renderer: setYesOrNo}
                ,
                {text: "是否完成", width: 70, dataIndex: 'isFinished', sortable: true, renderer: setYesOrNo}
                ,
                {text: "是否异常", width: 70, dataIndex: 'isAbnormal', sortable: true, renderer: setYesOrNo}
                ,
                {text: "货品名称", width: 70, dataIndex: 'goodsName', sortable: true}
                ,
                {text: "应收款", width: 60, dataIndex: 'receivable', sortable: true}
                ,
                {text: "箱数", width: 40, dataIndex: 'boxNum', sortable: true}
                ,
                {text: "包数", width: 40, dataIndex: 'packageNum', sortable: true}
                ,
                {text: "其他", width: 40, dataIndex: 'otherNum', sortable: true}
                ,
                {
                    text: "备注",
                    width: 120,
                    dataIndex: 'remark1',
                    sortable: true,
                    renderer: function (value, metaData, record, colIndex, store, view) {
                        metaData.tdAttr = 'data-qtip="' + value + '"';
                        return value;
                    }
                }
            ];


            var tbar = Ext.create('Ext.Toolbar', {
                items: [
                    {
                        text: '查询',
                        iconCls: 'page_findIcon',
                        handler: function () {
                            searchWin.show();
                        }
                    },
                    {
                        text: '导出',
                        iconCls: 'uploadIcon',
                        handler: function () {
                            if (!Ext.fly('test')) {
                                var frm = document.createElement('form');
                                frm.id = 'orderSeachForm';
                                frm.name = id;
                                frm.style.display = 'none';
                                document.body.appendChild(frm);
                            }

                            Ext.MessageBox.wait("请等待出现“文件下载”提示后，再操作系统,请稍后......");
                            Ext.Ajax.request({
                                url: '<g:createLink action="export"/>',
                                form: Ext.fly('orderSeachForm'),
                                method: 'POST',
                                params: orderSeachForm.form.getValues(),
                                isUpload: true,
                                timeout: 60000,
                                success: function (r) {
                                    Ext.MessageBox.show({
                                        title: '提示:',
                                        msg: r.responseText,
                                        width: 400,
                                        buttons: Ext.MessageBox.OK,
                                        icon: Ext.MessageBox.ERROR
                                    });
                                }
                            });
                            setTimeout("javascript:Ext.MessageBox.hide();", 15000);
                        }
                    }
                ]
            });

            //创建数据源
            var orderStore = Ext.create('Ext.data.Store', {
                pageSize: 10,
                proxy: {
                    type: 'ajax',
                    url: '<g:createLink action="list"/>',
                    actionMethods: {read: 'POST'},
                    reader: {
                        type: 'json',
                        root: 'data',
                        totalProperty: 'totalCount'
                    },
                    simpleSortMode: true
                },
                fields: dataFields,
                idProperty: 'id',
                autoLoad: true
            });


            //每页显示条数下拉选择框
            var pagesize_combo = new Ext.form.ComboBox({
                name: 'pagesize',
                triggerAction: 'all',
                mode: 'local',
                store: new Ext.data.ArrayStore({
                    fields: ['value', 'text'],
                    data: [
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
                valueField: 'value',
                displayField: 'text',
                value: '10',
                editable: false,
                width: 45,
                listeners: {
                    select: function (combo, record, eOpts) {
                        orderStore.pageSize = parseInt(combo.getValue());
                        bbar.updateInfo();
                        bbar.moveFirst();
                        orderStore.load();
                    }
                }
            });

            var bbar = Ext.create('Ext.PagingToolbar', {
                store: orderStore,
                displayInfo: true,
                displayMsg: '当前显示 {0} - {1} 条  , 共 {2} 条',
                emptyMsg: "没有符合条件的记录",
                items: ["&nbsp;每页", pagesize_combo, '条']
            });

            //表格数据
            var orderGrid = Ext.create('Ext.grid.Panel', {
                autoFill: false,
                autoHeight: true,
                heigth: 500,
                store: orderStore,
                tbar: tbar,
                columns: [Ext.create('Ext.grid.RowNumberer', {header: 'NO', width: 34}), columnHeads],
                margin: '4 4',
                title: '运单数据',
                features: [
                    {
                        ftype: 'summary'
                    }
                ],
                renderTo: Ext.getBody(),
                columnLines: true,
                bbar: bbar,
                viewConfig: {
                    forceFit: true,
                    getRowClass: function (record, index, rowParams, store) {
                        //禁用数据显示红色
                        if (record.get('isAbnormal') == true) {
                            return "row-f";
                        } else {
                            return '';
                        }

                    }
                }
            });


            //下页提交提交查询条件
            orderStore.on('beforeload', function (store, options) {
                Ext.apply(store.proxy.extraParams, orderSeachForm.form.getValues());
            });


            //表格双击事件（查看单条数据明细）
            orderGrid.addListener('itemdblclick', function () {
                orderWindow('运单详情', tabPanel, "");
                loadData('<g:createLink action="show"/>');
            }, this);

            function loadData(url) {
                var selection = orderGrid.selModel.getSelection();

                if (selection == undefined || selection == null || selection == "") {
                    Ext.MessageBox.show({
                        title: '提示:',
                        msg: '必须选择一条记录!',
                        width: 300,
                        buttons: Ext.MessageBox.OK,
                        icon: Ext.MessageBox.ERROR
                    });
                    orderWin.hide();
                    return;
                }
                var selectedKey = selection[0].get("id");//returns array of selected rows ids only

                if (selectedKey != undefined && selectedKey != null && selectedKey != "") {
                    orderForm.form.load({
                        waitMsg: '正在加载数据请稍后......', //提示信息
                        waitTitle: '提示', //标题
                        url: url,
                        params: {id: selectedKey},
                        method: 'POST', //请求方式
                        failure: function (form, action) {//加载失败的处理函数
                            Ext.MessageBox.show({
                                title: '提示:',
                                msg: '数据加载失败!',
                                width: 300,
                                buttons: Ext.MessageBox.OK,
                                icon: Ext.MessageBox.ERROR
                            });
                            orderWin.hide();
                        }, success: function (form, action) {
                            if (action.result.data.isFinished) {
                                Ext.getCmp("isFinished").setValue('已完成');
                            } else {
                                Ext.getCmp("isFinished").setValue('未完成');
                            }

                            if (action.result.data.isComplete) {
                                Ext.getCmp("isComplete").setValue("已补全");
                            } else {
                                Ext.getCmp("isComplete").setValue("未补全");
                            }
                            if (action.result.data.isAbnormal) {
                                Ext.getCmp("isAbnormal").setValue("异常件");
                            } else {
                                Ext.getCmp("isAbnormal").setValue("正常件");
                            }
//
//                        if (action.result.data.company == null) {
//                            Ext.getCmp("company").setValue("");
//                        } else {
//                            Ext.getCmp("company").setValue(action.result.data.company.companyName);
//                        }
//                        if (action.result.data.targetStation == null) {
//                            Ext.getCmp("targetStation").setValue("");
//                        } else {
//                            Ext.getCmp("targetStation").setValue(action.result.data.targetStation.stationName);
//                        }
//                        if (action.result.data.initialStation == null) {
//                            Ext.getCmp("initialStation").setValue("");
//                        } else {
//                            Ext.getCmp("initialStation").setValue(action.result.data.initialStation.stationName);
//                        }
                        }
                    });
                    orderHistoryStore.load({params: {orderId: selectedKey}});

                } else {
                    Ext.MessageBox.show({
                        title: '提示:',
                        msg: '数据加载失败!',
                        width: 300,
                        buttons: Ext.MessageBox.OK,
                        icon: Ext.MessageBox.ERROR
                    });
                    orderWin.hide();
                }
            }

        });
    </script>

</head>

<body>
<div id='orderDiv'></div>

</body>
</html>
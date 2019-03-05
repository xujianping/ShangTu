<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 12-9-17
  Time: 下午2:39
  To change this template use File | Settings | File Templates.
--%>
<%@ page import="com.util.enums.StationType; com.xujp.dj.Station; com.util.enums.OrderState; com.util.enums.CompleteState; com.util.enums.OrderType; com.xujp.dj.Company" contentType="text/html;charset=UTF-8"  %>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="layout" content="ext"/>
<link rel="stylesheet" href="${resource(dir: 'css', file: 'ext_icon.css')}"/>
<g:javascript src="common.js"></g:javascript>
<g:javascript src="ext-lang-zh_CN.js"></g:javascript>
<g:javascript src="dateTimePicker.js"></g:javascript>
<g:javascript src="dateTimeField.js"></g:javascript>
<style type="text/css" >
#searchForm{
font-size:35px;
line-height:normal;
font-style: normal;
font-variant: normal;
}
</style>
<script type="text/javascript">
    Ext.onReady(function(){
        Ext.tip.QuickTipManager.init();
         //查询窗体
        var searchForm = Ext.create('Ext.form.Panel',{
            autoHeight:true,
            border:0,
            frame : true,
            width:document.body.clientWidth-20,
            style:"margin-left: 10;margin-top:8;margin-bottom:8",
            defaultType: 'textfield',
            title:'输入运单号',
            id:'searchForm',
            items:[
                {
                    style:"margin-left: 60;margin-top:20;",
                    labelStyle: 'font-size:26px;line-height:120%;',
                    fieldStyle: 'font-size:32px;line-height:120%;',
                    height:40,
                    width:460,
                    xtype:'textfield',
                    fieldLabel:'运单号',
                    id:'freightNoInfo',
                    listeners:{
                        specialkey:function (field, e) {
                            if(e.getKey() == Ext.EventObject.ENTER){
                                var freightNo = Ext.getCmp('freightNoInfo').value;
                                if(freightNo.length < 4){
                                    Ext.MessageBox.show({title:'提示:', msg:'请检查运单输入长度!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                    return false;
                                }
                                loadDate(freightNo);
                            }
                        }
                    }
                }
            ]
        });

        //基本信息,修改form
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
        orderStateData.push(['${it.name()}', '${it}']);
        </g:each>
        var completeStateData = [];
        <g:each in="${CompleteState.values()}">
        completeStateData.push(['${it.name()}', '${it}']);
        </g:each>
        var stationData = []
        stationData.push([0, '操作中心']);
        <g:each in="${Station.findAllByStationType(StationType.ST)}">
        stationData.push(['${it.id}', '${it.stationName}']);
        </g:each>

        var orderForm =  new Ext.FormPanel({
            //frame:true,
            width:document.body.clientWidth-20,
            style:"margin-left: 10;margin-top:8;margin-bottom:8",
            autoWidth:true,
            autoHeight:true,
            frame:true,
            defaultType: 'textfield',
            layout: 'column',
            items: [
                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    hidden:true,
                    margin: '5 5 5 5',
                    fieldLabel: 'ID',
                    name: 'id',
                    id: 'id',
                    allowBlank: true
                },
                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    margin: '5 5 5 5',
                    fieldLabel: '订单号',
                    name: 'orderNo',
                    allowBlank: true
                }
                ,
                {
                    columnWidth: .33,
                    xtype: 'combobox',
                    fieldLabel: '订单类型',
                    name: 'orderType',
                    id: 'orderType',
                    allowBlank: true,
                    editable: false,
                    multiSelect: false,
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
                    xtype: 'combobox',
                    fieldLabel: '所属公司',
                    name: 'company',
                    id: 'company',
                    allowBlank: true,
                    editable: false,
                    multiSelect: false,
                    margin: '5 5 5 5',
                    queryMode: 'local',
                    store: new Ext.data.ArrayStore({
                        fields: ['id', 'companyName'],
                        data: companyData
                    }),
                    valueField: 'id',
                    displayField: 'companyName'
                },
                {
                    columnWidth: .33,
                    xtype: 'combobox',
                    fieldLabel: '是否补全',
                    name: 'isComplete',
                    id: 'isComplete',
                    queryMode: 'local', //本地数据
                    editable: false,
                    value: '',
                    store: Ext.create("Ext.data.Store", {
                        fields: ["id", "name"],
                        data: [
                            { "id": "0", "name": "未补全" },
                            { "id": "1", "name": "已补全" }
                        ]
                    }),
                    valueField: 'id',
                    displayField: 'name',
                    margin: '5 5 5 5',
                    allowBlank: true
                },
                {
                    columnWidth: .33,
                    xtype: 'combobox',
                    fieldLabel: '订单状态',
                    name: 'orderState',
                    id: 'orderState',
                    allowBlank: true,
                    editable: false,
                    multiSelect: false,
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
                    fieldLabel: '目标站点',
                    name: 'targetStation',
                    id: 'targetStation',
                    allowBlank: true,
                    editable: false,
                    multiSelect: false,
                    queryMode: 'local',
                    store: new Ext.data.ArrayStore({
                        fields: ['id', 'stationName'],
                        data: stationData
                    }),
                    valueField: 'id',
                    displayField: 'stationName',
                    margin: '5 5 5 5'
                },
                {
                    columnWidth: .33,
                    xtype: 'combobox',
                    fieldLabel: '出发站点',
                    name: 'initialStation',
                    id: 'initialStation',
                    allowBlank: true,
                    editable: false,
                    multiSelect: false,
                    queryMode: 'local',
                    store: new Ext.data.ArrayStore({
                        fields: ['id', 'stationName'],
                        data: stationData
                    }),
                    valueField: 'id',
                    displayField: 'stationName',
                    margin: '5 5 5 5'
                },
                {
                    columnWidth: .33,
                    xtype: 'combobox',
                    fieldLabel: '完成状态',
                    name: 'completeState',
                    id: 'completeState',
                    allowBlank: true,
                    editable: false,
                    multiSelect: false,
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
                    name: 'isFinished',
                    id: 'isFinished',
                    queryMode: 'local', //本地数据
                    editable: false,
                    value: '',
                    store: Ext.create("Ext.data.Store", {
                        fields: ["id", "name"],
                        data: [
                            { "id": "0", "name": "未完成" },
                            { "id": "1", "name": "已完成" }
                        ]
                    }),
                    valueField: 'id',
                    displayField: 'name',
                    margin: '5 5 5 5',
                    allowBlank: true
                },
                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    margin: '5 5 5 5',
                    fieldLabel: '收件人',
                    name: 'customer',
                    allowBlank: true
                }
                ,
                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    margin: '5 5 5 5',
                    fieldLabel: '收货地址',
                    name: 'address',
                    allowBlank: true
                }
                ,
                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    margin: '5 5 5 5',
                    fieldLabel: '收件手机',
                    name: 'mobileNo',
                    allowBlank: true
                }
                ,

                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    margin: '5 5 5 5',
                    fieldLabel: '收件电话',
                    name: 'phoneNo',
                    allowBlank: true
                }
                ,
                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    margin: '5 5 5 5',
                    fieldLabel: '货品名称',
                    name: 'goodsName',
                    allowBlank: true
                }
                ,
                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    margin: '5 5 5 5',
                    fieldLabel: '备注',
                    name: 'remark1',
                    allowBlank: true
                }
                ,
                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    margin: '5 5 5 5',
                    fieldLabel: '箱数目',
                    name: 'boxNum',
                    regex: /^(([1-9]\d{0,9})|0)?$/, //email格式验证
                    regexText: "不是有效数目",
                    allowBlank: true
                }
                ,
                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    margin: '5 5 5 5',
                    fieldLabel: '包数目',
                    name: 'packageNum',
                    regex: /^(([1-9]\d{0,9})|0)?$/, //email格式验证
                    regexText: "不是有效数目",
                    allowBlank: true
                }
                ,
                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    margin: '5 5 5 5',
                    fieldLabel: '其他数目',
                    name: 'otherNum',
                    regex: /^(([1-9]\d{0,9})|0)?$/, //email格式验证
                    regexText: "不是有效数目",
                    allowBlank: true
                }
                ,
                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    margin: '5 5 5 5',
                    fieldLabel: '体积',
                    name: 'volume',
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
                    name: 'weight',
                    allowBlank: true
                },
                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    margin: '5 5 5 5',
                    fieldLabel: '应收款',
                    regex: /^(([1-9]\d{0,9})|0)(\.\d{1,2})?$/, //email格式验证
                    regexText: "不是有效金额",
                    name: 'receivable',
                    allowBlank: true
                }
                ,
                {
                    columnWidth: .33,
                    xtype: 'textfield',
                    margin: '5 5 5 5',
                    fieldLabel: '价值',
                    regex: /^(([1-9]\d{0,9})|0)(\.\d{1,2})?$/, //email格式验证
                    regexText: "不是有效金额",
                    name: 'cost',
                    allowBlank: true
                }
                ,
                {
                    columnWidth: .25,
                    xtype: 'datetimefield',
                    name: 'wareEnterDate',
                    id: 'wareEnterDate',
                    margin: '5 5 5 5',
                    format: 'Y-m-d H:i:s',
                    editable: false,
                    labelStyle: 'width:100',
                    fieldLabel: '库房入库日期'
                } ,
                {
                    columnWidth: .25,
                    xtype: 'datetimefield',
                    name: 'wareLeaveDate',
                    id: 'wareLeaveDate',
                    margin: '5 5 5 5',
                    format: 'Y-m-d H:i:s',
                    editable: false,
                    labelStyle: 'width:100',
                    fieldLabel: '库房出库日期'
                } ,
                {
                    columnWidth: .25,
                    xtype: 'datetimefield',
                    name: 'stationEnterDate',
                    id: 'stationEnterDate',
                    margin: '5 5 5 5',
                    format: 'Y-m-d H:i:s',
                    editable: false,
                    labelStyle: 'width:100',
                    fieldLabel: '站点入库日期'
                } ,
                {
                    columnWidth: .25,
                    xtype: 'datetimefield',
                    name: 'stationLeaveDate',
                    id: 'stationLeaveDate',
                    margin: '5 5 5 5',
                    format: 'Y-m-d H:i:s',
                    editable: false,
                    labelStyle: 'width:100',
                    fieldLabel: '站点出库日期'
                } ,
                {
                    columnWidth: .25,
                    xtype: 'datetimefield',
                    name: 'deployEnterDate',
                    id: 'deployEnterDate',
                    margin: '5 5 5 5',
                    format: 'Y-m-d H:i:s',
                    editable: false,
                    labelStyle: 'width:100',
                    fieldLabel: '直调入库日期'
                } ,
                {
                    columnWidth: .25,
                    xtype: 'datetimefield',
                    name: 'deployLeaveDate',
                    id: 'bdeployLeaveDate',
                    margin: '5 5 5 5',
                    format: 'Y-m-d H:i:s',
                    editable: false,
                    labelStyle: 'width:100',
                    fieldLabel: '直调出库日期'
                }
            ],
            buttonAlign:'center',
            buttons:[
                {
                    iconCls:'acceptIcon',
                    text:'提交',
                    handler:function () {
                        var id = Ext.getCmp('id').value
                            if(id == undefined||id ==null || id == ''){
                                Ext.MessageBox.show({title:'警告:', msg:'数据未加载成功不能提交!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                return
                            }
                        var myMask1 = new Ext.LoadMask(Ext.getBody(), {
                            msg:'正在提交，请稍后！',
                            removeMask:true
                        });
                        if(orderForm.form.isValid()){
                            myMask1.show();
                            orderForm.form.submit({
                                url:'<g:createLink action="saveOrder"/>',
                                success:function (form, action) {
                                    myMask1.hide();
                                    Ext.MessageBox.show({title:'提示:',msg:action.result.alertMsg , width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                    orderForm.form.reset();//清空表单
                                    Ext.getCmp('id').setValue('')
                                },
                                failure:function (form, action) {
                                    myMask1.hide();
                                    Ext.MessageBox.show({title:'提示:',msg:action.result.alertMsg , width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                }
                            });
                        }else{
                            Ext.MessageBox.show({title:'警告:', msg:'必须填写数据!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                            return false;
                            myMask1.hide();
                        }
                    }
                },{
                    text:'清空',
                    iconCls:'deleteIcon',
                    handler:function () {
                        orderForm.form.reset();//清空表单
                        orderDeliveryForm.form.reset();//清空表单
                        Ext.getCmp('id').setValue('')
                    }
                }
            ]
        });

        //主框架
        var tabs = Ext.createWidget('tabpanel', {
            activeTab: 0,
            width:document.body.clientWidth,
            renderTo: Ext.getBody(),
            autoHeight:true,
            margin: '0 0 4 0',
            defaults :{
                bodyPadding: 10,
                closable: false
            },
            items: [{
                title: '订单修改',
                xtype: 'container',
                anchor: '100%',
                items: [
                    searchForm,
                    orderForm
                ]
            }
            ]
        });
        tabs.show()

         //数据加载
        function loadDate(freightNo){
            orderForm.form.load({
                waitMsg:'正在加载订单基础数据请稍后......', //提示信息
                waitTitle:'提示', //标题
                url:'<g:createLink action="searchOrder"/>',
                params:{freightNo:freightNo},
                method:'POST', //请求方式
                failure:function (form, action) {//加载失败的处理函数
                    Ext.MessageBox.show({title:'提示:', msg:'数据加载失败!没有该订单信息！', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                    return false;
                }, success:function (form, action) {
                    if (action.result.data.company == null) {
                        Ext.getCmp("company").setValue("");
                    } else {
                        Ext.getCmp("company").setValue(action.result.data.company.id);
                    }
                    if (action.result.data.targetStation == null) {
                        Ext.getCmp("targetStation").setValue("");
                    } else {
                        Ext.getCmp("targetStation").setValue(action.result.data.targetStation.id);
                    }
                    if (action.result.data.initialStation == null) {
                        Ext.getCmp("initialStation").setValue("");
                    } else {
                        Ext.getCmp("initialStation").setValue(action.result.data.initialStation.id);
                    }

                    for(i = 0 ;i<completeStateData.length ; i++){
                        if(completeStateData[i][1]==action.result.data.completeState.toString()){
                            Ext.getCmp("completeState").setRawValue(completeStateData[i][0]);
                            Ext.getCmp("completeState").setValue(completeStateData[i][0]);
                        }
                    }
                    for(i = 0 ;i<orderStateData.length ; i++){
                        if(orderStateData[i][1]==action.result.data.orderState.toString()){
                            Ext.getCmp("orderState").setRawValue(orderStateData[i][0]);
                            Ext.getCmp("orderState").setValue(orderStateData[i][0]);
                        }
                    }
                    for(i = 0 ;i<orderTypeData.length ; i++){
                        if(orderTypeData[i][1]==action.result.data.orderType.toString()){
                            Ext.getCmp("orderType").setRawValue(orderTypeData[i][0]);
                            Ext.getCmp("orderType").setValue(orderTypeData[i][0]);
                        }
                    }


                }
            });

        };

    });
</script>
</head>
<body>

</body>
</html>
<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2015-03-13
  Time: 11:18
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
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
    font-size: 28px;
}
</style>
<script type="text/javascript">

    Ext.onReady(function () {
        Ext.tip.QuickTipManager.init();
        var searchForm = Ext.create('Ext.form.Panel',{
            autoHeight:true,
            border:0,
            frame : true,
            width:document.body.clientWidth-22,
            style:"margin-left: 2;margin-top:8;margin-bottom:8",
            defaultType: 'textfield',
            title:'输入订单号',
            id:'searchForm',
            items:[
                {
                    style:"margin-left: 60;margin-top:20;",
                    labelStyle: 'font-size:26px;line-height:120%;',
                    fieldStyle: 'font-size:32px;line-height:120%;',
                    height:40,
                    width:460,
                    xtype:'textfield',
                    fieldLabel:'订单号',
                    id:'freightNoInfo',
                    listeners:{
                        specialkey:function (field, e) {
                            if(e.getKey() == Ext.EventObject.ENTER){
                                var freightNo = Ext.getCmp('freightNoInfo').value;
                                if(freightNo.length < 4){
                                    Ext.MessageBox.show({title:'提示:', msg:'请检查订单输入长度!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                    return false;
                                }
                                loadDate(freightNo);
                            }
                        }
                    }
                }
            ]
        });
        //新增,修改form
        var orderForm = new Ext.FormPanel({
            //collapsible : true,// 是否可以展开
            frame: true,
            style:"margin-left: 2;margin-top:8;margin-bottom:8",
            autoScroll: true,
            width:document.body.clientWidth-20,
            autoWidth: true,
            autoHeight: true,
            //reader : _jsonFormReader,
            defaultType: 'textfield',
            layout: 'column',
            items: [

                {
                    fieldLabel: 'id',
                    name: 'id',
                    id: 'id',
                    hidden: true,
                    hideLabel: true,
                    allowBlank: true
                },
                {   columnWidth: .99,
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
                            readOnly:true
                        }
                        ,
                        {
                            columnWidth: 0.5,
                            xtype: 'textfield',
                            margin: '5 5 5 5',
                            fieldLabel: '运单类型',
                            name: 'orderType',
                            readOnly:true
                        }
                        ,
                        {
                            columnWidth: 0.5,
                            xtype: 'textfield',
                            margin: '5 5 5 5',
                            fieldLabel: '公司',
                            name: 'company',
                            id: 'company',
                            readOnly:true
                        }
                        ,
                        {
                            columnWidth: 0.5,
                            xtype: 'textfield',
                            margin: '5 5 5 5',
                            fieldLabel: '出发站点',
                            id: 'initialStation',
                            name: 'initialStation',
                            readOnly:true
                        }
                        ,
                        {
                            columnWidth: 0.5,
                            xtype: 'textfield',
                            margin: '5 5 5 5',
                            fieldLabel: '目标站点',
                            id: 'targetStation',
                            name: 'targetStation',
                            readOnly:true
                        }
                        ,
                        {
                            columnWidth: 0.5,
                            xtype: 'textfield',
                            margin: '5 5 5 5',
                            fieldLabel: '收货店铺代码',
                            name: 'customerCode',
                            readOnly:true
                        },
                        {
                            columnWidth: 0.99,
                            xtype: 'textfield',
                            margin: '5 5 5 5',
                            fieldLabel: '异常原因',
                            name: 'abnormalReasion',
                            id: 'abnormalReasion',
                            readOnly:true
                        }
//                            ,
//                            {
//                                columnWidth: 0.5,
//                                xtype: 'textfield',
//                                margin: '5 5 5 5',
//                                fieldLabel: '收货人',
//                                name: 'customer',
//                                allowBlank: true
//                            }
//                            ,
//                            {
//                                columnWidth: 0.5,
//                                xtype: 'textfield',
//                                margin: '5 5 5 5',
//                                fieldLabel: '收货人电话',
//                                name: 'phoneNo',
//                                allowBlank: true
//                            }
//                            ,
//                            {
//                                columnWidth: 1,
//                                xtype: 'textfield',
//                                margin: '5 5 5 5',
//                                fieldLabel: '收货地址',
//                                name: 'address',
//                                allowBlank: true
//                            }
//                            ,
//                            {
//                                columnWidth: 0.5,
//                                xtype: 'textfield',
//                                margin: '5 5 5 5',
//                                fieldLabel: '货品名称',
//                                name: 'goodsName',
//                                allowBlank: true
//                            }
//                            ,
//                            {
//                                columnWidth: 0.5,
//                                xtype: 'textfield',
//                                margin: '5 5 5 5',
//                                fieldLabel: '发货城市',
//                                name: 'startCity',
//                                allowBlank: true
//                            }
//                            ,
//                            {
//                                columnWidth: 0.5,
//                                xtype: 'textfield',
//                                margin: '5 5 5 5',
//                                fieldLabel: '收货城市',
//                                name: 'endCity',
//                                allowBlank: true
//                            },
//                            {
//                                columnWidth: 0.5,
//                                xtype: 'textfield',
//                                margin: '5 5 5 5',
//                                fieldLabel: '货品重量',
//                                name: 'weight',
//                                allowBlank: true
//                            }
//                            ,
//                            {
//                                columnWidth: 0.5,
//                                xtype: 'textfield',
//                                margin: '5 5 5 5',
//                                fieldLabel: '货品体积',
//                                name: 'volume',
//                                allowBlank: true
//                            }
//                            ,
//                            {
//                                columnWidth: 0.5,
//                                xtype: 'textfield',
//                                margin: '5 5 5 5',
//                                fieldLabel: '是否补全',
//                                id: 'isComplete',
//                                name: 'isComplete',
//                                allowBlank: true
//                            }
//                            ,
//                            {
//                                columnWidth: 0.5,
//                                xtype: 'textfield',
//                                margin: '5 5 5 5',
//                                fieldLabel: '应收款',
//                                name: 'receivable',
//                                allowBlank: true
//                            }
//                            ,
//
//                            {
//                                columnWidth: 0.5,
//                                xtype: 'textfield',
//                                margin: '5 5 5 5',
//                                fieldLabel: '包数量',
//                                name: 'boxNum',
//                                allowBlank: true
//                            }
//                            ,
//                            {
//                                columnWidth: 0.5,
//                                xtype: 'textfield',
//                                margin: '5 5 5 5',
//                                fieldLabel: '箱数量',
//                                name: 'packageNum',
//                                allowBlank: true
//                            }
//                            ,
//                            {
//                                columnWidth: 0.5,
//                                xtype: 'textfield',
//                                margin: '5 5 5 5',
//                                fieldLabel: '其他数量',
//                                name: 'otherNum',
//                                allowBlank: true
//                            }
                    ]},
                {
                    columnWidth: 0.99,
                    xtype: 'textarea',
                    margin: '5 5 5 5',
                    fieldLabel: '处理描述',
                    name: 'remark2',
                    id: 'remark2',
                    grow      : true,
                    anchor    : '100%'
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
                        var remark2 = Ext.getCmp('remark2').value
                        if(remark2 == undefined||remark2 ==null || remark2 == ''){
                            Ext.MessageBox.show({title:'警告:', msg:'提报异常，必须填写异常原因!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
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
                        Ext.getCmp('abnormalReasion').setValue('')
                    }
                }
            ]

        });
        //主框架
        var tabs = Ext.createWidget('tabpanel', {
            activeTab: 0,
            width:document.body.clientWidth-14,
            renderTo: Ext.getBody(),
            autoHeight:true,
            margin: '0 0 4 0',
            defaults :{
                bodyPadding: 10,
                closable: false
            },
            items: [{
                title: '处理异常',
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
                    if(action.result.alertMsg){
                        Ext.MessageBox.show({title:'提示:', msg:action.result.alertMsg, width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});

                    }else{
                        Ext.MessageBox.show({title:'提示:', msg:'数据加载失败!没有该订单信息！', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});

                    }
                    return false;
                }, success:function (form, action) {
                }
            });

        };
    });
</script>
</head>

<body>

</body>
</html>
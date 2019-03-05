<%--
  Created by IntelliJ IDEA.
  User: hww
  Date: 12-5-18
  Time: 下午9:19
  To change this template use File | Settings | File Templates.
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

            var g_speaker;
            try {
                if (!g_speaker) {
                    g_speaker = new ActiveXObject("Sapi.SpVoice");
                }
            } catch (e) {
                Ext.MessageBox.show({
                    title: '注意:',
                    msg: '初始化语音模块失败!' + e,
                    width: 300,
                    buttons: Ext.MessageBox.OK,
                    icon: Ext.MessageBox.ERROR
                });
                g_speaker = null;
            }

            //数据字段
            var dataFields = [
                'id',
                'freightNo',
                'orderType',
                'posterName',
                'customer',
                'mobileNo',
                'receivable',
                'completeState',
                'payable',
                'companyName',
                'goodsName',
                'address'
            ];

            var columns = [
                {text: "id", width: 98, dataIndex: 'id', hidden: true},
                {text: "订单号", width: 120, dataIndex: 'freightNo', sortable: true, summaryType: 'count'},
                {text: "订单类型", width: 70, dataIndex: 'orderType', sortable: true},
                {text: "公司", width: 120, dataIndex: 'companyName', sortable: true},
                {text: "收件人", width: 70, dataIndex: 'customer', sortable: true},
//            {text: "快递员", width: 70, dataIndex: 'posterName', sortable: true},
                {text: "完成状态", width: 75, dataIndex: 'completeState', sortable: true},
                {
                    text: "应收金额",
                    width: 75,
                    dataIndex: 'receivable',
                    sortable: true,
                    summaryType: 'sum',
                    summaryRenderer: function (value, summaryData, dataIndex) {
                        return formatCurrency(value);
                    }
                },
//            {text: "应退金额", width: 75, dataIndex: 'payable', sortable: true, summaryType: 'sum', summaryRenderer: function (value, summaryData, dataIndex) {
//                return formatCurrency(value);
//            }},
                {
                    text: "地址",
                    flex: 1,
                    dataIndex: 'address',
                    sortable: true,
                    renderer: function (value, metaData, record, colIndex, store, view) {
                        metaData.tdAttr = 'data-qtip="' + value + '"';
                        return value;
                    }
                },
                {text: "商品名", width: 150, dataIndex: 'goodsName', sortable: true}
            ]

            var inScanningStore = Ext.create('Ext.data.Store', {
                fields: dataFields,
                idProperty: 'id',
                autoLoad: false
            });

            var otherAcceptScanningStore = Ext.create('Ext.data.Store', {
                fields: dataFields,
                idProperty: 'id',
                autoLoad: false
            });

            var inGrid = Ext.create('Ext.grid.Panel', {
                columns: [
                    Ext.create('Ext.grid.RowNumberer', {header: 'NO', width: 28}),
                    columns
                ],
                store: inScanningStore,
                margin: '2 2',
                columnLines: true,
                height: document.body.clientHeight - 200,
                width: document.body.clientWidth - 40,
                buttonAlign: 'center',
                features: [
                    {
                        ftype: 'summary'
                    }
                ],
                listeners: {
                    scrollershow: function (scroller) {
                        if (scroller && scroller.scrollEl) {
                            scroller.clearManagedListeners();
                            scroller.mon(scroller.scrollEl, 'scroll', scroller.onElScroll, scroller);
                        }
                    }
                },
                buttons: [
                    {
                        text: '提交妥投',
                        iconCls: 'acceptIcon',
                        handler: function () {
                            var count = inScanningStore.count();
                            if (count < 1) {
                                Ext.MessageBox.show({
                                    title: '提示:',
                                    msg: "已扫描订单0条，请扫描后再提交!",
                                    width: 300,
                                    buttons: Ext.MessageBox.OK,
                                    icon: Ext.MessageBox.ERROR
                                });
                            } else {
                                Ext.MessageBox.confirm('操作', "有【" + count + "】条记录将妥投，确认请交？", function (btn) {
                                    if (btn == "yes") {
                                        var myMask = new Ext.LoadMask(Ext.getBody(), {
                                            msg: '正在保存，请稍后！',
                                            removeMask: true
                                        });
                                        myMask.show();

                                        var ids = new Array();
                                        inScanningStore.each(function (record) {
                                            ids.push(record.get("id"))
                                        });

                                        Ext.Ajax.request({
                                            url: '<g:createLink action="saveFinishd"/>',
                                            params: {ids: ids.join(',')},
                                            timeout: 180000,
                                            success: function (r) {
                                                myMask.hide();
                                                var result = Ext.JSON.decode(r.responseText);
                                                if (result.success) {
                                                    Ext.MessageBox.show({
                                                        title: '提示:',
                                                        msg: "妥投提交成功!",
                                                        width: 300,
                                                        buttons: Ext.MessageBox.OK,
                                                        icon: Ext.MessageBox.INFO
                                                    });
                                                    inScanningStore.removeAll();
                                                } else {
                                                    Ext.MessageBox.show({
                                                        title: '提示:',
                                                        msg: "妥投提交失败，请重试!",
                                                        width: 300,
                                                        buttons: Ext.MessageBox.OK,
                                                        icon: Ext.MessageBox.ERROR
                                                    });
                                                }
                                            },
                                            failure: function (r) {
                                                myMask.hide();
                                                Ext.MessageBox.show({
                                                    title: '提示:',
                                                    msg: "妥投已收款失败，请重试!",
                                                    width: 300,
                                                    buttons: Ext.MessageBox.OK,
                                                    icon: Ext.MessageBox.ERROR
                                                });
                                            }
                                        });
                                    }
                                });
                            }
                        }
                    },
                    {
                        text: '删除',
                        iconCls: 'edit1Icon',
                        handler: function () {
                            var selection = inGrid.selModel.getSelection();
                            if (selection == undefined || selection == null || selection == "") {
                                Ext.MessageBox.show({
                                    title: '提示:',
                                    msg: '必须选择一条记录!',
                                    width: 300,
                                    buttons: Ext.MessageBox.OK,
                                    icon: Ext.MessageBox.ERROR
                                });
                            } else {
                                inScanningStore.remove(selection[0])
                            }
                        }
                    },
                    {
                        text: '清空列表',
                        iconCls: 'deleteIcon',
                        handler: function () {
                            Ext.MessageBox.confirm('操作', "确认清空数据？", function (btn) {
                                if (btn == "yes") {
                                    inScanningStore.removeAll();
                                }
                            });
                        }
                    }
                ],
                title: '已扫描订单'
            })

            var otherAcceptInfoForm = new Ext.FormPanel({
                //collapsible : true,// 是否可以展开
                labelWidth: 120, // label settings here cascade unless overridden
                frame: true,
                waitMsgTarget: true,
                //reader : _jsonFormReader,
                width: '100%',
                style: "border:0px solid #000;",
                defaultType: 'textfield',
                items: [

                    {
                        fieldLabel: '收件人姓名',
                        name: 'acceptor',
                        id: "acceptor",
                        allowBlank: false
                    }
                ]
            });

            var panel = Ext.create('Ext.panel.Panel', {
                height: document.body.clientHeight - 15,
                width: document.body.clientWidth - 10,
                bodyPadding: 4,
                style: 'margin: 4',
                layout: {
                    type: 'column'
                },
                renderTo: Ext.getBody(),
                items: [
                    {
                        xtype: 'tabpanel',
                        activeTab: 0, // first tab initially active
                        width: document.body.clientWidth - 30,
                        bodyPadding: 10,
                        margin: '4 6',
                        height: 158,
                        items: [
                            {
                                xtype: 'panel',
                                title: '输入订单',
                                height: 175,
                                width: 380,
                                layout: {
                                    type: 'table',
                                    columns: 2
                                },
                                items: [
                                    {
                                        fieldLabel: '单号',
                                        style: 'font-size: 28px;',
                                        height: 58,
                                        width: 420,
                                        xtype: 'textfield',
                                        name: 'freightNo',
                                        labelStyle: 'font-size:32px;line-height:100%;padding-right:3px;',
                                        fieldStyle: 'font-size:42px;line-height:100%;',
                                        id: 'freightNo2',
                                        listeners: {
                                            specialkey: function (field, e) {
                                                if (e.getKey() == Ext.EventObject.ENTER) {
                                                    inScanningStore.removeAll();
                                                    var freightNo = Ext.getCmp('freightNo2').getValue();
                                                    var tag = true;
                                                    if (freightNo.length <= 4) {
                                                        tag = false;
                                                    }

                                                    if (tag) {
                                                        var myMask = new Ext.LoadMask(Ext.getBody(), {
                                                            msg: '正在保存，请稍后！',
                                                            removeMask: true
                                                        });
                                                        myMask.show();
                                                        this.setDisabled(true)

                                                        Ext.Ajax.request({
                                                            url: '<g:createLink action="scanningOrder"/>',
                                                            params: {freightNo: freightNo},
                                                            success: function (r) {
                                                                myMask.hide();
                                                                Ext.getCmp('freightNo2').setValue("");
                                                                Ext.getCmp("freightNo2").setDisabled(false)
                                                                Ext.getCmp("freightNo2").focus();
                                                                var result = Ext.JSON.decode(r.responseText);
                                                                if (result.success) {
                                                                    try {
                                                                        g_speaker.Speak("成功", 1);
                                                                    } catch (e) {
                                                                    }
                                                                    Ext.getCmp("resultInfo2").removeCls("resultError");
                                                                    Ext.getCmp("resultInfo2").setText("结果：" + result.alertMsg);

                                                                    otherAcceptScanningStore.removeAll();
                                                                    var otherAcceptSubmitWin
                                                                    if (!otherAcceptSubmitWin) {
                                                                        otherAcceptSubmitWin = Ext.create('Ext.window.Window', {
                                                                            title: '非本人签收提交妥投',
                                                                            height: 450,
                                                                            width: 1000,
                                                                            closable: true,
                                                                            draggable: false,
                                                                            resizable: false,
                                                                            modal: true,
                                                                            closeAction: 'hide',
                                                                            layout: 'fit',
                                                                            items: [
                                                                                {
                                                                                    baseCls: "x-plain",
                                                                                    layout: "column",
                                                                                    bodyStyle: "padding-top: 15px; padding-left:10px;padding-right:10px;",
                                                                                    items: [
                                                                                        {
                                                                                            columnWidth: 1,
                                                                                            html: '<div style="text-align:center;font-size: 15;color: #3366ff;">查询到的订单信息</div>'
                                                                                        },
                                                                                        {
                                                                                            columnWidth: 1,
                                                                                            height: 120,
                                                                                            style: "padding-top: 15px;",
                                                                                            xtype: 'grid',
                                                                                            autoFill: false,
                                                                                            store: otherAcceptScanningStore,
                                                                                            columns: columns,
                                                                                            columnLines: true,
                                                                                            multiSelect: true

                                                                                        },
                                                                                        {
                                                                                            columnWidth: 1,
                                                                                            layout: 'column',
                                                                                            style: "padding-top: 10px;",
                                                                                            items: [
                                                                                                otherAcceptInfoForm
                                                                                            ]

                                                                                        }

                                                                                    ]
                                                                                }
                                                                            ],
                                                                            buttonAlign: 'center',
                                                                            listeners: {
                                                                                "hide": function () {
                                                                                    otherAcceptScanningStore.removeAll();
                                                                                    otherAcceptInfoForm.form.reset();
                                                                                }
                                                                            },
                                                                            buttons: [
                                                                                {
                                                                                    text: '提交妥投',
                                                                                    iconCls: 'acceptIcon',
                                                                                    handler: function () {
                                                                                        if (otherAcceptInfoForm.form.isValid()) {
                                                                                            var count = otherAcceptScanningStore.count();
                                                                                            if (count < 1) {
                                                                                                Ext.MessageBox.show({
                                                                                                    title: '提示:',
                                                                                                    msg: "已扫描订单0条，请扫描后再提交!",
                                                                                                    width: 300,
                                                                                                    buttons: Ext.MessageBox.OK,
                                                                                                    icon: Ext.MessageBox.ERROR
                                                                                                });
                                                                                            } else if (count > 1) {
                                                                                                Ext.MessageBox.show({
                                                                                                    title: '提示:',
                                                                                                    msg: "非本人签收提交妥投每次只能提交一条数据!",
                                                                                                    width: 300,
                                                                                                    buttons: Ext.MessageBox.OK,
                                                                                                    icon: Ext.MessageBox.ERROR
                                                                                                });
                                                                                            } else {
                                                                                                Ext.MessageBox.confirm('操作', "确定提交妥投？", function (btn) {
                                                                                                    if (btn == "yes") {
                                                                                                        var myMask = new Ext.LoadMask(Ext.getBody(), {
                                                                                                            msg: '正在保存，请稍后！',
                                                                                                            removeMask: true
                                                                                                        });
                                                                                                        myMask.show();

                                                                                                        var ids = new Array();
                                                                                                        otherAcceptScanningStore.each(function (record) {
                                                                                                            ids.push(record.get("id"))
                                                                                                        });

                                                                                                        Ext.Ajax.request({
                                                                                                            url: '<g:createLink action="otherAcceptSaveFinishCollected"/>',
                                                                                                            params: {
                                                                                                                ids: ids.join(','),
                                                                                                                acceptor: Ext.getCmp("acceptor").getValue()
                                                                                                            },
                                                                                                            timeout: 180000,
                                                                                                            success: function (r) {
                                                                                                                myMask.hide();
                                                                                                                var result = Ext.JSON.decode(r.responseText);
                                                                                                                if (result.success) {
                                                                                                                    otherAcceptSubmitWin.hide();
                                                                                                                    Ext.MessageBox.show({
                                                                                                                        title: '提示:',
                                                                                                                        msg: "妥投保存成功!",
                                                                                                                        width: 300,
                                                                                                                        buttons: Ext.MessageBox.OK,
                                                                                                                        icon: Ext.MessageBox.INFO
                                                                                                                    });
                                                                                                                    otherAcceptScanningStore.removeAll();
                                                                                                                } else {
                                                                                                                    Ext.MessageBox.show({
                                                                                                                        title: '提示:',
                                                                                                                        msg: "妥投失败，请重试!",
                                                                                                                        width: 300,
                                                                                                                        buttons: Ext.MessageBox.OK,
                                                                                                                        icon: Ext.MessageBox.ERROR
                                                                                                                    });
                                                                                                                }
                                                                                                            },
                                                                                                            failure: function (r) {
                                                                                                                myMask.hide();
                                                                                                                Ext.MessageBox.show({
                                                                                                                    title: '提示:',
                                                                                                                    msg: "妥投失败，请重试!",
                                                                                                                    width: 300,
                                                                                                                    buttons: Ext.MessageBox.OK,
                                                                                                                    icon: Ext.MessageBox.ERROR
                                                                                                                });
                                                                                                            }
                                                                                                        });
                                                                                                    }
                                                                                                });
                                                                                            }
                                                                                        } else {
                                                                                            Ext.MessageBox.show({
                                                                                                title: '提示:',
                                                                                                msg: '请填写完成再提交!',
                                                                                                width: 300,
                                                                                                buttons: Ext.MessageBox.OK,
                                                                                                icon: Ext.MessageBox.ERROR
                                                                                            });
                                                                                        }
                                                                                    }
                                                                                }
                                                                            ]
                                                                        })
                                                                    }
                                                                    otherAcceptSubmitWin.show();
                                                                    otherAcceptScanningStore.add(result.data);
                                                                } else {
                                                                    try {
                                                                        g_speaker.Speak(result.soundMsg, 1);
                                                                    } catch (e) {
                                                                    }
                                                                    Ext.getCmp("resultInfo2").addCls("resultError");
                                                                    Ext.getCmp("resultInfo2").setText("结果：" + result.alertMsg);
                                                                }
                                                            },
                                                            failure: function (r) {
                                                                myMask.hide();
                                                                Ext.getCmp('freightNo2').setValue("");
                                                                Ext.getCmp("freightNo2").setDisabled(false)
                                                                Ext.getCmp("freightNo2").focus();
                                                                Ext.MessageBox.show({
                                                                    title: '提示:',
                                                                    msg: "妥投扫描失败,请重试!",
                                                                    width: 300,
                                                                    buttons: Ext.MessageBox.OK,
                                                                    icon: Ext.MessageBox.ERROR
                                                                });
                                                            }
                                                        });
                                                    } else {
                                                        Ext.MessageBox.show({
                                                            title: '提示:',
                                                            msg: '请检查运单长度!',
                                                            width: 300,
                                                            buttons: Ext.MessageBox.OK,
                                                            icon: Ext.MessageBox.ERROR
                                                        });
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    {
                                        xtype: 'label',
                                        cls: 'resultError',
                                        id: 'resultInfo2',
                                        html: '结果：',
                                        style: "margin-left:30;font-size:22px;"
                                    }
                                ]
                            },
                            %{--{--}%
                                %{--xtype: 'panel',--}%
                                %{--title: '输入订单',--}%
                                %{--height: 175,--}%
                                %{--width: 380,--}%
                                %{--layout: {--}%
                                    %{--type: 'table',--}%
                                    %{--columns: 2--}%
                                %{--},--}%
                                %{--items: [--}%
                                    %{--{--}%
                                        %{--fieldLabel: '单号',--}%
                                        %{--style: 'font-size: 28px;',--}%
                                        %{--height: 58,--}%
                                        %{--width: 420,--}%
                                        %{--xtype: 'textfield',--}%
                                        %{--name: 'freightNo',--}%
                                        %{--labelStyle: 'font-size:32px;line-height:100%;padding-right:3px;',--}%
                                        %{--fieldStyle: 'font-size:42px;line-height:100%;',--}%
                                        %{--id: 'freightNo',--}%
                                        %{--listeners: {--}%
                                            %{--specialkey: function (field, e) {--}%
                                                %{--if (e.getKey() == Ext.EventObject.ENTER) {--}%
                                                    %{--var freightNo = Ext.getCmp('freightNo').getValue();--}%
                                                    %{--var tag = true;--}%
                                                    %{--if (freightNo.length <= 4) {--}%
                                                        %{--tag = false;--}%
                                                    %{--}--}%

                                                    %{--if (tag) {--}%
                                                        %{--var myMask = new Ext.LoadMask(Ext.getBody(), {--}%
                                                            %{--msg: '正在保存，请稍后！',--}%
                                                            %{--removeMask: true--}%
                                                        %{--});--}%
                                                        %{--myMask.show();--}%
                                                        %{--this.setDisabled(true)--}%

                                                        %{--Ext.Ajax.request({--}%
                                                            %{--url: '<g:createLink action="scanningOrder"/>',--}%
                                                            %{--params: {freightNo: freightNo},--}%
                                                            %{--success: function (r) {--}%
                                                                %{--myMask.hide();--}%
                                                                %{--Ext.getCmp('freightNo').setValue("");--}%
                                                                %{--Ext.getCmp("freightNo").setDisabled(false)--}%
                                                                %{--Ext.getCmp("freightNo").focus();--}%
                                                                %{--var result = Ext.JSON.decode(r.responseText);--}%
                                                                %{--if (result.success) {--}%
                                                                    %{--try {--}%
                                                                        %{--g_speaker.Speak("成功", 1);--}%
                                                                    %{--} catch (e) {--}%
                                                                    %{--}--}%
                                                                    %{--Ext.getCmp("resultInfo").removeCls("resultError");--}%
                                                                    %{--Ext.getCmp("resultInfo").setText("结果：" + result.alertMsg);--}%
                                                                    %{--var hasFrerihtNo = false--}%
                                                                    %{--inScanningStore.each(function (record) {--}%
                                                                        %{--if (record.get("freightNo") == result.data.freightNo) {--}%
                                                                            %{--hasFrerihtNo = true--}%
                                                                            %{--return;--}%
                                                                        %{--}--}%
                                                                    %{--});--}%
                                                                    %{--if (!hasFrerihtNo)--}%
                                                                        %{--inScanningStore.add(result.data);--}%
                                                                %{--} else {--}%
                                                                    %{--try {--}%
                                                                        %{--g_speaker.Speak(result.soundMsg, 1);--}%
                                                                    %{--} catch (e) {--}%
                                                                    %{--}--}%
                                                                    %{--Ext.getCmp("resultInfo").addCls("resultError");--}%
                                                                    %{--Ext.getCmp("resultInfo").setText("结果：" + result.alertMsg);--}%
                                                                %{--}--}%
                                                            %{--},--}%
                                                            %{--failure: function (r) {--}%
                                                                %{--myMask.hide();--}%
                                                                %{--Ext.getCmp('freightNo').setValue("");--}%
                                                                %{--Ext.getCmp("freightNo").setDisabled(false)--}%
                                                                %{--Ext.getCmp("freightNo").focus();--}%
                                                                %{--Ext.MessageBox.show({--}%
                                                                    %{--title: '提示:',--}%
                                                                    %{--msg: "妥投扫描失败,请重试!",--}%
                                                                    %{--width: 300,--}%
                                                                    %{--buttons: Ext.MessageBox.OK,--}%
                                                                    %{--icon: Ext.MessageBox.ERROR--}%
                                                                %{--});--}%
                                                            %{--}--}%
                                                        %{--});--}%
                                                    %{--} else {--}%
                                                        %{--Ext.MessageBox.show({--}%
                                                            %{--title: '提示:',--}%
                                                            %{--msg: '请检查运单长度!',--}%
                                                            %{--width: 300,--}%
                                                            %{--buttons: Ext.MessageBox.OK,--}%
                                                            %{--icon: Ext.MessageBox.ERROR--}%
                                                        %{--});--}%
                                                    %{--}--}%
                                                %{--}--}%
                                            %{--}--}%
                                        %{--}--}%
                                    %{--},--}%
                                    %{--{--}%
                                        %{--xtype: 'label',--}%
                                        %{--cls: 'resultError',--}%
                                        %{--id: 'resultInfo',--}%
                                        %{--html: '结果：',--}%
                                        %{--style: "margin-left:30;font-size:22px;"--}%
                                    %{--}--}%
                                %{--]--}%
                            %{--},--}%
                            {
                                xtype: 'panel',
                                title: '批量导入',
                                layout: {
                                    type: 'table',
                                    columns: 3
                                },
                                items: [
                                    {
                                        fieldLabel: '批量订单',
                                        xtype: 'textareafield',
                                        width: 350,
                                        height: 110,
                                        autoHeight: true,
                                        name: 'freightNos',
                                        id: 'freightNos',
                                        style: "margin-left: 10",
                                        labelStyle: 'font-size:20px;line-height:100%;padding-right:3px;',
                                        fieldStyle: 'font-size:16px;line-height:100%;',
                                        id: 'freightNos'
                                    },
                                    {
                                        xtype: 'button',
                                        width: 70,
                                        iconCls: 'acceptIcon',
                                        text: '提交',
                                        style: "margin-left:50;margin-top:4;",
                                        handler: function () {
                                            var freightNos = Ext.getCmp('freightNos').value;
                                            var tag = true;
                                            if (freightNos.length <= 4) {
                                                tag = false;
                                            }
                                            if (freightNos.split("\r\n").length > 1000) {
                                                Ext.Msg.alert("信息", "批量订单每次操作不能超过1000条!");
                                                return;
                                            }
                                            if (tag) {
                                                var myMask = new Ext.LoadMask(Ext.getBody(), {
                                                    msg: '正在保存，请稍后！',
                                                    removeMask: true
                                                });
                                                myMask.show();

                                                Ext.Ajax.request({
                                                    url: '<g:createLink action="scanningBathOrder"/>',
                                                    params: {freightNos: freightNos},
                                                    success: function (r) {
                                                        myMask.hide();
                                                        var result = Ext.JSON.decode(r.responseText);
                                                        var succInfos = ''
                                                        var failureInfos = ''
                                                        var m = 0;
                                                        for (var i = 0; i < result.length; i++) {
                                                            if (result[i].success) {
                                                                m++;
                                                                var hasFrerihtNo = false
                                                                inScanningStore.each(function (record) {
                                                                    if (record.get("freightNo") == result[i].data.freightNo) {
                                                                        hasFrerihtNo = true
                                                                        return;
                                                                    }
                                                                });
                                                                if (!hasFrerihtNo)
                                                                    inScanningStore.add(result[i].data);
                                                            } else {
                                                                failureInfos += result[i].alertMsg + "<br/>"
                                                            }
                                                        }
                                                        if (m == result.length) {
                                                            Ext.getCmp("resultSuccInfos").setText("结果：本批妥投扫描成功！");
                                                        } else {
                                                            Ext.MessageBox.show({
                                                                title: '如下错误:',
                                                                msg: failureInfos,
                                                                width: 480,
                                                                buttons: Ext.MessageBox.OK,
                                                                icon: Ext.MessageBox.ERROR
                                                            });
                                                            Ext.getCmp("resultSuccInfos").setText("结果：本批妥投扫描【" + m + "】单成功!【" + eval(result.length - m) + "】单失败!")
                                                        }
                                                    },
                                                    failure: function (r) {
                                                        myMask.hide();
                                                        Ext.MessageBox.show({
                                                            title: '提示:',
                                                            msg: "批量妥投扫描失败,请重试!",
                                                            width: 300,
                                                            buttons: Ext.MessageBox.OK,
                                                            icon: Ext.MessageBox.ERROR
                                                        });
                                                    }
                                                });
                                            } else {
                                                Ext.MessageBox.show({
                                                    title: '提示:',
                                                    msg: '请检查运单号是否正确!',
                                                    width: 300,
                                                    buttons: Ext.MessageBox.OK,
                                                    icon: Ext.MessageBox.ERROR
                                                });
                                            }
                                        }
                                    },
                                    {
                                        xtype: 'label',
                                        cls: 'resultError',
                                        id: 'resultSuccInfos',
                                        html: '结果:',
                                        height: 110,
                                        autoHeight: true,
                                        style: 'margin-left:50;margin-top:4;'
                                    }
                                ]
                            },
                            {
                                xtype: 'panel',
                                title: '查询方式',
                                layout: {
                                    type: 'table',
                                    columns: 4
                                },
                                items: [
                                    {
                                        xtype: 'combobox',
                                        name: 'poster',
                                        id: 'poster',
                                        colspan: 2,
                                        width: 350,
                                        style: "margin-left: 20;margin-top:4;",
                                        editable: true,
                                        queryMode: 'local',
                                        store: new Ext.data.ArrayStore({
                                            fields: ['value', 'text'],
                                            data: Ext.JSON.decode('${params.posters}')
                                        }),
                                        valueField: 'value',
                                        displayField: 'text',
                                        fieldLabel: '投递员'
                                    },
                                    {
                                        fieldLabel: '单号',
                                        style: "margin-left: 20;margin-top:4;",
                                        colspan: 2,
                                        height: 28,
                                        width: 350,
                                        xtype: 'textfield',
                                        name: 'payFreightNo',
                                        id: 'payFreightNo'
                                    },
                                    {
                                        xtype: 'datetimefield',
                                        msgTarget: 'side',
                                        allowBlank: true,
                                        colspan: 2,
                                        style: "margin-left: 20;margin-top:4;",
                                        fieldLabel: '出库开始时间',
                                        format: 'Y-m-d H:i:s',
                                        endDateField: 'endDate',
                                        id: 'startDate',
                                        name: 'startDate',
                                        editable: false,
                                        value: '${startDate}',
                                        height: 28,
                                        width: 350
                                    },
                                    {
                                        fieldLabel: '出库结束时间',
                                        xtype: 'datetimefield',
                                        msgTarget: 'side',
                                        colspan: 2,
                                        allowBlank: true,
                                        style: "margin-left: 20;margin-top:4;",
                                        format: 'Y-m-d H:i:s',
                                        id: 'endDate',
                                        name: 'endDate',
                                        startDateField: 'startDate',
                                        value: '${endDate}',
                                        editable: false,
                                        height: 28,
                                        width: 350
                                    },
                                    {
                                        xtype: 'button',
                                        colspan: 1,
                                        width: 70,
                                        iconCls: 'acceptIcon',
                                        text: '查询',
                                        style: "margin-left: 120;margin-top:4;",
                                        handler: function () {
                                            var startDate = Ext.getCmp('startDate').value;
                                            var endDate = Ext.getCmp('endDate').value;
                                            var poster = Ext.getCmp("poster").getValue();
                                            var freightNo = Ext.getCmp("payFreightNo").getValue();
                                            var params
                                            if (startDate == null && endDate != null) {
                                                params = {
                                                    endDate: Ext.Date.format(endDate, 'Y-m-d H:i:s'),
                                                    poster: poster,
                                                    freightNo: freightNo
                                                };
                                            } else if (startDate != null && endDate == null) {
                                                params = {
                                                    startDate: Ext.Date.format(startDate, 'Y-m-d H:i:s'),
                                                    poster: poster,
                                                    freightNo: freightNo
                                                };
                                            } else if (startDate == null && endDate == null) {
                                                params = {poster: poster, freightNo: freightNo};
                                            } else {
                                                params = {
                                                    startDate: Ext.Date.format(startDate, 'Y-m-d H:i:s'),
                                                    endDate: Ext.Date.format(endDate, 'Y-m-d H:i:s'),
                                                    poster: poster,
                                                    freightNo: freightNo
                                                };
                                            }
                                            var myMask = new Ext.LoadMask(Ext.getBody(), {
                                                msg: '正在查询中，请稍后！',
                                                removeMask: true
                                            });
                                            myMask.show();
                                            Ext.Ajax.request({
                                                url: '<g:createLink action="searchOrder"/>',
                                                params: params,
                                                success: function (r) {
                                                    myMask.hide();
                                                    var result = Ext.JSON.decode(r.responseText);
                                                    inScanningStore.removeAll();
                                                    if (result.success) {
                                                        var hasFrerihtNo = false;
                                                        for (var i = 0; i < result.data.length; i++) {
                                                            inScanningStore.each(function (record) {
                                                                if (record.get("freightNo") == result.data[i].freightNo) {
                                                                    hasFrerihtNo = true;
                                                                    return;
                                                                }
                                                            });
                                                            if (!hasFrerihtNo) {
                                                                inScanningStore.add(result.data[i]);
                                                                hasFrerihtNo = false;
                                                            }
                                                        }
                                                    } else {
                                                        Ext.MessageBox.show({
                                                            title: '提示:',
                                                            msg: "查询妥投失败,请重试!",
                                                            width: 300,
                                                            buttons: Ext.MessageBox.OK,
                                                            icon: Ext.MessageBox.ERROR
                                                        });
                                                    }
                                                },
                                                failure: function (r) {
                                                    myMask.hide();
                                                    Ext.MessageBox.show({
                                                        title: '提示:',
                                                        msg: "查询妥投失败,请重试!",
                                                        width: 300,
                                                        buttons: Ext.MessageBox.OK,
                                                        icon: Ext.MessageBox.ERROR
                                                    });
                                                }
                                            });
                                        }
                                    },
                                    {
                                        xtype: 'button',
                                        colspan: 1,
                                        width: 70,
                                        iconCls: 'acceptIcon',
                                        text: '清空',
                                        style: "margin-left: 40;margin-top:4;",
                                        handler: function () {
                                            Ext.getCmp('startDate').setValue('');
                                            Ext.getCmp('endDate').setValue('');
                                            Ext.getCmp("poster").setValue('');
                                            Ext.getCmp("payFreightNo").setValue('');
                                        }
                                    }
                                ]
                            }

                        ]
                    },
                    {
                        xtype: 'container',
                        layout: 'column',
                        width: document.body.clientWidth - 30,
                        bodyPadding: 10,
                        margin: '4 6',
                        defaults: {
                            layout: 'anchor',
                            defaults: {
                                anchor: '100%'
                            }
                        },
                        items: [
                            {
                                columnWidth: 1,
                                items: [inGrid]
                            }
                        ]
                    }
                ]
            });

            panel.show();

        });
    </script>
</head>

<body>
</body>
</html>
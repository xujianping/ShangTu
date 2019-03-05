<%--
  Created by IntelliJ IDEA.
  User: hww
  Date: 12-7-4
  Time: 下午5:48
  To change this template use File | Settings | File Templates.
--%>

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

            //创建数据源
            var  comboBoxTree = Ext.create("Ext.ux.ComboBoxTree", {
                id:'stationId',
                name:'stationId',
                hiddenName:'stationId',
                storeUrl : '<g:createLink action="station" controller="common" params="[stationId:'',selectType:'NOTSELECT']" />',
                //anchor: '40%',
                fieldLabel : '选择站点',
                editable:false,
                rootId : '0',
                rootText : '操作中心',
                selectClick:true,
                allowBlank:false,
                style:"margin-left: 20",
                anchor: '35%'
            });

            var posterStore = Ext.create('Ext.data.Store', {
                proxy:{
                    type:'ajax',
                    url:'<g:createLink action="getPosterByStation"/>',
                    reader:{
                        type:'json',
                        root:'data'
                    }
                },
                fields:['id', 'posterName'],
                autoLoad:false
            });

            var importForm =  Ext.create('Ext.form.Panel', {
                height: 320,
                autoFill:false,
                autoHeight:true,
                width:document.body.clientWidth-20,
                bodyPadding: 10,
                title: '查询条件',
                renderTo:Ext.getBody(),
                margin:'8 10',
                layout: 'anchor',
                defaultType:'textfield',
                items: [
                       {
                                xtype:'combobox',
                                fieldLabel:'站名',
                                hiddenName:'stationId',
                                style:"margin-left: 20",
                                id:'stationId',
                                height:28,
                                editable:true,
                                anchor: '35%',
                                allowBlank:false,
                                emptyText:'必须选择站点',
                                transform:'stationSelect',
                                listeners:{
                                select:function (combo, record, index) {
                                    var stationId = Ext.getCmp("stationId").value;
                                    if (stationId == "") {
                                        Ext.MessageBox.show({title:"信息", msg:"请先选择站点", buttons:Ext.Msg.OK, icon:Ext.MessageBox.ERROR})
                                        return
                                    }
                                    var posterObj = Ext.getCmp("posterId");
                                    posterObj.clearValue();
                                    posterObj.store.load({params:{stationId:stationId}});
                            }
                        }
                    },
//                    {
//                        xtype: 'combobox',
//                        fieldLabel: '快递员',
//                        hiddenName:'posterId',
//                        id:'posterId',
//                        style:"margin-left: 20;margin-top:10;",
//                        editable:false,
//                        allowBlank:false,
//                        anchor: '35%',
//                        valueField:'id',
//                        displayField:'posterName',
//                        store:posterStore,
//                        listeners:{
//                            "focus":function () {
//                                var stationId = Ext.getCmp("stationId").value;
//                                if (stationId == "") {
//                                    Ext.MessageBox.show({title:"信息", msg:"请先选择站点", buttons:Ext.Msg.OK, icon:Ext.MessageBox.ERROR})
//                                    return
//                                }
//                                var posterObj = Ext.getCmp("posterId");
//                                posterObj.clearValue();
//                                posterObj.store.load({params:{stationId:stationId}});
//                            }
//                        }
//                    },
                    {
                        xtype: 'datetimefield',
                        msgTarget: 'side',
                        allowBlank:false,
                        style:"margin-left: 20;margin-top:10;",
                        fieldLabel: '出库时间',
                        format:'Y-m-d H:i:s',
                        endDateField:'endDate',
                        id:'startDate',
                        name:'startDate',
                        editable:false,
                        value:'${startDate}',
                        anchor: '35%'
                    },
                    {
                        fieldLabel: '结束时间',
                        xtype: 'datetimefield',
                        msgTarget: 'side',
                        allowBlank:false,
                        style:"margin-left: 20;margin-top:10;",
                        format:'Y-m-d H:i:s',
                        id:'endDate',
                        name:'endDate',
                        startDateField:'startDate',
                        value:'${endDate}',
                        editable:false,
                        anchor: '35%'
                    },
                    {
                        xtype: 'button',
                        width:70,
                        iconCls:'printerIcon',
                        text:'打印',
                        style:"margin-left: 120;margin-top:10;",
                        handler:function () {
                            if(importForm.form.isValid()){
                                var values = importForm.form.getValues();
//                                var posterId = Ext.getCmp("posterId").value;
                                window.open('<g:createLink action="print"/>?startDate='+ values['startDate'] +'&endDate=' + values['endDate'])
                            }else{
                                Ext.MessageBox.show({title:'提示:', msg:'请填写正确后再提交!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                            }
                        }
                    }
                ]
            });

            importForm.show();
        });
    </script>
</head>
<body>
<g:select name="stationId" id="stationSelect" from="${stations}" optionKey="id" optionValue="stationName" noSelection="['': '']"/>
</body>
</html>
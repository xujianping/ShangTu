<%@ page import="com.xujp.dj.Company; com.util.enums.StationType; com.xujp.dj.Station" %>
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
            var stationData = [];
            <g:each in="${Station.findAllByStationType(StationType.ST,[sort: 'stationCode'])}">
            stationData.push([${it.id}, '${it.nameAndCode}']);
            </g:each>

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
                        fieldLabel:'站点名',
                        hiddenName:'stationId',
                        name:'stationId',
                        id:'stationId',
                        allowBlank:false,
                        emptyText:'必须选择站点',
                        style:"margin-left: 20;margin-top:10;",
                        queryMode:'local',
                        valueField:'id',
                        displayField:'stationName',
                        store:new Ext.data.ArrayStore({
                            fields:['id', 'stationName'],
                            data:stationData
                        }) ,
                        anchor: '35%'
                    },
                    {
                        xtype: 'combobox',
                        fieldLabel: '公司名',
                        hiddenName:'companyId',
                        style:"margin-left: 20;margin-top:10;",
                        editable:true,
                        allowBlank:true,
                        multiSelect:true,
                        transform:'companySelect',
                        anchor: '35%'
                    },{
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
                                var myMask = new Ext.LoadMask(Ext.getBody(), {
                                    msg:'正在查询，请稍后！',
                                    removeMask:true
                                });
                                myMask.show();
                                var values = importForm.form.getValues();
                                Ext.Ajax.request( {
                                    url:'<g:createLink action="notLeaveCount"/>',
                                    params:values ,
                                    success:function (r) {
                                        var result = Ext.JSON.decode(r.responseText);
                                        myMask.hide();
                                        Ext.MessageBox.confirm('操作', result.alertMsg, function (btn) {
                                            if (btn == "yes") {
                                                window.open('<g:createLink action="print"/>?stationId='+ values['stationId'] +'&companyId='+ values['companyId'] +'&startDate='+ values['startDate'] +'&endDate=' + values['endDate'])
                                            }
                                        });
                                    },
                                    failure:function (r) {
                                        myMask.hide();
                                        Ext.MessageBox.show({title:'提示:', msg:"请选择正确的查询条件重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                    }
                                });

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
<g:select name="companyId" id="companySelect" from="${Company.list([sort: 'companyName'])}" optionKey="id" optionValue="companyName" noSelection="['-1':'全部']"/>
</body>
</html>
<%@ page import="com.util.enums.StationType" %>

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
        var clientHeight = document.body.clientHeight;

        var store = Ext.create('Ext.data.TreeStore', {
            proxy:{
                type:'ajax',
                timeout:30000,
                url:'<g:createLink action="station" controller="common" params="[functionId:'',selectType:'NOTSELECT']" />'
            },
            root:{
                text:'操作中心',
                id:'0',
                expanded:true
            },
            folderSort:true,
            sorters:[
                {
                    property:'id',
                    direction:'ASC'
                }
            ]
        });
        var tree = Ext.create('Ext.tree.Panel', {
            store:store,
            renderTo:Ext.getBody(),
            height:document.body.clientHeight - 30,
            viewConfig:{
                plugins:{
                    ptype:'treeviewdragdrop'
                }
            },
            frame:false,
            useArrows:true
        });

        // 定义右键菜单
        var treeMenu = new Ext.menu.Menu({
            id:'treeMenu',
            floating:true,
            plain:true,
            items:[
                {
                    id:'rMenu1',
                    text:'增加站点',
                    iconCls:'addIcon',
                    handler:function () {
                        var tabHerf = '<g:createLink action="toForm"  params="[opType:'add']" />' + "&parentId=" + currentId
                        parent.Ext.create('widget.window', {
                            title:'增加站点',
                            id:'top_iframe',
                            closable:true,
                            constrain:true,
                            collapsible:false, // 是否可收缩
                            width: 400,
                            height: 300,
                            layout:'fit',
                            maximizable:true, // 设置是否可以最大化
                            iconCls:'imageIcon',
                            bodyStyle:'padding: 5px;',
                            border:true,
                            html:'<iframe scrolling="auto" frameborder="no" border="0" marginwidth="0" marginheight="0" allowtransparency="yes" width="99%" height="99%" src="' + tabHerf + '"></iframe>',
                            listeners:{
                                "close":function () {
                                    store.load();
                                }
                            }
                        }).show();
                    }
                },
                {
                    id:'rMenu2',
                    text:'编辑站点',
                    iconCls:'edit1Icon',
                    handler:function () {
                        var tabHerf = '<g:createLink action="toForm"  params="[opType:'edit']" />' + "&id=" + currentId;
                        parent.Ext.create('widget.window', {
                            title:'编辑站点',
                            id:'top_iframe',
                            closable:true,
                            constrain:true,
                            collapsible:false, // 是否可收缩
                            height:parent.document.body.clientHeight - 50,
                            width:parent.document.body.clientWidth - 50,
                            layout:'fit',
                            maximizable:true, // 设置是否可以最大化
                            iconCls:'imageIcon',
                            bodyStyle:'padding: 5px;',
                            border:true,
                            html:'<iframe scrolling="auto" frameborder="no" border="0" marginwidth="0" marginheight="0" allowtransparency="yes" width="99%" height="99%" src="' + tabHerf + '"></iframe>',
                            listeners:{
                                "close":function () {
                                }
                            }
                        }).show();
                    }
                },
                {
                    id:'rMenu3',
                    text:'删除站点',
                    iconCls:'deleteIcon',
                    hidden:true,
                    handler:function () {
                        if (currentId == undefined || currentId == null || currentId == "") {
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
                                var selectedKey = currentId;
                                Ext.Ajax.request({
                                    url:'<g:createLink action="delete"/>',
                                    params:{ id:selectedKey},
                                    success:function (r) {
                                        var result = Ext.JSON.decode(r.responseText);
                                        if (result.success) {
                                            Ext.MessageBox.show({title:'提示:', msg:'删除信息成功!', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
                                            store.load();
                                        } else {
                                            Ext.MessageBox.show({title:'提示:', msg:result.alertMsg, width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                        }
                                    },
                                    failure:function (r) {
                                        var result = Ext.JSON.decode(r.responseText);
                                        Ext.MessageBox.show({title:'提示:', msg:"删除失败,请重试!", width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
                                        store.load();
                                    }
                                });
                            }
                        });
                    }
                },
                {
                    id:'rMenu4',
                    text:'显示详情',
                    iconCls:'acceptIcon',
                    handler:function () {
                        var tabHerf = '<g:createLink action="toForm"  params="[opType:'show']" />' + "&id=" + currentId;
                        parent.Ext.create('widget.window', {
                            title:'显示详情',
                            id:'top_iframe',
                            closable:true,
                            constrain:true,
                            collapsible:false, // 是否可收缩
                            height:parent.document.body.clientHeight - 50,
                            width:parent.document.body.clientWidth - 50,
                            layout:'fit',
                            maximizable:true, // 设置是否可以最大化
                            iconCls:'imageIcon',
                            bodyStyle:'padding: 5px;',
                            border:true,
                            html:'<iframe scrolling="auto" frameborder="no" border="0" marginwidth="0" marginheight="0" allowtransparency="yes" width="99%" height="99%" src="' + tabHerf + '"></iframe>',
                            listeners:{
                                "close":function () {
                                }
                            }
                        }).show();
                    }
                }
            ]
        });
        var currentId = null;
        tree.addListener('itemcontextmenu', function (groupTree, record, item, index, e) {
            // 声明菜单类型
            e.stopEvent();
            if (record.raw && record.raw.leaf) {
                treeMenu.getComponent('rMenu3').show();
            } else {
                treeMenu.getComponent('rMenu3').hide();
            }
            treeMenu.showAt(e.getXY());
            if (record.get('id'))
                currentId = record.get('id');
            else
                currentId = null;
            return false;
        });
        tree.addListener('itemclick', function (groupTree, record, item, index, e) {
            // 声明菜单类型
            e.stopEvent();
            if (record.raw) {
                if (record.raw.leaf){
                    Ext.getCmp('uploadBtn').show();
                    Ext.getCmp('areaUploadBtn').show();
                }else{
                    Ext.getCmp('uploadBtn').hide();
                    Ext.getCmp('areaUploadBtn').show();
                }
            }
        });



    });
</script>

</head>

<body>
<div id='functionCategoryDiv'></div>

</body>
</html>
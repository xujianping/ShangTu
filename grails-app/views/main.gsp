<html>
<head>
<title><g:message code="sys.name"/></title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="layout" content="ext"/>
<style type="text/css">
.menubar {
    border-bottom: 1px solid #AACCF6;
    color: #222222;
    cursor: pointer;
    display: block;
    padding: 4px 4px 4px 20px !important;

}

.menubar:hover {
    text-decoration: none;
}

A {
    color: #03319a;
    text-decoration: none
}

A:hover {
    color: blue
}
</style>


<script type="text/javascript" defer="defer">

    Ext.require([
        'Ext.grid.*',
        'Ext.data.*',
        'Ext.form.*',
        'Ext.tip.QuickTipManager'
    ]);


    var tabPanel

    /*产生一个新的tab*/
    function targetNewTab(tabText, tabHref) {
        var ifremeHeiht = document.body.clientHeight - 138;
        var tab = tabPanel.getComponent(tabText);
        if (tab) {
            tabPanel.remove(tab);
        }
        tab = tabPanel.add({
            'id':tabText,
            'title':tabText,
            closable:true,
            autoScroll:true,
            html:'<iframe  frameborder="no" border="0" marginwidth="0" marginheight="0" allowtransparency="yes" width="100%" height="' + ifremeHeiht + '" src="' + tabHref + '"></iframe>'
        });
        tabPanel.setActiveTab(tab);
        tabPanel.body.mask('加载页面，请稍候...');
        //加载完毕后清掉加载进度条
        setTimeout("javascript:centerPanelUnmask()", 3000);
    }
    ;

    /*关闭tab*/
    function targetDeleteTab(tabText) {
        var tab = tabPanel.getComponent(tabText);
        if (tab) {
            tabPanel.remove(tab);
        }

        tabPanel.body.mask('加载页面，请稍候...');
        //加载完毕后清掉加载进度条
        setTimeout("javascript:centerPanelUnmask()", 3000);
    }

    function centerPanelUnmask() {
        tabPanel.body.unmask();
    }

    Ext.onReady(function () {
        var mainWidth = document.body.clientWidth - 290;
        var mainPanel = Ext.create('Ext.panel.Panel', {
            width:document.body.clientWidth - 200,
            height:document.body.clientHeight - 148,
            //autoWidth:true,
            x:4,
            y:4,
            layout:'accordion',
            items:[
                {
                    title:'订单信息统计',
                    autoScroll:true
                }
            ]
        });


        tabPanel = Ext.create('Ext.tab.Panel', {
                    activeTab:0, // first tab initially active
                    region:'center',
                    items:[
                        {
                            title:'欢迎页',
                            closable:false,
                            items:[
                                mainPanel
                            ]
                        }
                    ]
                }
        );

        var accrodion = [
            <g:each in="${actions.groupBy{it.groupName}}" var='menuGroup' status="i">
            {
                title:'${menuGroup.key}',
                autoScroll:true,
                html:'<div style="overflow:auto"><ul id="${menuGroup.key}" class="mymenu"><g:each var = "menuItem" in = "${menuGroup.value}"><li class="menubar"><a onclick="targetNewTab(\'${menuItem.title}\',\'<g:createLink controller = "${menuItem.controllerName}" />\');return false;">${menuItem.title}</a></li></g:each></ul></div>',
                iconCls:'settings'
            }<g:if test="${actions.groupBy{it.groupName}.size()!=i+1}">,
            </g:if>
            </g:each>
        ]

        var win = Ext.create('Ext.container.Viewport', {
            title:'Layout Window',
            //animateTarget: this,
            layout:'border',
            bodyStyle:'padding: 5px;',
            items:[
                {
                    region:'north',
                    height:85,
                    autoEl:{
                        tag:'div',
                        // style="background-image:url(${resource(dir:'images',file:'logo.jpg')});width:435px"
                        html:'<table width="100%" height="84" border="0" cellpadding="1" cellspacing="0" style="background:#D2E0F2"><tr><td align="left"> <img src="${resource(dir:'images',file:'logo.png')}" style="height:70px;margin:8px;"  ></td></tr></table>'
                    }
                },
                {
                    region:'south',
                    height:31,
                    autoEl:{
                        tag:'div',
                        html:"<table width='100%' height='31' border='0' cellpadding='0' cellspacing='0' background='${resource(dir:'images',file:'zhuyem_26.gif')}' style='color:#919191; font-size:12px;'><tr><td align='left'>&nbsp;&nbsp;当前用户：【&nbsp; ${user.realname} &nbsp;】&nbsp;,&nbsp;所属机构：【&nbsp;${user.station.stationName}&nbsp;】</td><td align='right'>本系统必须经善途授权使用&nbsp;&nbsp;</td></tr></table>"
                    }
                },
                {
                    region:'west',
                    title:'菜单',
                    width:200,
                    split:true,
                    collapsible:true,
                    animCollapse:true,
                    margins:'0 0 0 5',
                    layout:'accordion',
                    items:[
                        accrodion
                    ],
                    bbar:new Ext.Toolbar({items:[
                        {
                            iconCls:'wrenchIcon',
                            text:'修改密码',
                            handler:function () {
                                var tab = tabPanel.getComponent("modify_pwd");
                                if (tab) {
                                    tabPanel.remove(tab);
                                }
                                tab = tabPanel.add({
                                    id:"modify_pwd",
                                    title:"修改密码",
                                    closable:true,
                                    autoScroll:true, //
                                    html:'<iframe scrolling="auto" frameborder="0" width="99%" height="99%" src="<g:createLink controller="passWordEdit"/>"></iframe>'
                                });
                                tabPanel.setActiveTab(tab);
                            }
                        },
                        '-',
                        {
                            iconCls:'disconnectIcon',
                            text:'退出系统', handler:function () {
                            window.top.location.replace('<g:createLink controller="logout"/>');
                        }
                        }
                    ]
                    })
                },
                {
                    region:'center',
                    items:[tabPanel]
                }
            ]
        });
        win.show();



    });
</script>

</head>

<body>
</body>
</html>
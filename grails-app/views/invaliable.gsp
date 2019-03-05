<%@ page contentType="text/html;charset=UTF-8" %>
<html>
  <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <meta name="layout" content="ext"/>
      <link rel="stylesheet" href="${resource(dir: 'css', file: 'ext_icon.css')}"/>
      <g:javascript src="common.js"></g:javascript>
      <g:javascript src="ext-lang-zh_CN.js"></g:javascript>

      <script type="text/javascript" language="javascript">
          Ext.onReady(function () {
              Ext.tip.QuickTipManager.init();
              Ext.MessageBox.show({title:'不可用', msg:'该功能仅限所属机构为站点的用户使用', width:300, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR
                ,fn:function(){
                    try{
                        var tabText = parent.tabPanel.activeTab.title;
                        var tab = parent.tabPanel.getComponent(tabText);
                        if (tab) {
                            parent.tabPanel.remove(tab);
                        };
                    }catch(e){}
                }
              });
          });
      </script>
  </head>
<body></body>
</html>
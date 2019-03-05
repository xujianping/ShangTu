<!doctype html>
<html>
<head>
    <meta name="layout" content="ext"/>
    <title>Welcome to Grails</title>
    <asset:link rel="icon" href="favicon.ico" type="image/x-ico" />
</head>
<body>
<div>
    <button id="mb1">Show</button>
</div>
<script type="text/javascript">
    Ext.require([
        'Ext.window.MessageBox',
        'Ext.tip.*'
    ]);
    Ext.onReady(function () {
        Ext.get('mb1').on('click', function(e){
            Ext.MessageBox.confirm('Confirm', 'Are you sure you want to do that?');
        });
    });
</script>
</body>
</html>


<html>
<head>
    <title>打印物流单</title>
    <style media="print" type="text/css">
    .Noprint {
        display: none;
        font-family: Arial;
        background-color: #eaf5ff;
    }

    .PageNext {
        page-break-after: always;
    }
    </style>
    <style type="text/css">
    table {
        border: 1px solid #000000; /* 表格边框 */
        border-collapse: collapse; /* 边框重叠 */
        font-size: 13px;
        width: 21cm;
    }

    th {
        height: 30px;
        font-size: 20px;
    }

    tbody tr td {
        border: 1px solid #000000; /* 单元格边框 */
        text-align: center;
        height: 26px;
        padding-bottom: 1px;
        padding-left: 1px;
        padding-right: 1px;
    }

    tfoot tr td {
        height: 28px;
    }
    </style>
    <script type="text/javascript">

    </script>
</head>

<body>
<div class="Noprint">　　
　<OBJECT id="WebBrowser" classid="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2" height="0" widtd="0"></OBJECT>　　
    <input type="button" value="打印" onclick="document.all.WebBrowser.ExecWB(6, 1)"/>　　
    <input type="button" value="直接打印" onclick="document.all.WebBrowser.ExecWB(6, 6)"/>
    <input type="button" value="页面设置" onclick="document.all.WebBrowser.ExecWB(8, 1)"/>　　
    <input type="button" value="打印预览" onclick="document.all.WebBrowser.ExecWB(7, 1)"/>　　
</div>

<div id='printListDiv' style="widtd: 21cm;margin-top:30px;">
    <table>
        <tdead>
            <tr>
                <th colspan="3" align="left">
                    出库站点：${stationName}
                </th>
                <th colspan="2" align="right">
                    物流单
                </th>
                <th colspan="3" align="right">
                    打印日期：<% Date d = new Date(); out.write(d.format("yyyy-MM-dd")) %>
                </th>
            </tr>
        </tdead>
        <tbody>
        <tr>
            <td style="width: 35px"><b>序号</b></td>
            <td style="width: 80px"><b>购物公司</b></td>
            <td style="width: 60px"><b>出库日期</b></td>
            <td style="width: 80px"><b>运单号</b></td>
            <td style="width: 45px"><b>顾客</b></td>
            <td style="width: 30px"><b>件数</b></td>
            <td><b>地址</b></td>
            <td style="width: 70px"><b>类型</b></td>
            <td style="width: 45px"><b>应收款</b></td>
        </tr>
        <%
            def deliverCount = 0
            def exchangeCount = 0
            def refundCount = 0
            def packageCount = 0
            def map = []
        %>
        <g:each in="${values}" var="result" status="num">
            <tr>
                <td>${num + 1}</td>
                <td>${result['companyName']}</td>
                <td>${result['wareLeaveDate'].format("yyyy-MM-dd")}</td>
                <td>${result['freightNo']}</td>
                <td>${result['customer']}</td>
                <td>${result['goodsNum']}</td>
                <td>${result['address']}</td>
                <td>
                    <%
                        out.print result['orderType'].toString()
                    %>
                </td>
                <td>${result['receivable']}</td>
            </tr>
            <%
                if(result['orderType']==com.util.enums.OrderType.DELIVER_ORDER){
                    deliverCount ++
                }
                if(result['orderType']==com.util.enums.OrderType.DEPLOY_ORDER){
                    exchangeCount ++
                }
                if(result['orderType']==com.util.enums.OrderType.HQ_DEPLOY_ORDER){
                    refundCount ++
                }
                if(result['goodsNum']!=null){
                    packageCount += result['goodsNum']
                }
                if(map.indexOf(result['wareLeaveBatchNo']) ==-1){
                   map << result['wareLeaveBatchNo']
                }
            %>
        </g:each>
        </tbody>
        <tfoot>
        <tr>
            <td colspan="2">&nbsp;&nbsp;配送：${deliverCount}</td>
            <td colspan="4" align="right">制表人：<u>${oper}</u></td>
            <td colspan="2" align="left"><u>

            </u></td>
        </tr>
        <tr>
            <td colspan="2">&nbsp;&nbsp;直调：${exchangeCount}</td>
            <td colspan="4" align="right">装箱人签字：</td>
            <td colspan="2" align="left"><u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u>
            </td>
        </tr>
        <tr>
            <td colspan="2">&nbsp;&nbsp;中心直调：${refundCount}</td>
            <td colspan="4" align="right">封箱人签字：</td>
            <td colspan="2" align="left"><u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u>
            </td>
        </tr>
        <tr>
            <td colspan="2">&nbsp;&nbsp;</td>
            <td colspan="4" align="right">司机签字：</td>
            <td colspan="2" align="left"><u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u>
            </td>
        </tr>
        <tr>
            <td colspan="4">总件数:${packageCount}</td>
            <td colspan="2" align="right">发行站签字：</td>
            <td colspan="2" align="left"><u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u>
            </td>
        </tr>
        <tr>
            <td colspan="8">批次号:${map.join(',')}</td>
        </tr>
        </tfoot>
    </table>
</div>
</body>
</html>
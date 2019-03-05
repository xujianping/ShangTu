<%--
  Created by IntelliJ IDEA.
  User: hww
  Date: 12-7-4
  Time: 下午5:50
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>打印配送单</title>
    <style media="print" type="text/css">
    .Noprint{display:none;
        font-family:Arial;
        background-color:#eaf5ff;
    }
    .PageNext{page-break-after:always;}
    </style>
    <style type="text/css">
    table{
        border:1px solid #000000;    /* 表格边框 */
        border-collapse:collapse;    /* 边框重叠 */
        font-size:13px;
        width: 21cm;
    }
    th{
        height: 30px;
        font-size:20px;
    }
    tbody tr td{
        border:1px solid #000000;    /* 单元格边框 */
        text-align:center;
        height: 26px;
        padding-bottom:1px;
        padding-left:1px; padding-right:1px;
    }
    tfoot tr td{
        height: 28px;
    }
    </style>
    <script type="text/javascript">

    </script>
</head>
<body>
<div class="Noprint" >　　
　<OBJECT id="WebBrowser"  classid="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2"  height="0"  widtd="0"></OBJECT>　　
    <input type="button"  value="打印" onclick="document.all.WebBrowser.ExecWB(6,1)" />　　
    <input type="button"   value="直接打印"  onclick="document.all.WebBrowser.ExecWB(6,6)" />
    <input type="button"   value="页面设置"  onclick="document.all.WebBrowser.ExecWB(8,1)" />　　
    <input type="button"   value="打印预览"  onclick="document.all.WebBrowser.ExecWB(7,1)" />　　
</div>
<div id='printListDiv' style="widtd: 21cm;margin-top:30px;">
    <table>
        <tdead>
            <tr>
                <th colspan="5" align="left">
                    配送单
                </th>
                <th colspan="3" align="right">
                    打印日期：<%Date d = new Date();out.write(d.format("yyyy-MM-dd"))%>
                </th>
            </tr>
        </tdead>
        <tbody>
        <tr>
            <td  style="width: 35px"><b>序号</b></td>
            <td  style="width: 70px"><b>上游公司</b></td>
            <td style="width: 60px"><b>出库日期</b></td>
            <td  style="width: 80px"><b>运单号</b></td>
            <td style="width: 35px"><b>收货人</b></td>
            <td  style="width: 45px"><b>电话</b></td>
            <td><b>地址</b></td>
            <td  style="width: 70px"><b>类型</b></td>
            <td  style="width: 45px"><b>应收款</b></td>
        </tr>
        <%
            BigDecimal receivables=BigDecimal.ZERO;
            def deliverCount = 0
            def exchangeCount = 0
            def refundCount = 0
        %>
        <g:each in="${orders}" var="order" status="num">
            <tr>
                <td  >${num+1}</td>
                <td  >${order['companyName']}</td>
                <td  ><g:formatDate date="${order['stationLeaveDate']}" format="yyyy-MM-dd"/> </td>
                <td  >${order['freightNo']}</td>
                <td  >${order['customer']}</td>
                <td  >${order['phoneNo']}</td>
                <td  >${order['address']}</td>
                <td  >${order['orderType']}</td>
                <td  >${order['receivable']}</td>
            </tr>
           <%
               receivables +=order['receivable'];
               if(order['orderType']==com.util.enums.OrderType.DELIVER_ORDER){
                   deliverCount ++
               }
               if(order['orderType']==com.util.enums.OrderType.DEPLOY_ORDER){
                   exchangeCount ++
               }
               if(order['orderType']==com.util.enums.OrderType.HQ_DEPLOY_ORDER){
                   refundCount ++
               }
           %>
        </g:each>
        </tbody>
        <tfoot>
        <tr>
            <th  colspan="3" align="left">&nbsp;&nbsp;直调：${exchangeCount}单</th>
            <th  colspan="3" align="left">&nbsp;&nbsp;中心直调：${refundCount}单</th>
            <th  colspan="4" align="left">&nbsp;&nbsp;配送：${deliverCount}单</th>
        </tr>
        <tr>
            <th  colspan="4" align="left">&nbsp;&nbsp;应收总额：${receivables}&nbsp;元</th>
            <th  colspan="2" align="right">制表人：</th>
            <th  colspan="4" align="left"><u>&nbsp;&nbsp;&nbsp;&nbsp;${oper}&nbsp;&nbsp;&nbsp;&nbsp;</u></th>
        </tr>
        </tfoot>
    </table>
</div>
</body>
</html>
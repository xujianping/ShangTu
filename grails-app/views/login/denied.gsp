<html>
<head>
	<title><g:message code="sys.name"/></title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	<meta name="layout" content="ext"/>
	<style type="text/css">
	<!--
	.STYLE1 {
		color: #CAE9FF;
		font-weight: bold;
	}
	.input_text {
		border-top-width: 1px;
		border-right-width: 1px;
		border-bottom-width: 1px;
		border-left-width: 1px;
		border-top-color: #CCCCCC;
		border-right-color: #CCCCCC;
		border-bottom-color: #CCCCCC;
		border-left-color: #CCCCCC;
		height:20px;
	}
	-->
	</style>
</head>
<body>
<div style="display: none;">

</div>
<table width="100%" height="450" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td align="center" valign="middle">
			<table width="450" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td>
						<table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#C6D5F5">
							<tr>
								<td bgcolor="#3367CB" class="td_head">
									<table width="100%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td width="350">
												<asset:image src="title.gif"  width="349" height="41"/>
											</td>
											<td>
												<span class="STYLE1">错 误 提 示</span>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td bgcolor="#FFFFFF">
									<table width="100%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td width="120" align="center" valign="middle">
												<asset:image src="error_msg.jpg"  width="77" height="77" />
											</td>
											<td>
												<font color="red">您没有相应的操作权限，或登录超时。</font>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td height="40" align="right" bgcolor="#F5F5F5">
									<input type="button" name="Submit" value="重新登陆" onClick="window.top.location.replace('<%String path = request.contextPath;out.write(path)%>/');return false" />
									&nbsp;&nbsp;
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>

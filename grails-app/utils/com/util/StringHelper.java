package com.util;

import org.apache.commons.lang.StringUtils;

import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: hww
 * Date: 12-8-21
 * Time: 下午2:37
 * To change this template use File | Settings | File Templates.
 */
public class StringHelper {

    /**
     * 用getBytes(encoding)：返回字符串的一个byte数组<br>
     * 当b[0]为 63时，应该是转码错误<br>
     * A、不乱码的汉字字符串： <br>
     * 1、encoding用GB2312时，每byte是负数；<br>
     * 2、encoding用ISO8859_1时，b[i]全是63。<br>
     * B、乱码的汉字字符串：<br>
     * 1、encoding用ISO8859_1时，每byte也是负数；<br>
     * 2、encoding用GB2312时，b[i]大部分是63。<br>
     * C、英文字符串<br>
     * 1、encoding用ISO8859_1和GB2312时，每byte都大于0；<br>
     * <p/>
     * 总结：给定一个字符串，用getBytes("iso8859_1") <br>
     * 1、如果b[i]有63，不用转码； A-2<br>
     * 2、如果b[i]全大于0，那么为英文字符串，不用转码； B-1<br>
     * 3、如果b[i]有小于0的，那么已经乱码，要转码。 C-1 <br>
     */
    public static String toGBK(String source) {
        if (source == null || source.equals("")) {
            return "";
        }

        String retStr = source;

        try {
            byte b[] = source.getBytes("ISO8859_1");

            for (int i = 0; i < b.length; i++) {
                byte b1 = b[i];
                if (b1 == 63) {
                    break; // 1
                } else if (b1 > 0) {
                    continue;// 2
                } else if (b1 < 0) {
                    // 不可能为0，0为字符串结束符
                    retStr = new String(b, "GBK");
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return retStr;
    }

    /**
     * 用getBytes(encoding)：返回字符串的一个byte数组<br>
     * 当b[0]为 63时，应该是转码错误<br>
     * A、不乱码的汉字字符串： <br>
     * 1、encoding用GB2312时，每byte是负数；<br>
     * 2、encoding用ISO8859_1时，b[i]全是63。<br>
     * B、乱码的汉字字符串：<br>
     * 1、encoding用ISO8859_1时，每byte也是负数；<br>
     * 2、encoding用GB2312时，b[i]大部分是63。<br>
     * C、英文字符串<br>
     * 1、encoding用ISO8859_1和GB2312时，每byte都大于0；<br>
     * <p/>
     * 总结：给定一个字符串，用getBytes("iso8859_1") <br>
     * 1、如果b[i]有63，不用转码； A-2<br>
     * 2、如果b[i]全大于0，那么为英文字符串，不用转码； B-1<br>
     * 3、如果b[i]有小于0的，那么已经乱码，要转码。 C-1 <br>
     */
    public static String toUTF(String source) {
        if (source == null || source.equals("")) {
            return "";
        }

        String retStr = source;

        try {
            byte b[] = source.getBytes("ISO8859_1");

            for (int i = 0; i < b.length; i++) {
                byte b1 = b[i];
                if (b1 == 63) {
                    break; // 1
                } else if (b1 > 0) {
                    continue;// 2
                } else if (b1 < 0) {
                    // 不可能为0，0为字符串结束符
                    retStr = new String(b, "utf-8");
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return retStr;
    }

    /**
     * 将一个字符数组转换为GBK编码
     *
     * @param source
     * @return
     */
    public static String[] toGBK(String[] source) {
        String[] temp = new String[source.length];
        for (int i = 0; i < source.length; i++) {
            temp[i] = toGBK(source[i]);
        }
        return temp;
    }

    /**
     * 替换字符串
     *
     * @param line
     * @param oldString
     * @param newString
     * @return
     */
    private static String replace(String line, String oldString, String newString) {
        if (line == null) {
            return null;
        }
        int i = 0;
        if ((i = line.indexOf(oldString, i)) >= 0) {
            char[] line2 = line.toCharArray();
            char[] newString2 = newString.toCharArray();
            int oLength = oldString.length();
            StringBuffer buf = new StringBuffer(line2.length);
            buf.append(line2, 0, i).append(newString2);
            i += oLength;
            int j = i;
            while ((i = line.indexOf(oldString, i)) > 0) {
                buf.append(line2, j, i - j).append(newString2);
                i += oLength;
                j = i;
            }
            buf.append(line2, j, line2.length - j);
            return buf.toString();
        }

        return line;
    }

    /**
     * 判断字符串不为null同时不为""
     *
     * @param value
     * @return
     */
    public static boolean isNotNull(String value) {
        if (null != value && !"".equals(value.trim())) {
            return true;
        }

        return false;
    }

    /**
     * 判断字符串数组不为null同时不为空
     *
     * @param value
     * @return
     */
    public static boolean isNotNull(String[] value) {
        if (null != value && value.length != 0) {
            return true;
        }

        return false;
    }

    /**
     * 将字符串数组转为以arg分隔的字符串<br>
     *
     * @param args
     * @param arg
     * @return
     */
    public static String array2String(String[] args, String arg) {
        StringBuffer sb = new StringBuffer();

        // 数组为空,直接返回空字符串
        if (args == null || args.length <= 0) {
            return "";
        }

        for (int i = 0; i < args.length; i++) {
            // 数组元素为空或空字符串，则转换为空格
            if (args[i] == null || args[i].trim().equals("")) {
                sb.append(arg + "");
            } else {
                sb.append(arg + args[i]);
            }
        }

        // 去除第一个分隔符
        if (sb.length() > 0) {
            return sb.substring(arg.length());
        }

        return sb.toString();
    }

    /**
     * <b>function:</b> 处理oracle sql 语句in子句中（where id in (1, 2, ..., 1000, 1001)），如果子句中超过1000项就会报错。
     * 这主要是oracle考虑性能问题做的限制。如果要解决次问题，可以用 where id (1, 2, ..., 1000) or id (1001, ...)
     * @author hoojo
     * @createDate 2012-8-31 下午02:36:03
     * @param ids in语句中的集合对象
     * @param count in语句中出现的条件个数
     * @param field in语句对应的数据库查询字段
     * @return 返回 field in (...) or field in (...) 字符串
     */
    public static String getOracleSQLIn(List<?> ids, int count, String field) {
        count = Math.min(count, 1000);
        int len = ids.size();
        int size = len % count;
        if (size == 0) {
            size = len / count;
        } else {
            size = (len / count) + 1;
        }
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < size; i++) {
            int fromIndex = i * count;
            int toIndex = Math.min(fromIndex + count, len);
            String productId = StringUtils.defaultIfEmpty(StringUtils.join(ids.subList(fromIndex, toIndex), "','"), "");
            if (i != 0) {
                builder.append(" or ");
            }
            builder.append(field).append(" in ('").append(productId).append("')");
        }

        return StringUtils.defaultIfEmpty(builder.toString(), field + " in ('')");
    }

    /**
     * 从hql语句获取count语句
     *
     * @param hql
     * @return
     */
    public static String getCountHql(String hql) {
        String lower = hql.toLowerCase();
        int i = lower.indexOf("from");
        int j = lower.indexOf(" order by ");

        if (j > i) {
            hql = hql.substring(i, j);
        } else {
            hql = hql.substring(i);
        }

        return "select count(*) " + hql;

    }
}


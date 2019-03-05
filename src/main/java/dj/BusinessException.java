package dj;

/**
 * Created by IntelliJ IDEA.
 * User: hww
 * Date: 12-6-6
 * Time: 下午2:43
 * To change this template use File | Settings | File Templates.
 */
public class BusinessException extends RuntimeException {
    private static final long serialVersionUID = -4203974155103350290L;
    private String code;
    private String msg;

    public BusinessException(String msg) {
        super(msg);
    }

    public BusinessException(String code, String msg) {
        super(msg);
        this.code = code;
    }

    public BusinessException(String msg, Throwable e) {
        super(msg, e);
    }

    public BusinessException(String code, String msg, Throwable e) {
        super(msg, e);
        this.code = code;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }
}
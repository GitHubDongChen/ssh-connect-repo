package cn.dc.repository.entity;

import java.util.StringJoiner;

public class ConnectVO {

  private String host;
  private Integer port;
  private String user;
  private String passwd;

  public ConnectVO() {
  }

  public ConnectVO(String host, Integer port, String user, String passwd) {
    this.host = host;
    this.port = port;
    this.user = user;
    this.passwd = passwd;
  }

  public String getHost() {
    return host;
  }

  public void setHost(String host) {
    this.host = host;
  }

  public Integer getPort() {
    return port;
  }

  public void setPort(Integer port) {
    this.port = port;
  }

  public String getUser() {
    return user;
  }

  public void setUser(String user) {
    this.user = user;
  }

  public String getPasswd() {
    return passwd;
  }

  public void setPasswd(String passwd) {
    this.passwd = passwd;
  }

  @Override
  public String toString() {
    return new StringJoiner(", ", ConnectVO.class.getSimpleName() + "[", "]")
        .add("host='" + host + "'")
        .add("port=" + port)
        .add("user='" + user + "'")
        .add("passwd='" + passwd + "'")
        .toString();
  }
}

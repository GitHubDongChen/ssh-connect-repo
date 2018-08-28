package cn.dc.repository.entity;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "connect")
public class ConnectPO {

  @Id
  private String id;
  private String host;
  private Integer port;
  private String user;
  private String passwd;

  protected ConnectPO() {
  }

  public ConnectPO(String host, Integer port, String user, String passwd) {
    this.host = host;
    this.port = port;
    this.user = user;
    this.passwd = passwd;
    generateId();
  }

  private void generateId() {
    String original = String.format("%s:%s:%s", host, port, user);
    try {
      MessageDigest md5 = MessageDigest.getInstance("MD5");
      md5.update(original.getBytes());
      this.id = new BigInteger(1, md5.digest()).toString(16);
    } catch (NoSuchAlgorithmException ignored) {
    }
  }

  public String getId() {
    return id;
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
    final StringBuffer sb = new StringBuffer("ConnectPO{");
    sb.append("id='").append(id).append('\'');
    sb.append(", host='").append(host).append('\'');
    sb.append(", port=").append(port);
    sb.append(", user='").append(user).append('\'');
    sb.append(", passwd='").append(passwd).append('\'');
    sb.append('}');
    return sb.toString();
  }
}

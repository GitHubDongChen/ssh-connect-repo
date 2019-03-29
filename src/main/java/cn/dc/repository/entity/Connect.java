package cn.dc.repository.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.StringJoiner;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "connect")
public class Connect {

  @Id
  @JsonIgnore
  private String id;
  private String host;
  private Integer port;
  private String user;
  private String passwd;
  private String alias;

  protected Connect() {
  }

  public Connect(String host, Integer port, String user, String passwd, String alias) {
    this.host = host;
    this.port = port;
    this.user = user;
    this.passwd = passwd;
    this.alias = alias;
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

  public String getAlias() {
    return alias;
  }

  public void setAlias(String alias) {
    this.alias = alias;
  }

  @Override
  public String toString() {
    return new StringJoiner(", ", Connect.class.getSimpleName() + "[", "]")
        .add("id='" + id + "'")
        .add("host='" + host + "'")
        .add("port=" + port)
        .add("user='" + user + "'")
        .add("passwd='" + passwd + "'")
        .add("alias='" + alias + "'")
        .toString();
  }
}

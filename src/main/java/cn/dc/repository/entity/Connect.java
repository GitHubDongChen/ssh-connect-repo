package cn.dc.repository.entity;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Getter
@Setter
@ToString
@Document(collection = "connect")
public class Connect {

  @Id
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

}

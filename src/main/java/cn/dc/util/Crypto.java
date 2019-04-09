package cn.dc.util;

import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import javax.annotation.PostConstruct;
import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESedeKeySpec;
import org.apache.tomcat.util.codec.binary.Base64;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * 3DES 加密解密
 *
 * @author dongchen
 */
@Component
public class Crypto {

  private static final String KEY_ALGORITHM = "DESede";
  /**
   * 默认的加密算法
   */
  private static final String DEFAULT_CIPHER_ALGORITHM = "DESede/ECB/PKCS5Padding";

  @Value("${private.key}")
  private String key;

  private Cipher encryptCipher;
  private Cipher decryptCipher;

  @PostConstruct
  public void init()
      throws NoSuchAlgorithmException, InvalidKeyException, InvalidKeySpecException, NoSuchPaddingException {
    SecretKey secretKey = getSecretKey(key);

    encryptCipher = Cipher.getInstance(DEFAULT_CIPHER_ALGORITHM);
    // 初始化为加密模式的密码器
    encryptCipher.init(Cipher.ENCRYPT_MODE, secretKey);

    decryptCipher = Cipher.getInstance(DEFAULT_CIPHER_ALGORITHM);
    //使用密钥初始化，设置为解密模式
    decryptCipher.init(Cipher.DECRYPT_MODE, secretKey);
  }


  /**
   * DESede 加密操作
   *
   * @param content 待加密内容
   * @return 返回Base64转码后的加密数据
   */
  public String encrypt(String content) {
    try {
      byte[] byteContent = content.getBytes(StandardCharsets.UTF_8);
      // 加密
      byte[] result = encryptCipher.doFinal(byteContent);
      //通过Base64转码返回
      return Base64.encodeBase64String(result);
    } catch (IllegalBlockSizeException | BadPaddingException e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * DESede 解密操作
   */
  public String decrypt(String content) {
    try {
      //执行操作
      byte[] result = decryptCipher.doFinal(Base64.decodeBase64(content));
      return new String(result, StandardCharsets.UTF_8);
    } catch (IllegalBlockSizeException | BadPaddingException e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * 生成加密秘钥
   */
  private static SecretKey getSecretKey(final String key)
      throws NoSuchAlgorithmException, InvalidKeyException, InvalidKeySpecException {
    SecretKeyFactory keyFactory = SecretKeyFactory.getInstance(KEY_ALGORITHM);
    DESedeKeySpec keySpec = new DESedeKeySpec(key.getBytes(StandardCharsets.UTF_8));
    return keyFactory.generateSecret(keySpec);
  }

}

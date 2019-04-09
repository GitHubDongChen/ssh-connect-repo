package cn.dc.controller;

import cn.dc.repository.ConnectRepository;
import cn.dc.repository.entity.Connect;
import cn.dc.util.Crypto;
import java.util.Optional;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ConnectQuery {

  private ConnectRepository connectRepository;

  private Crypto crypto;

  public ConnectQuery(ConnectRepository connectRepository, Crypto crypto) {
    this.connectRepository = connectRepository;
    this.crypto = crypto;
  }

  @GetMapping("/passwd")
  public ResponseEntity findPasswd(
      @RequestParam String host,
      @RequestParam(required = false, defaultValue = "22") Integer port,
      @RequestParam(required = false, defaultValue = "root") String user
  ) {
    Optional<Connect> result =
        connectRepository.findById(new Connect(host, port, user, null, null).getId());
    return result.map(connect -> crypto.decrypt(connect.getPasswd()))
        .map(passwd -> new ResponseEntity<>(passwd, HttpStatus.OK))
        .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
  }

  @GetMapping("/alias/{alias}")
  public ResponseEntity<Connect> findPasswdByAlias(
      @PathVariable String alias
  ) {
    Optional<Connect> result = connectRepository.findByAlias(alias);
    return result.map(connect -> {
      connect.setPasswd(crypto.decrypt(connect.getPasswd()));
      return connect;
    })
        .map(connect -> new ResponseEntity<>(connect, HttpStatus.OK))
        .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
  }


}

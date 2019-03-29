package cn.dc.controller;

import cn.dc.repository.ConnectRepository;
import cn.dc.repository.entity.ConnectPO;
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

  public ConnectQuery(ConnectRepository connectRepository) {
    this.connectRepository = connectRepository;
  }

  @GetMapping("/passwd")
  public ResponseEntity findPasswd(
      @RequestParam String host,
      @RequestParam(required = false, defaultValue = "22") Integer port,
      @RequestParam(required = false, defaultValue = "root") String user
  ) {

    Optional<ConnectPO> result =
        connectRepository.findById(new ConnectPO(host, port, user, null, null).getId());

    return result.map(po -> new ResponseEntity<>(po.getPasswd(), HttpStatus.OK))
        .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
  }

  @GetMapping("/alias/{alias}")
  public ResponseEntity<String> findPasswdByAlias(
      @PathVariable String alias
  ) {

    Optional<ConnectPO> result = connectRepository.findByAlias(alias);

    return result.map(po -> new ResponseEntity<>(po.getPasswd(), HttpStatus.OK))
        .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
  }


}

package cn.dc.controller;

import cn.dc.repository.ConnectRepository;
import cn.dc.repository.entity.Connect;
import cn.dc.util.Crypto;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ConnectCommand {

  private ConnectRepository connectRepository;

  private Crypto crypto;

  public ConnectCommand(ConnectRepository connectRepository, Crypto crypto) {
    this.connectRepository = connectRepository;
    this.crypto = crypto;
  }

  @PostMapping("/save")
  public void saveOrUpdateConnect(
      @RequestParam String host,
      @RequestParam(required = false, defaultValue = "22") Integer port,
      @RequestParam(required = false, defaultValue = "root") String user,
      @RequestParam String passwd,
      @RequestParam(required = false) String alias
  ) {
    if (StringUtils.isNotBlank(alias)) {
      connectRepository.findByAlias(alias)
          .ifPresent(connect -> {
            connect.setAlias(null);
            connectRepository.save(connect);
          });
    }

    Connect connect = new Connect(host, port, user, crypto.encrypt(passwd), alias);
    connectRepository.save(connect);
  }

  @DeleteMapping("/del/{id}")
  public void deleteConnect(@PathVariable String id) {
    connectRepository.deleteById(id);
  }

}

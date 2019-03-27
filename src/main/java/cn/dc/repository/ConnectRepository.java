package cn.dc.repository;

import cn.dc.repository.entity.ConnectPO;
import java.util.Optional;
import org.springframework.data.repository.CrudRepository;

public interface ConnectRepository extends CrudRepository<ConnectPO, String> {

  /**
   * 根据别名查找
   */
  Optional<ConnectPO> findByAlias(String alias);

}

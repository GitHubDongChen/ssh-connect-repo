package cn.dc.repository;

import cn.dc.repository.entity.Connect;
import java.util.Optional;
import org.springframework.data.repository.CrudRepository;

public interface ConnectRepository extends CrudRepository<Connect, String> {

  /**
   * 根据别名查找
   */
  Optional<Connect> findByAlias(String alias);

}

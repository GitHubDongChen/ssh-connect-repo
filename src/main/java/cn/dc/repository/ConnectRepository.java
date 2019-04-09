package cn.dc.repository;

import cn.dc.repository.entity.Connect;
import java.util.Optional;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ConnectRepository extends MongoRepository<Connect, String> {

  /**
   * 根据别名查找
   */
  Optional<Connect> findByAlias(String alias);

}

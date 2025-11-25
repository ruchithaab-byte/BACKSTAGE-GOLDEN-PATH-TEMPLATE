package com.hms.{{ values.serviceName | replace("-", "") }}.outbox;

import com.hms.{{ values.serviceName | replace("-", "") }}.outbox.{{ values.serviceName | replace("-", "") | capitalize }}OutboxEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface {{ values.serviceName | replace("-", "") | capitalize }}OutboxEventRepository extends JpaRepository<{{ values.serviceName | replace("-", "") | capitalize }}OutboxEvent, UUID> {
}

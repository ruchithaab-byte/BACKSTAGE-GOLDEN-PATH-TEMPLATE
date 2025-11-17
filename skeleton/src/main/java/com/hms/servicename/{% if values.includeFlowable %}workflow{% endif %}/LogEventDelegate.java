package com.hms.servicename.workflow;

import org.flowable.engine.delegate.DelegateExecution;
import org.flowable.engine.delegate.JavaDelegate;
import org.springframework.stereotype.Component;
import java.util.logging.Logger;

@Component("logTask") // Bean name must match the flowable:class in the XML
public class LogEventDelegate implements JavaDelegate {

    private final Logger LOGGER = Logger.getLogger(LogEventDelegate.class.getName());

    @Override
    public void execute(DelegateExecution execution) {
        LOGGER.info("WORKFLOW EXECUTED!");
        LOGGER.info("Process Instance ID: " + execution.getProcessInstanceId());
        // You can get variables from the Kafka event here
        // e.g., String customerId = (String) execution.getVariable("customerId");
    }
}


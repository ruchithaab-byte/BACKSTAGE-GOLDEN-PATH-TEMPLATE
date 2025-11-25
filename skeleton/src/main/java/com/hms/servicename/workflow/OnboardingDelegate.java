package com.hms.{{ values.serviceName | replace("-", "") }}.workflow;

import org.flowable.engine.delegate.DelegateExecution;
import org.flowable.engine.delegate.JavaDelegate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * Example Flowable Delegate.
 * This demonstrates how to write a JavaDelegate that can be called from a BPMN process.
 */
@Component("onboardingDelegate")
public class OnboardingDelegate implements JavaDelegate {

    private static final Logger log = LoggerFactory.getLogger(OnboardingDelegate.class);

    @Override
    public void execute(DelegateExecution execution) {
        log.info("Executing Onboarding Delegate for process instance: {}", execution.getProcessInstanceId());
        
        // Extract variables from the process execution context
        String userId = (String) execution.getVariable("userId");
        String tenantId = (String) execution.getVariable("tenantId");
        String email = (String) execution.getVariable("email");
        
        log.info("Onboarding user: {} (email={}) for tenant: {}", userId, email, tenantId);
        
        // TODO: Implement your business logic here
        // e.g., Send welcome email, provision resources, etc.
        
        // Set output variables if needed
        execution.setVariable("onboardingStatus", "COMPLETED");
    }
}

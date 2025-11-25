package com.hms.{{ values.serviceName | replace("-", "") }}.controller;

import com.hms.lib.common.security.PermissionService;
import io.permit.sdk.enforcement.Resource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * Example controller demonstrating Permit.io authorization patterns.
 * 
 * Authorization Patterns:
 * 1. Resource-level permissions (create, read, update, delete)
 * 2. Action-based permissions (approve, review, publish)
 * 3. Attribute-based permissions (owner-only actions)
 */
@RestController
@RequestMapping("/api/example")
public class {{ values.serviceName | replace("-", "") | capitalize }}ExampleAuthorizationController {
    
    @Autowired
    private PermissionService permissionService;
    
    /**
     * Pattern 1: Basic Resource Permission Check
     * 
     * Check if user can perform an action on a resource type.
     */
    @GetMapping("/resources/{id}")
    public ResponseEntity<?> getResource(@PathVariable String id, Authentication auth) {
        String userId = auth.getName(); // From JWT 'sub' claim
        
        // Build resource object
        Resource resource = Resource.builder()
                .withType("document")
                .withKey(id)
                .withTenant("current-org-id") // Get from context
                .build();
        
        // Check permission
        if (!permissionService.check(userId, "read", resource)) {
            return ResponseEntity.status(403).body("Access denied");
        }
        
        // Proceed with business logic
        return ResponseEntity.ok("Resource data");
    }
    
    /**
     * Pattern 2: Create/Write Permission
     * 
     * Check if user can create resources of a specific type.
     */
    @PostMapping("/resources")
    public ResponseEntity<?> createResource(@RequestBody Object payload, Authentication auth) {
        String userId = auth.getName();
        
        Resource resource = Resource.builder()
                .withType("document")
                .withTenant("current-org-id")
                .build();
        
        if (!permissionService.check(userId, "create", resource)) {
            return ResponseEntity.status(403).body("Cannot create resource");
        }
        
        // Create resource...
        return ResponseEntity.ok("Resource created");
    }
    
    /**
     * Pattern 3: Update/Delete Permission
     * 
     * Check if user can modify a specific resource instance.
     */
    @PutMapping("/resources/{id}")
    public ResponseEntity<?> updateResource(
            @PathVariable String id, 
            @RequestBody Object payload, 
            Authentication auth) {
        
        String userId = auth.getName();
        
        Resource resource = Resource.builder()
                .withType("document")
                .withKey(id)
                .withTenant("current-org-id")
                // Optional: Add attributes for ABAC
                .withAttribute("owner", "some-owner-id")
                .withAttribute("status", "draft")
                .build();
        
        if (!permissionService.check(userId, "update", resource)) {
            return ResponseEntity.status(403).body("Cannot update resource");
        }
        
        // Update logic...
        return ResponseEntity.ok("Resource updated");
    }
    
    /**
     * Pattern 4: Custom Action Permission
     * 
     * Check if user can perform custom business actions.
     */
    @PostMapping("/resources/{id}/publish")
    public ResponseEntity<?> publishResource(@PathVariable String id, Authentication auth) {
        String userId = auth.getName();
        
        Resource resource = Resource.builder()
                .withType("document")
                .withKey(id)
                .withTenant("current-org-id")
                .build();
        
        // Check custom permission
        if (!permissionService.check(userId, "publish", resource)) {
            return ResponseEntity.status(403).body("Cannot publish resource");
        }
        
        // Publish logic...
        return ResponseEntity.ok("Resource published");
    }
    
    /**
     * Pattern 5: Multi-Permission Check
     * 
     * Some operations require multiple permissions.
     */
    @PostMapping("/resources/{id}/approve-and-publish")
    public ResponseEntity<?> approveAndPublish(@PathVariable String id, Authentication auth) {
        String userId = auth.getName();
        
        Resource resource = Resource.builder()
                .withType("document")
                .withKey(id)
                .withTenant("current-org-id")
                .build();
        
        // Check multiple permissions
        boolean canApprove = permissionService.check(userId, "approve", resource);
        boolean canPublish = permissionService.check(userId, "publish", resource);
        
        if (!canApprove || !canPublish) {
            return ResponseEntity.status(403)
                    .body("Requires both approve and publish permissions");
        }
        
        // Execute operation...
        return ResponseEntity.ok("Resource approved and published");
    }
}

package com.hims.core.scalekit;

import com.scalekit.ScalekitClient;
import com.scalekit.exceptions.APIException;
import com.scalekit.grpc.scalekit.v1.organizations.CreateOrganization;
import com.scalekit.grpc.scalekit.v1.organizations.Organization;
import com.scalekit.grpc.scalekit.v1.users.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.UUID;

/**
 * Scalekit Service
 * 
 * Manages organizations and users using Scalekit Java SDK.
 * 
 * Responsibilities:
 * - Create organizations (tenants)
 * - Create users and assign them to organizations
 * - Manage user memberships
 * 
 * This service uses M2M (Machine-to-Machine) authentication with Scalekit.
 */
@Service
public class ScalekitService {

    private static final Logger log = LoggerFactory.getLogger(ScalekitService.class);

    private final ScalekitClient scalekitClient;

    public ScalekitService(
            @Value("${scalekit.environment-url}") String environmentUrl,
            @Value("${scalekit.client-id}") String clientId,
            @Value("${scalekit.client-secret}") String clientSecret) {
        this.scalekitClient = new ScalekitClient(environmentUrl, clientId, clientSecret);
        log.info("Scalekit client initialized for environment: {}", environmentUrl);
    }

    /**
     * Create a new organization (tenant) in Scalekit.
     * 
     * @param displayName Organization display name
     * @param externalId Optional external ID (for mapping to your system)
     * @return Created organization
     */
    public Organization createOrganization(String displayName, String externalId) {
        try {
            CreateOrganization.Builder builder = CreateOrganization.newBuilder()
                    .setDisplayName(displayName);

            if (externalId != null && !externalId.isBlank()) {
                builder.setExternalId(externalId);
            } else {
                // Generate a unique external ID if not provided
                builder.setExternalId(UUID.randomUUID().toString().substring(0, 10));
            }

            Organization organization = scalekitClient.organizations().create(builder.build());
            log.info("Created organization: {} (ID: {})", displayName, organization.getId());
            return organization;
        } catch (APIException e) {
            log.error("Failed to create organization: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to create organization in Scalekit: " + e.getMessage(), e);
        }
    }

    /**
     * Get organization by ID.
     * 
     * @param organizationId Scalekit organization ID
     * @return Organization
     */
    public Organization getOrganization(String organizationId) {
        try {
            return scalekitClient.organizations().getById(organizationId);
        } catch (APIException e) {
            log.error("Failed to get organization {}: {}", organizationId, e.getMessage());
            throw new RuntimeException("Failed to get organization: " + e.getMessage(), e);
        }
    }

    /**
     * Get organization by external ID.
     * 
     * @param externalId External ID
     * @return Organization
     */
    public Organization getOrganizationByExternalId(String externalId) {
        try {
            return scalekitClient.organizations().getByExternalId(externalId);
        } catch (APIException e) {
            log.error("Failed to get organization by external ID {}: {}", externalId, e.getMessage());
            throw new RuntimeException("Failed to get organization: " + e.getMessage(), e);
        }
    }

    /**
     * Create a user and assign them to an organization.
     * 
     * This is the recommended way to create users in Scalekit.
     * It creates the user and their membership in a single operation.
     * 
     * @param organizationId Organization ID (tenant)
     * @param email User email
     * @param sendInvitationEmail Whether to send invitation email
     * @return Created user with membership response
     */
    public CreateUserAndMembershipResponse createUserAndMembership(
            String organizationId,
            String email,
            boolean sendInvitationEmail) {
        try {
            CreateUser user = CreateUser.newBuilder()
                    .setEmail(email)
                    .build();

            CreateUserAndMembershipRequest request = CreateUserAndMembershipRequest.newBuilder()
                    .setUser(user)
                    .setSendInvitationEmail(sendInvitationEmail)
                    .build();

            CreateUserAndMembershipResponse response = scalekitClient.users()
                    .createUserAndMembership(organizationId, request);

            log.info("Created user {} and assigned to organization {}", email, organizationId);
            return response;
        } catch (APIException e) {
            log.error("Failed to create user {} in organization {}: {}", email, organizationId, e.getMessage());
            throw new RuntimeException("Failed to create user in Scalekit: " + e.getMessage(), e);
        }
    }

    /**
     * Create a user with profile information and assign them to an organization.
     * 
     * Note: Password is not set via CreateUser. Users will receive an invitation email
     * to set their password, or password can be set via Scalekit's password connection.
     * 
     * @param organizationId Organization ID (tenant)
     * @param email User email
     * @param firstName User first name
     * @param lastName User last name
     * @return Created user with membership response
     */
    public CreateUserAndMembershipResponse createUserWithProfile(
            String organizationId,
            String email,
            String firstName,
            String lastName) {
        try {
            CreateUser.Builder userBuilder = CreateUser.newBuilder()
                    .setEmail(email);

            if (firstName != null || lastName != null) {
                CreateUserProfile.Builder profileBuilder = CreateUserProfile.newBuilder();
                if (firstName != null) {
                    profileBuilder.setFirstName(firstName);
                }
                if (lastName != null) {
                    profileBuilder.setLastName(lastName);
                }
                userBuilder.setUserProfile(profileBuilder.build());
            }

            CreateUserAndMembershipRequest request = CreateUserAndMembershipRequest.newBuilder()
                    .setUser(userBuilder.build())
                    .setSendInvitationEmail(true) // Send invitation email to set password
                    .build();

            CreateUserAndMembershipResponse response = scalekitClient.users()
                    .createUserAndMembership(organizationId, request);

            log.info("Created user {} with profile and assigned to organization {}", email, organizationId);
            return response;
        } catch (APIException e) {
            log.error("Failed to create user {} in organization {}: {}", 
                    email, organizationId, e.getMessage());
            throw new RuntimeException("Failed to create user in Scalekit: " + e.getMessage(), e);
        }
    }

    /**
     * Get user by ID.
     * 
     * @param userId Scalekit user ID
     * @return User response
     */
    public GetUserResponse getUser(String userId) {
        try {
            return scalekitClient.users().getUser(userId);
        } catch (APIException e) {
            log.error("Failed to get user {}: {}", userId, e.getMessage());
            throw new RuntimeException("Failed to get user: " + e.getMessage(), e);
        }
    }
}


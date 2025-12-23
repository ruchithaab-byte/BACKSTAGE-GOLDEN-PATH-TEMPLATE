package com.hims.modules.{{ values.moduleName }};

import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import com.tngtech.archunit.lang.ArchRule;
import org.junit.jupiter.api.Test;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.*;

/**
 * Architecture tests for {{ values.moduleName }} module.
 * 
 * These tests enforce module boundaries and prevent coupling violations.
 */
class {{ values.moduleName | capitalize }}ModuleArchitectureTest {

    private final JavaClasses classes = new ClassFileImporter()
            .importPackages("com.hims.modules.{{ values.moduleName }}");

    @Test
    void apiShouldNotDependOnInternal() {
        ArchRule rule = noClasses()
                .that().resideInAPackage("com.hims.modules.{{ values.moduleName }}.api..")
                .should().dependOnClassesThat()
                .resideInAPackage("com.hims.modules.{{ values.moduleName }}.internal..");

        rule.check(classes);
    }

    @Test
    void internalShouldNotDependOnOtherModulesInternal() {
        ArchRule rule = noClasses()
                .that().resideInAPackage("com.hims.modules.{{ values.moduleName }}.internal..")
                .should().dependOnClassesThat()
                .resideInAnyPackage(
                        "com.hims.modules.clinical.internal..",
                        "com.hims.modules.billing.internal..",
                        "com.hims.modules.inventory.internal.."
                )
                .because("Modules must not access other modules' internal packages");

        // Only check if other modules exist
        JavaClasses allClasses = new ClassFileImporter().importPackages("com.hims");
        if (allClasses.containPackage("com.hims.modules.clinical") ||
            allClasses.containPackage("com.hims.modules.billing") ||
            allClasses.containPackage("com.hims.modules.inventory")) {
            rule.check(classes);
        }
    }

    @Test
    void internalMayDependOnOtherModulesApi() {
        ArchRule rule = classes()
                .that().resideInAPackage("com.hims.modules.{{ values.moduleName }}.internal..")
                .should().onlyDependOnClassesThat()
                .resideInAnyPackage(
                        "com.hims.modules.{{ values.moduleName }}..",
                        "com.hims.modules..api..",  // Other modules' API packages
                        "com.hims.core..",
                        "java..",
                        "org.springframework..",
                        "jakarta.."
                );

        rule.check(classes);
    }

    @Test
    void webShouldNotExposeInternalEntities() {
        ArchRule rule = noClasses()
                .that().resideInAPackage("com.hims.modules.{{ values.moduleName }}.internal.web..")
                .should().dependOnClassesThat()
                .resideInAPackage("com.hims.modules.{{ values.moduleName }}.internal.domain..")
                .because("Controllers should use DTOs, not domain entities");

        rule.check(classes);
    }

    @Test
    void serviceShouldImplementApiInterface() {
        ArchRule rule = classes()
                .that().resideInAPackage("com.hims.modules.{{ values.moduleName }}.internal.service..")
                .should().implement(com.hims.modules.{{ values.moduleName }}.api.spi.{{ values.moduleName | capitalize }}ServiceProvider.class)
                .because("Services must implement API interface");

        rule.check(classes);
    }
}


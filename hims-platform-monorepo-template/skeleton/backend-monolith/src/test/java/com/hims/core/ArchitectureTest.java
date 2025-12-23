package com.hims.core;

import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import com.tngtech.archunit.lang.ArchRule;
import org.junit.jupiter.api.Test;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.*;

/**
 * Architecture tests to enforce Core Kernel boundaries.
 * 
 * These tests ensure:
 * 1. Core cannot depend on modules
 * 2. Modules may depend on core
 * 3. Core cannot have business entities
 */
class ArchitectureTest {

    private final JavaClasses classes = new ClassFileImporter()
            .importPackages("com.hims");

    @Test
    void coreShouldNotDependOnModules() {
        ArchRule rule = noClasses()
                .that().resideInAPackage("com.hims.core..")
                .should().dependOnClassesThat()
                .resideInAPackage("com.hims.modules..");

        rule.check(classes);
    }

    @Test
    void modulesMayDependOnCore() {
        ArchRule rule = classes()
                .that().resideInAPackage("com.hims.modules..")
                .should().onlyDependOnClassesThat()
                .resideInAnyPackage(
                        "com.hims.modules..",
                        "com.hims.core..",
                        "java..",
                        "org.springframework..",
                        "jakarta..",
                        "org.hibernate.."
                );

        // Only check if modules exist
        if (classes.containPackage("com.hims.modules")) {
            rule.check(classes);
        }
    }

    @Test
    void coreShouldNotHaveBusinessEntities() {
        ArchRule rule = noClasses()
                .that().resideInAPackage("com.hims.core..")
                .should().beAnnotatedWith(jakarta.persistence.Entity.class)
                .orShould().beAnnotatedWith(jakarta.persistence.Table.class);

        rule.check(classes);
    }

    @Test
    void coreShouldNotHaveRepositories() {
        ArchRule rule = noClasses()
                .that().resideInAPackage("com.hims.core..")
                .should().beAssignableTo(org.springframework.data.repository.Repository.class);

        rule.check(classes);
    }
}


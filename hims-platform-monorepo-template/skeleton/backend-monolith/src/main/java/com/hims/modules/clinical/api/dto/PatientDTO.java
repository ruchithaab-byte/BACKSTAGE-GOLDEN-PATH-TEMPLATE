package com.hims.modules.clinical.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * Patient Data Transfer Object
 * 
 * Used for patient registration API input.
 * FHIR-aligned structure for interoperability.
 */
public class PatientDTO {

    @NotBlank(message = "MRN is required")
    @Pattern(regexp = "^[A-Z0-9-]{1,50}$", message = "MRN must be alphanumeric with hyphens, max 50 characters")
    private String mrn;

    @NotNull(message = "Name is required")
    private NameDTO name;

    @NotNull(message = "Gender is required")
    @Pattern(regexp = "^(male|female|other|unknown)$", message = "Gender must be one of: male, female, other, unknown")
    private String gender;

    @NotNull(message = "Birth date is required")
    private LocalDate birthDate;

    private List<ContactPointDTO> telecom;
    private List<AddressDTO> address;
    private MaritalStatusDTO maritalStatus;
    private String photoUrl;
    private List<ContactDTO> contacts;
    private List<CommunicationDTO> communication;
    private String generalPractitionerId;
    private String managingOrganization;
    private String abhaNumber;
    private String abhaAddress;
    private String encryptionKeyId;
    private String dataSovereigntyTag;
    private String consentRef;

    // Getters and Setters
    public String getMrn() { return mrn; }
    public void setMrn(String mrn) { this.mrn = mrn; }
    public NameDTO getName() { return name; }
    public void setName(NameDTO name) { this.name = name; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public LocalDate getBirthDate() { return birthDate; }
    public void setBirthDate(LocalDate birthDate) { this.birthDate = birthDate; }
    public List<ContactPointDTO> getTelecom() { return telecom; }
    public void setTelecom(List<ContactPointDTO> telecom) { this.telecom = telecom; }
    public List<AddressDTO> getAddress() { return address; }
    public void setAddress(List<AddressDTO> address) { this.address = address; }
    public MaritalStatusDTO getMaritalStatus() { return maritalStatus; }
    public void setMaritalStatus(MaritalStatusDTO maritalStatus) { this.maritalStatus = maritalStatus; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public List<ContactDTO> getContacts() { return contacts; }
    public void setContacts(List<ContactDTO> contacts) { this.contacts = contacts; }
    public List<CommunicationDTO> getCommunication() { return communication; }
    public void setCommunication(List<CommunicationDTO> communication) { this.communication = communication; }
    public String getGeneralPractitionerId() { return generalPractitionerId; }
    public void setGeneralPractitionerId(String generalPractitionerId) { this.generalPractitionerId = generalPractitionerId; }
    public String getManagingOrganization() { return managingOrganization; }
    public void setManagingOrganization(String managingOrganization) { this.managingOrganization = managingOrganization; }
    public String getAbhaNumber() { return abhaNumber; }
    public void setAbhaNumber(String abhaNumber) { this.abhaNumber = abhaNumber; }
    public String getAbhaAddress() { return abhaAddress; }
    public void setAbhaAddress(String abhaAddress) { this.abhaAddress = abhaAddress; }
    public String getEncryptionKeyId() { return encryptionKeyId; }
    public void setEncryptionKeyId(String encryptionKeyId) { this.encryptionKeyId = encryptionKeyId; }
    public String getDataSovereigntyTag() { return dataSovereigntyTag; }
    public void setDataSovereigntyTag(String dataSovereigntyTag) { this.dataSovereigntyTag = dataSovereigntyTag; }
    public String getConsentRef() { return consentRef; }
    public void setConsentRef(String consentRef) { this.consentRef = consentRef; }

    // Nested DTOs
    public static class NameDTO {
        private String use; // usual, official, temp, nickname, anonymous, old, maiden
        private String family;
        private List<String> given;
        private List<String> prefix;
        private List<String> suffix;

        public String getUse() { return use; }
        public void setUse(String use) { this.use = use; }
        public String getFamily() { return family; }
        public void setFamily(String family) { this.family = family; }
        public List<String> getGiven() { return given; }
        public void setGiven(List<String> given) { this.given = given; }
        public List<String> getPrefix() { return prefix; }
        public void setPrefix(List<String> prefix) { this.prefix = prefix; }
        public List<String> getSuffix() { return suffix; }
        public void setSuffix(List<String> suffix) { this.suffix = suffix; }
    }

    public static class ContactPointDTO {
        private String system; // phone, fax, email, pager, url, sms, other
        private String value;
        private String use; // home, work, temp, old, mobile
        private Integer rank;
        private LocalDate periodStart;
        private LocalDate periodEnd;

        public String getSystem() { return system; }
        public void setSystem(String system) { this.system = system; }
        public String getValue() { return value; }
        public void setValue(String value) { this.value = value; }
        public String getUse() { return use; }
        public void setUse(String use) { this.use = use; }
        public Integer getRank() { return rank; }
        public void setRank(Integer rank) { this.rank = rank; }
        public LocalDate getPeriodStart() { return periodStart; }
        public void setPeriodStart(LocalDate periodStart) { this.periodStart = periodStart; }
        public LocalDate getPeriodEnd() { return periodEnd; }
        public void setPeriodEnd(LocalDate periodEnd) { this.periodEnd = periodEnd; }
    }

    public static class AddressDTO {
        private String use; // home, work, temp, old, billing
        private String type; // postal, physical, both
        private String text;
        private List<String> line;
        private String city;
        private String district;
        private String state;
        private String postalCode;
        private String country;
        private LocalDate periodStart;
        private LocalDate periodEnd;

        public String getUse() { return use; }
        public void setUse(String use) { this.use = use; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getText() { return text; }
        public void setText(String text) { this.text = text; }
        public List<String> getLine() { return line; }
        public void setLine(List<String> line) { this.line = line; }
        public String getCity() { return city; }
        public void setCity(String city) { this.city = city; }
        public String getDistrict() { return district; }
        public void setDistrict(String district) { this.district = district; }
        public String getState() { return state; }
        public void setState(String state) { this.state = state; }
        public String getPostalCode() { return postalCode; }
        public void setPostalCode(String postalCode) { this.postalCode = postalCode; }
        public String getCountry() { return country; }
        public void setCountry(String country) { this.country = country; }
        public LocalDate getPeriodStart() { return periodStart; }
        public void setPeriodStart(LocalDate periodStart) { this.periodStart = periodStart; }
        public LocalDate getPeriodEnd() { return periodEnd; }
        public void setPeriodEnd(LocalDate periodEnd) { this.periodEnd = periodEnd; }
    }

    public static class MaritalStatusDTO {
        private String code; // M, S, D, W, U, UNK
        private String display;
        private String system;

        public String getCode() { return code; }
        public void setCode(String code) { this.code = code; }
        public String getDisplay() { return display; }
        public void setDisplay(String display) { this.display = display; }
        public String getSystem() { return system; }
        public void setSystem(String system) { this.system = system; }
    }

    public static class ContactDTO {
        private String relationship;
        private NameDTO name;
        private List<ContactPointDTO> telecom;
        private AddressDTO address;
        private String gender;
        private String organization;

        public String getRelationship() { return relationship; }
        public void setRelationship(String relationship) { this.relationship = relationship; }
        public NameDTO getName() { return name; }
        public void setName(NameDTO name) { this.name = name; }
        public List<ContactPointDTO> getTelecom() { return telecom; }
        public void setTelecom(List<ContactPointDTO> telecom) { this.telecom = telecom; }
        public AddressDTO getAddress() { return address; }
        public void setAddress(AddressDTO address) { this.address = address; }
        public String getGender() { return gender; }
        public void setGender(String gender) { this.gender = gender; }
        public String getOrganization() { return organization; }
        public void setOrganization(String organization) { this.organization = organization; }
    }

    public static class CommunicationDTO {
        private String language;
        private Boolean preferred;

        public String getLanguage() { return language; }
        public void setLanguage(String language) { this.language = language; }
        public Boolean getPreferred() { return preferred; }
        public void setPreferred(Boolean preferred) { this.preferred = preferred; }
    }
}


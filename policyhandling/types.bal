// ─── Enumerations ────────────────────────────────────────────────────────────

public enum PolicyType {
    AUTO = "AUTO",
    HOME = "HOME",
    COMMERCIAL = "COMMERCIAL",
    RENTERS = "RENTERS"
}

public enum PolicyStatus {
    ACTIVE = "ACTIVE",
    CANCELLED = "CANCELLED",
    EXPIRED = "EXPIRED",
    PENDING = "PENDING"
}

public enum QuoteStatus {
    DRAFT = "DRAFT",
    ISSUED = "ISSUED",
    ACCEPTED = "ACCEPTED",
    EXPIRED = "EXPIRED",
    BOUND = "BOUND"
}

public enum CoverageType {
    LIABILITY = "LIABILITY",
    COLLISION = "COLLISION",
    COMPREHENSIVE = "COMPREHENSIVE",
    DWELLING = "DWELLING",
    PERSONAL_PROPERTY = "PERSONAL_PROPERTY",
    GENERAL_LIABILITY = "GENERAL_LIABILITY"
}

// ─── Address ─────────────────────────────────────────────────────────────────

public type Address record {|
    string streetLine1;
    string streetLine2?;
    string city;
    string state;
    string zipCode;
    string country;
|};

// ─── Coverage ─────────────────────────────────────────────────────────────────

public type Coverage record {|
    CoverageType coverageType;
    decimal limitAmount;
    decimal deductibleAmount;
    decimal premiumAmount;
|};

// ─── Insured Vehicle (for AUTO policies) ─────────────────────────────────────

public type InsuredVehicle record {|
    string vin;
    string make;
    string model;
    int year;
    string licensePlate;
|};

// ─── Insured Property (for HOME / RENTERS / COMMERCIAL policies) ─────────────

public type InsuredProperty record {|
    string propertyId;
    Address propertyAddress;
    string propertyType;
    decimal estimatedValue;
|};

// ─── Policy Holder ────────────────────────────────────────────────────────────

public type PolicyHolder record {|
    string customerId;
    string firstName;
    string lastName;
    string email;
    string phoneNumber;
    Address mailingAddress;
|};

// ─── Policy ──────────────────────────────────────────────────────────────────

public type Policy record {|
    string policyId;
    string policyNumber;
    PolicyType policyType;
    PolicyStatus policyStatus;
    PolicyHolder policyHolder;
    string effectiveDate;
    string expirationDate;
    decimal annualPremium;
    Coverage[] coverages;
    InsuredVehicle? insuredVehicle;
    InsuredProperty? insuredProperty;
    string createdAt;
    string updatedAt;
|};

// ─── Policy Create Request ────────────────────────────────────────────────────

public type PolicyCreateRequest record {|
    PolicyType policyType;
    PolicyHolder policyHolder;
    string effectiveDate;
    string expirationDate;
    Coverage[] coverages;
    InsuredVehicle? insuredVehicle;
    InsuredProperty? insuredProperty;
|};

// ─── Policy Update Request ────────────────────────────────────────────────────

public type PolicyUpdateRequest record {|
    string? effectiveDate;
    string? expirationDate;
    Coverage[]? coverages;
    InsuredVehicle? insuredVehicle;
    InsuredProperty? insuredProperty;
|};

// ─── Policy Cancel Request ────────────────────────────────────────────────────

public type PolicyCancelRequest record {|
    string cancellationReason;
    string cancellationDate;
|};

// ─── Quote Risk Details ───────────────────────────────────────────────────────

public type QuoteRiskDetails record {|
    InsuredVehicle? vehicle;
    InsuredProperty? property;
    int driverAge?;
    int yearsWithoutClaims?;
    string constructionType?;
    int buildingAge?;
|};

// ─── Quote ───────────────────────────────────────────────────────────────────

public type Quote record {|
    string quoteId;
    string quoteNumber;
    PolicyType policyType;
    QuoteStatus quoteStatus;
    PolicyHolder applicant;
    QuoteRiskDetails riskDetails;
    Coverage[] proposedCoverages;
    decimal estimatedAnnualPremium;
    decimal estimatedMonthlyPremium;
    string quoteValidUntil;
    string? boundPolicyId;
    string createdAt;
    string updatedAt;
|};

// ─── Quote Request ────────────────────────────────────────────────────────────

public type QuoteRequest record {|
    PolicyType policyType;
    PolicyHolder applicant;
    QuoteRiskDetails riskDetails;
    Coverage[] desiredCoverages;
    string requestedEffectiveDate;
|};

// ─── Quote Bind Request ───────────────────────────────────────────────────────

public type QuoteBindRequest record {|
    string quoteId;
    string effectiveDate;
|};

// ─── API Response Wrappers ────────────────────────────────────────────────────

public type PolicyListResponse record {|
    int total;
    int page;
    int pageSize;
    Policy[] policies;
|};

public type QuoteListResponse record {|
    int total;
    int page;
    int pageSize;
    Quote[] quotes;
|};

public type ErrorResponse record {|
    string errorCode;
    string message;
    string timestamp;
|};

public type SuccessResponse record {|
    string message;
    string timestamp;
|};

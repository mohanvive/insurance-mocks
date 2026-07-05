// ─── Enumerations ────────────────────────────────────────────────────────────

public enum ClaimStatus {
    SUBMITTED = "SUBMITTED",
    UNDER_REVIEW = "UNDER_REVIEW",
    INVESTIGATION = "INVESTIGATION",
    APPROVED = "APPROVED",
    PARTIALLY_APPROVED = "PARTIALLY_APPROVED",
    DENIED = "DENIED",
    CLOSED = "CLOSED",
    REOPENED = "REOPENED"
}

public enum ClaimType {
    AUTO_COLLISION = "AUTO_COLLISION",
    AUTO_COMPREHENSIVE = "AUTO_COMPREHENSIVE",
    AUTO_LIABILITY = "AUTO_LIABILITY",
    PROPERTY_DAMAGE = "PROPERTY_DAMAGE",
    THEFT = "THEFT",
    FIRE = "FIRE",
    WATER_DAMAGE = "WATER_DAMAGE",
    LIABILITY = "LIABILITY",
    GENERAL_LIABILITY = "GENERAL_LIABILITY"
}

public enum DocumentType {
    POLICE_REPORT = "POLICE_REPORT",
    PHOTOS = "PHOTOS",
    REPAIR_ESTIMATE = "REPAIR_ESTIMATE",
    MEDICAL_REPORT = "MEDICAL_REPORT",
    INVOICE = "INVOICE",
    PROOF_OF_OWNERSHIP = "PROOF_OF_OWNERSHIP",
    WITNESS_STATEMENT = "WITNESS_STATEMENT",
    OTHER = "OTHER"
}

public enum PaymentStatus {
    PENDING = "PENDING",
    PROCESSED = "PROCESSED",
    FAILED = "FAILED",
    REVERSED = "REVERSED"
}

public enum PaymentMethod {
    BANK_TRANSFER = "BANK_TRANSFER",
    CHECK = "CHECK",
    DIRECT_DEPOSIT = "DIRECT_DEPOSIT"
}

// ─── Claimant ─────────────────────────────────────────────────────────────────

public type Claimant record {|
    string customerId;
    string firstName;
    string lastName;
    string email;
    string phoneNumber;
|};

// ─── Loss Location ────────────────────────────────────────────────────────────

public type LossLocation record {|
    string streetLine1;
    string streetLine2?;
    string city;
    string state;
    string zipCode;
    string country;
|};

// ─── Damaged Vehicle ──────────────────────────────────────────────────────────

public type DamagedVehicle record {|
    string vin;
    string make;
    string model;
    int year;
    string licensePlate;
    string damageDescription;
|};

// ─── Claim Note ───────────────────────────────────────────────────────────────

public type ClaimNote record {|
    string noteId;
    string claimId;
    string authorId;
    string authorName;
    string noteText;
    string createdAt;
|};

public type ClaimNoteRequest record {|
    string authorId;
    string authorName;
    string noteText;
|};

// ─── Claim Document ───────────────────────────────────────────────────────────

public type ClaimDocument record {|
    string documentId;
    string claimId;
    DocumentType documentType;
    string fileName;
    string fileUrl;
    string uploadedBy;
    string uploadedAt;
|};

public type ClaimDocumentRequest record {|
    DocumentType documentType;
    string fileName;
    string fileUrl;
    string uploadedBy;
|};

// ─── Claim Payment ────────────────────────────────────────────────────────────

public type ClaimPayment record {|
    string paymentId;
    string claimId;
    decimal paymentAmount;
    PaymentMethod paymentMethod;
    PaymentStatus paymentStatus;
    string payeeName;
    string payeeAccountRef?;
    string description;
    string processedAt?;
    string createdAt;
|};

public type ClaimPaymentRequest record {|
    decimal paymentAmount;
    PaymentMethod paymentMethod;
    string payeeName;
    string payeeAccountRef?;
    string description;
|};

// ─── Claim ────────────────────────────────────────────────────────────────────

public type Claim record {|
    string claimId;
    string claimNumber;
    string policyId;
    string policyNumber;
    ClaimType claimType;
    ClaimStatus claimStatus;
    Claimant claimant;
    string lossDate;
    string reportedDate;
    LossLocation lossLocation;
    string lossDescription;
    decimal estimatedLossAmount;
    decimal approvedAmount;
    decimal deductibleAmount;
    DamagedVehicle? damagedVehicle;
    string? assignedAdjusterId;
    string? assignedAdjusterName;
    ClaimNote[] notes;
    ClaimDocument[] documents;
    ClaimPayment[] payments;
    string? closedDate;
    string? denialReason;
    string createdAt;
    string updatedAt;
|};

// ─── Claim File Request ───────────────────────────────────────────────────────

public type ClaimFileRequest record {|
    string policyId;
    string policyNumber;
    ClaimType claimType;
    Claimant claimant;
    string lossDate;
    LossLocation lossLocation;
    string lossDescription;
    decimal estimatedLossAmount;
    DamagedVehicle? damagedVehicle;
|};

// ─── Claim Update Request ─────────────────────────────────────────────────────

public type ClaimUpdateRequest record {|
    ClaimStatus? claimStatus;
    decimal? estimatedLossAmount;
    decimal? approvedAmount;
    decimal? deductibleAmount;
    string? assignedAdjusterId;
    string? assignedAdjusterName;
    string? denialReason;
|};

// ─── Claim Close Request ──────────────────────────────────────────────────────

public type ClaimCloseRequest record {|
    string closedDate;
    string closureNotes;
|};

// ─── API Response Wrappers ────────────────────────────────────────────────────

public type ClaimListResponse record {|
    int total;
    int page;
    int pageSize;
    Claim[] claims;
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
